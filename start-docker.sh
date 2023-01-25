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

# MySQL - Setup - loyaltyone_october
cecho "\nMySQL - Setup - ${MYSQL_DATABASE}" ${BLUE}
(
    #mysql_import ${MYSQL_DATABASE} ./mysql/loyaltyone_october.sql
    docker exec -i loy-db mysql --user=root --password=root -e " \
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}; \
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'; \
    GRANT SELECT ON ${MYSQL_DATABASE}.* TO '${MYSQL_EXPORTER_USERNAME}'@'%'; \
    FLUSH PRIVILEGES; " \
    && cecho "MySQL Setup ${MYSQL_DATABASE}" ${GREEN}
)

docker-compose -f docker-compose.yml up -d --build

# OCT - Database Migration
cecho "\nOCT - Database Migration" ${BLUE}
(
    docker exec -i loy-ramsay php artisan october:up \
    && cecho "Database Migrated" ${GREEN}
)

# MySQL - Setup - October CMS System Settings - Remove
cecho "\nMySQL - Setup - October CMS System Settings - Remove" ${BLUE}
(
    docker exec -i loy-db mysql --user=root --password=root -e " \
    DELETE FROM ${MYSQL_DATABASE}.system_settings WHERE item='intellipharm_loyaltyonemembersite_settings';" \
    && cecho "MySQL - Setup - October CMS System Settings removed" ${GREEN}
)

# MySQL - Setup - October CMS System Settings - Configure
cecho "\nMySQL - Setup - October CMS System Settings - Configure" ${BLUE}
(
    docker exec -i loy-db mysql --user=root --password=root -e " \
    INSERT INTO ${MYSQL_DATABASE}.system_settings (item,value) VALUES ('intellipharm_loyaltyonemembersite_settings','{\"app_id\":\"${APP_API_ID@E}\",\"api_base_url\":\"http:\\/\\/loy-api\\/\",\"username\":\"${APP_API_USERNAME@E}\",\"password\":\"${APP_API_PASSWORD@E}\",\"staff_pos_key\":\"${APP_API_STAFF_POS_KEY@E}\",\"staff_name\":\"${APP_API_STAFF_NAME@E}\",\"go_bookings_api\":\"${APP_API_GO_BOOKINGS_API@E}\",\"go_bookings_username\":\"${APP_API_GO_BOOKINGS_USERNAME@E}\",\"go_bookings_password\":\"${APP_API_GO_BOOKINGS_PASSWORD@E}\"}');" \
    && cecho "MySQL - Setup - October CMS System Settings configured" ${GREEN}
)

# OCT - Refresh Plugin - LoyaltyoneMemberSite
cecho "\nOCT - Refresh Plugin - LoyaltyoneMemberSite" ${BLUE}
(
    docker exec -i loy-ramsay php artisan plugin:refresh Intellipharm.LoyaltyoneMemberSite \
    && cecho "Refreshed Plugin - LoyaltyoneMemberSite" ${GREEN}
)

# OCT - Enable Theme - LoyaltyoneMemberSite
cecho "\nOCT - Enable Theme - LoyaltyoneMemberSite" ${BLUE}
(
    docker exec -i loy-ramsay php artisan theme:use loyaltyone-ramsay \
    && cecho "Enabled Theme - LoyaltyoneMemberSite" ${GREEN}
)

# ----------------
# --- COMPLETE ---
# ----------------

# Setup Complete
cecho "\n--------------------------" ${GREEN}
cecho "---- SETUP COMPLETE! -----" ${GREEN}
cecho "--------------------------" ${GREEN}

# Application URLs
cecho "\n🔗 URLs - LoyaltyOne Ramsay" ${LIGHTRED}
cecho "  OCT (FRONTEND): http://ramsay.localhost/" ${YELLOW}
cecho "  OCT (BACKEND): http://ramsay.localhost/backend -> USER: admin PWD: admin" ${YELLOW}