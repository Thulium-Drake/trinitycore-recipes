#!/bin/bash
# What? Create mmaps, vmaps and dbc files for TrinityCore
# Who? Thulium (thulium@element-networks.nl)

# Check if we are in a WoW client folder
[ ! -f Wow.exe ] && echo "!! Error: This doesn't look like a WoW client folder!" && exit 1

# Make all directories required
mkdir vmaps mmaps

# Run extractors
echo "################################
# Phase 1 : Extracting maps    #
################################"
mapextractor
echo "################################
# Phase 2 : Extracting vmaps   #
################################"
vmap4extractor
echo "################################
# Phase 3 : Assembling vmaps   #
################################"
vmap4assembler Buildings vmaps
echo "################################
# Phase 4 : Generating mmaps   #
################################"
mmaps_generator

# Make sure the disk has synced all writes before we zip them up
sync

# Check which version of the tools we are running
if [ "$(dpkg -S /opt/trinitycore/bin/mapextractor | cut -d: -f1)" == "trinitycore-tools3.3.5" ]
then
  echo "######################################
# Building tar for TrinityCore 3.3.5 #
######################################"
  tar czf trinitycore-data.tgz dbc maps mmaps vmaps
else
  echo "#######################################                                  
# Building tar for TrinityCore master #                                          
#######################################"
  tar czf trinitycore-data.tgz dbc gt maps mmaps vmaps
fi

# Clean up the mess we made
rm -rf Buildings Cameras dbc maps mmaps vmaps

# Echo where the package is
echo "# Your data package is in $(pwd)/trinitycore-data.tgz"

# Ask if the user wishes us to apply the data package
read -p "# Would you like this script to apply it on your server? y/N " RESPONSE
case $RESPONSE in
    [yY])
        # Ask the server on which to apply the tar file
        read -p "##############################################################################
# Please provide the username and server on which to apply the data package  #
# e.g. root@trinitycore-server                                               #
#                                                                            #
# This script will then upload and extract the data package for you          #
# overwriting the current maps.                                              #
#                                                                            #
# NOTE: You might be asked for a password to login, this will happen 2 times #
##############################################################################

TrinityCore server: " HOST

        [ -z $HOST ] && echo "!! Error: no host supplied, exiting" && exit 1

        scp trinitycore-data.tgz $HOST:/tmp
        ssh $HOST "systemctl stop trinitycore-worldserver; rm -rf /opt/trinitycore/data; mkdir /opt/trinitycore/data; tar xzf /tmp/trinitycore-data.tgz -C /opt/trinitycore/data; systemctl start trinitycore-worldserver"
        ;;
    *)
        echo "# All done! Exiting"
        exit 0
        ;;
esac
