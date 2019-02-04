#!/bin/bash                                                                     
# What? This script creates a SQL user on the local server with a random password
# Who? Thulium (thulium@element-networks.nl)                                    
SQLPASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})             
                                                                                
cat << EOF >/tmp/create_trinitycore_dbs.sql                                     
GRANT USAGE ON * . * TO 'trinity'@'localhost' IDENTIFIED BY "$SQLPASSWORD" WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 ;
                                                                                
CREATE DATABASE world DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;       
CREATE DATABASE characters DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;  
CREATE DATABASE auth DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;        
                                                                                
GRANT ALL PRIVILEGES ON world . * TO 'trinity'@'localhost' WITH GRANT OPTION;   
GRANT ALL PRIVILEGES ON characters . * TO 'trinity'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON auth . * TO 'trinity'@'localhost' WITH GRANT OPTION;    
                                                                                
EOF
                                                                                
mysql -p < /tmp/create_trinitycore_dbs.sql                                      
sed -i "s/SQLPASSWORD/$SQLPASSWORD/" /opt/trinitycore/etc/authserver.conf /opt/trinitycore/etc/worldserver.conf
echo "Databases and SQL user created on local MySQL server with password: $SQLPASSWORD"
