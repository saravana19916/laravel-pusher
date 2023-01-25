#!/bin/bash
#!/bin/bash
set -o pipefail

# Load .env file
if [ ! -f .env ]; then
    cp .env.example .env
fi
source .env


# -----------------
# --- UTILITIES ---
# -----------------

# BASH Colours
DARKGRAY='\033[1;30m'
RED='\033[0;31m'    
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'    
YELLOW='\033[0;33m'
BLUE='\033[0;34m'    
PURPLE='\033[0;35m'    
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'    
WHITE='\033[1;37m'
SET='\033[0m'
cecho () {
    local default_msg="No message passed."
    message=${1:-$default_msg}
    COLOUR=${2:-$WHITE}
    echo -e "${COLOUR}$message${SET}"
}

# ------------------
# --- OCT CONFIG ---
# ------------------

# OCT - Copy config-example folder
cecho "\nOCT - Copy config-example folder\n - ./config/*" ${BLUE}
if [ -d ./config ]; then
    cecho "Configs already copied" ${GREEN}
else
    cp -r ./config-example ./config \
    && cecho "Configs copied" ${GREEN}
    sed -i "s|'url' => 'http://localhost',|'url' => 'http://ramsay.localhost',|g" ./config/app.php
    # Configure OCT - database.php
    sed -zri "s|[ \t]+'mysql'[ \t]+=>[ \t]+\[\n[ \t]+'driver'[ \t]+=> 'mysql',\n[ \t]+'host'[ \t]+=> 'localhost',\n[ \t]+'port'[ \t]+=> 3306,\n[ \t]+'database'[ \t]+=> 'database',\n[ \t]+'username'[ \t]+=> 'root',\n[ \t]+'password'[ \t]+=> '',\n[ \t]+'charset'[ \t]+=> 'utf8mb4',\n[ \t]+'collation'[ \t]+=> 'utf8mb4_unicode_ci',\n[ \t]+'prefix'[ \t]+=> '',\n[ \t]+\],|\t\t'mysql' => [\n\t\t\t'driver'\t=> 'mysql',\n\t\t\t'host'\t\t=> 'loy-db',\n\t\t\t'port'\t\t=> 3306,\n\t\t\t'database'\t=> '${MYSQL_DATABASE}',\n\t\t\t'username'\t=> '${MYSQL_USER}',\n\t\t\t'password'\t=> '${MYSQL_PASSWORD}',\n\t\t\t'charset'\t=> 'utf8mb4',\n\t\t\t'collation'\t=> 'utf8mb4_unicode_ci',\n\t\t\t'prefix'\t=> '',\n\t\t],|g" ./config/database.php
    sed -zri "s|[ \t]+'redis'[ \t]+=>[ \t]+\[\n\n[ \t]+'cluster'[ \t]+=>[ \t]+false,\n\n[ \t]+'default'[ \t]+=>[ \t]+\[\n[ \t]+'host'[ \t]+=>[ \t]+'127\.0\.0\.1',\n[ \t]+'password'[ \t]+=>[ \t]+null,\n[ \t]+'port'[ \t]+=>[ \t]+6379,\n[ \t]+'database'[ \t]+=>[ \t]+0,\n[ \t]+\],\n\n[ \t]+\],|\t'redis' => [\n\n\t\t'cluster' => false,\n\n\t\t'default' => [\n\t\t\t'host'\t\t=> 'loy-redis',\n\t\t\t'password'\t=> null,\n\t\t\t'port'\t\t=> 6379,\n\t\t\t'database'\t=> 0,\n\t\t],\n\n\t],|g" ./config/database.php
fi
# OCT - Permissions
cecho "\nOCT - Fix Permissions" ${BLUE}
sudo chown ${USER}:${USER} -R . \
&& chmod -R 777 ./themes \
&& chmod -R 777 ./storage/app/uploads \
&& chmod -R 777 ./storage \
&& cecho "OCT permissions fixed" ${GREEN}

composer install

apachectl -D FOREGROUND
