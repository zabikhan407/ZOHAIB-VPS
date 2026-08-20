#!/bin/bash

# ==============================================================================
# Script Name   : ZOHAIB KHAN NETWORK VPN Panel
# Custom Path   : /etc/zohaibkhan
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PANEL_NAME="ZOHAIB KHAN NETWORK"
CUSTOM_PATH="/etc/zohaibkhan"
DOMAIN_FILE="$CUSTOM_PATH/domain.conf"
USERS_DIR="$CUSTOM_PATH/users"

mkdir -p "$USERS_DIR"
mkdir -p "$CUSTOM_PATH/tgbot"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] Root user se login karein!${NC}"
   exit 1
fi

# Function to setup Menu
setup_command() {
    cat << 'EOF' > /usr/local/bin/menu
#!/bin/bash
# ZOHAIB KHAN NETWORK Menu Loader
bash /etc/zohaibkhan/main_menu.sh
EOF
    chmod +x /usr/local/bin/menu
    ln -sf /usr/local/bin/menu /usr/bin/zohaib
}

# Core Menu Script
cat << 'EOF' > /etc/zohaibkhan/main_menu.sh
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

get_domain() { [ -f "/etc/zohaibkhan/domain.conf" ] && cat /etc/zohaibkhan/domain.conf || echo "No Domain"; }

clear
echo -e "${CYAN}==================================================${NC}"
echo -e "       ${YELLOW}ZOHAIB KHAN NETWORK VPN PANEL${NC}"
echo -e "       Domain: ${GREEN}$(get_domain)${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "  ${GREEN}1)${NC} Add User"
echo -e "  ${GREEN}2)${NC} Delete User"
echo -e "  ${GREEN}3)${NC} List Users"
echo -e "  ${GREEN}4)${NC} Setup Domain & SSL"
echo -e "  ${GREEN}5)${NC} Restart Services"
echo -e "  ${GREEN}0)${NC} Exit"
echo -e "${CYAN}==================================================${NC}"
read -p "Select option: " opt

case $opt in
    1)
        read -p "Username: " uname
        read -p "Password: " upass
        read -p "Days: " udays
        exp=$(date -d "+$udays days" +"%Y-%m-%d")
        useradd -M -s /bin/bash -e "$exp" "$uname"
        echo "$uname:$upass" | chpasswd
        echo "IP_LIMIT=2\nGB_LIMIT=Unlimited\nUSED_MB=0" > "/etc/zohaibkhan/users/$uname.conf"
        echo -e "${GREEN}User Created!${NC}"; sleep 2; menu ;;
    2)
        read -p "Username to delete: " uname
        userdel -f "$uname"
        rm -f "/etc/zohaibkhan/users/$uname.conf"
        echo -e "${RED}User Deleted!${NC}"; sleep 2; menu ;;
    3)
        ls /etc/zohaibkhan/users/ | sed 's/.conf//'
        read -p "Press enter..." ; menu ;;
    4)
        read -p "Enter Domain: " dom
        echo "$dom" > /etc/zohaibkhan/domain.conf
        apt install -y certbot nginx
        systemctl stop nginx
        certbot certonly --standalone -d "$dom" --agree-tos --register-unsafely-without-email
        systemctl start nginx
        echo -e "${GREEN}SSL Done!${NC}"; sleep 2; menu ;;
    5)
        systemctl restart dropbear nginx
        echo -e "${GREEN}Restarted!${NC}"; sleep 2; menu ;;
    0) exit ;;
esac
EOF

chmod +x /etc/zohaibkhan/main_menu.sh
setup_command

# Install Dependencies
echo -e "${YELLOW}Installing Dependencies...${NC}"
apt update && apt install -y dropbear nginx python3 python3-pip
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=109/g' /etc/default/dropbear
echo 'DROPBEAR_EXTRA_ARGS="-p 447"' >> /etc/default/dropbear
systemctl restart dropbear

clear
echo -e "${GREEN}==========================================${NC}"
echo -e "   ZOHAIB KHAN NETWORK Installed!"
echo -e "   Type 'menu' or 'zohaib' to open panel"
echo -e "${GREEN}==========================================${NC}"
