#!/bin/bash

# Vuls client scan script
# Made by Jiab77 - 2020

# Colors
NC="\033[0m"
NL="\n"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;37m"
PURPLE="\033[1;35m"

# Header
echo -e "${NL}${BLUE}Vuls client scan script ${WHITE}/ Jiab77 - 2020${NC}${NL}"

# Usage
((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<server-ip>${NC}${NL}" && exit 1

# Config
VULS_SERVER=$1
LOCAL_REPORT="$(hostname).json"
PACK_LIST=/tmp/pkgs.log
REDHAT6=false

# Detect client platform
distro=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d\= -f2 | sed -e 's/"//g')
if [[ $distro == "" ]]; then
    # Use the other way to detect the OS
    distro=$(cat /etc/redhat-release | awk '{print tolower($1)}')
    REDHAT6=true
fi

# Verify scan result
verify_scan() {
    if [[ -s $LOCAL_REPORT ]]; then
        rm -f $LOCAL_REPORT 2>/dev/null
        echo -e "${NL}${GREEN}Scan completed.${NC}${NL}"
    else
        echo -e "${NL}${RED}Failed to run the scan.${NC}${NL}"
    fi
}

# Scan Ubuntu client
scan_ubuntu() {
    echo -e "${WHITE}Scanning ${GREEN}$(hostname) ${WHITE}/${YELLOW} Ubuntu ${WHITE}based client...${NC}${NL}"
    echo -e "$(dpkg-query -W -f="\${binary:Package},\${db:Status-Abbrev},\${Version},\${Source},\${source:Version}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: `lsb_release -si | awk '{print tolower($1)}'`" -H "X-Vuls-OS-Release: `lsb_release -sr | awk '{print $1}'`" -H "X-Vuls-Kernel-Release: `uname -r`" -H "X-Vuls-Server-Name: `hostname`" --data-binary @$PACK_LIST http://${VULS_SERVER}:5515/vuls > $LOCAL_REPORT
    rm -f $PACK_LIST 2>/dev/null
    verify_scan
}

# Scan CentOS client
scan_centos() {
    echo -e "${WHITE}Scanning ${GREEN}$(hostname) ${WHITE}/${YELLOW} CentOS ${WHITE}based client...${NC}${NL}"
    echo -e "`rpm -qa --queryformat "%{NAME} %{EPOCHNUM} %{VERSION} %{RELEASE} %{ARCH}\n"`" > $PACK_LIST
    if [[ $REDHAT6 == "true" ]]; then
        curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: `awk '{print tolower($1)}' /etc/redhat-release`" -H "X-Vuls-OS-Release: `awk '{print $3}' /etc/redhat-release`" -H "X-Vuls-Kernel-Release: `uname -r`" -H "X-Vuls-Server-Name: `hostname`" --data-binary @$PACK_LIST http://${VULS_SERVER}:5515/vuls > $LOCAL_REPORT
    else
        curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: `awk '{print tolower($1)}' /etc/redhat-release`" -H "X-Vuls-OS-Release: `awk '{print $4}' /etc/redhat-release`" -H "X-Vuls-Kernel-Release: `uname -r`" -H "X-Vuls-Server-Name: `hostname`" --data-binary @$PACK_LIST http://${VULS_SERVER}:5515/vuls > $LOCAL_REPORT
    fi
    rm -f $PACK_LIST 2>/dev/null
    verify_scan
}

# Select which function to run on the client
case $distro in
    "ubuntu")
        scan_ubuntu;;
    "centos")
        scan_centos;;
    *)  # we can add more install command for each distros.
        echo -e "${YELLOW}Your OS distribution [${RED}${distro}${YELLOW}] is not supported by the script yet.${NC}"
        echo -e "${YELLOW}Details:${NC}${NL}"
        if [[ $REDHAT6 == "true" ]]; then
            cat /etc/redhat-release
        else
            cat /etc/os-release
        fi
        echo -e "${NL}${YELLOW}Please contact the dev.${NC}${NL}"
    ;;
esac
