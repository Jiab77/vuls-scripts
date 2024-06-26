#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1001

# Vuls client scan script
# Made by Jiab77 / 2020 - 2022
#
# Version: 0.5
#
# Install:
# - sudo cp -v vuls-client-scan.sh /usr/local/bin/vuls-client-scan
# - sudo chmod -v +x /usr/local/bin/vuls-client-scan
#
# TODO:
# - Implement: ./vuls-client-scan.sh <server-ip> <reporting-hostname>
#
# References:
# https://vuls.io/docs/en/usage-server.html
# https://docs.oracle.com/en/database/oracle/oracle-database/18/ladbi/checking-kernel-and-package-requirements-for-linux.html#GUID-7065A86D-C2AB-4731-953B-12AC25C94156
# https://oracle-base.com/articles/linux/installing-software-packages
# https://www.cyberciti.biz/faq/how-do-i-determine-rhel-version/
# https://www.cyberciti.biz/faq/howto-list-installed-rpm-package/
# https://www.2daygeek.com/linux-rpm-command-examples-manage-packages-fedora-centos-rhel-systems/

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

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
echo -e "${NL}${BLUE}Vuls client scan script ${WHITE}/ Jiab77 - 2022${NC}${NL}"

# Usage
((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<server-ip>${NC}${NL}" && exit 1

# Config
DEBUG_MODE=false
VULS_SERVER=$1
HOST_FQDN="$(hostname -f)"
LOCAL_REPORT="/tmp/${HOST_FQDN}.json"
PACK_LIST=/tmp/pkgs.log
REDHAT6=false

# Detect client platform
distro=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d\= -f2 | sed -e 's/"//g')
if [[ $distro == "" ]]; then
    # Use the other way to detect the OS
    # distro=$(cat /etc/redhat-release | awk '{print tolower($1)}')
    distro=$(< /etc/redhat-release awk '{print tolower($1)}')
    REDHAT6=true
fi

# Verify scan result
verify_scan() {
    if [[ -s "$LOCAL_REPORT" ]]; then
        [[ $DEBUG_MODE == false ]] && rm -f "$LOCAL_REPORT" 2>/dev/null
        echo -e "${NL}${GREEN}Scan completed.${NC}${NL}"
    else
        echo -e "${NL}${RED}Failed to run the scan.${NC}${NL}"
    fi
}

# Scan CentOS client
scan_centos() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} CentOS ${WHITE}based client...${NC}${NL}"
    echo -e "$(rpm -qa --queryformat "%{NAME} %{EPOCHNUM} %{VERSION} %{RELEASE} %{ARCH}\n")" > $PACK_LIST
    if [[ $REDHAT6 == "true" ]]; then
        curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(awk '{print tolower($1)}' /etc/redhat-release)" -H "X-Vuls-OS-Release: $(awk '{print $3}' /etc/redhat-release)" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    else
        curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(awk '{print tolower($1)}' /etc/redhat-release)" -H "X-Vuls-OS-Release: $(awk '{print $4}' /etc/redhat-release)" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    fi
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Scan Oracle Linux client
scan_oracle() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} Oracle Linux ${WHITE}based client...${NC}${NL}"
    echo -e "$(rpm -qa --queryformat "%{NAME} %{EPOCHNUM} %{VERSION} %{RELEASE} %{ARCH}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(awk '{print tolower($1)}' /etc/oracle-release)" -H "X-Vuls-OS-Release: $(awk '{print $5}' /etc/oracle-release)" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Scan RedHat Entreprise Linux client
scan_rhel() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} RedHat Entreprise Linux ${WHITE}based client...${NC}${NL}"
    echo -e "$(rpm -qa --queryformat "%{NAME} %{EPOCHNUM} %{VERSION} %{RELEASE} %{ARCH}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(awk '{print tolower($1)}' /etc/redhat-release)" -H "X-Vuls-OS-Release: $(awk '{print $7}' /etc/redhat-release)" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Scan Rocky Linux client
scan_rocky() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} Rocky Linux ${WHITE}based client...${NC}${NL}"
    echo -e "$(rpm -qa --queryformat "%{NAME} %{EPOCHNUM} %{VERSION} %{RELEASE} %{ARCH}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(awk '{print tolower($1)}' /etc/redhat-release)" -H "X-Vuls-OS-Release: $(awk '{print $4}' /etc/redhat-release)" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Scan Pop!_OS client
scan_pop() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} Pop!_OS ${WHITE}based client...${NC}${NL}"
    echo -e "$(dpkg-query -W -f="\${binary:Package},\${db:Status-Abbrev},\${Version},\${Source},\${source:Version}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: ubuntu" -H "X-Vuls-OS-Release: $(lsb_release -sr | awk '{print $1}')" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Scan Ubuntu client
scan_ubuntu() {
    echo -e "${WHITE}Scanning ${GREEN}${HOST_FQDN} ${WHITE}/${YELLOW} Ubuntu ${WHITE}based client...${NC}${NL}"
    echo -e "$(dpkg-query -W -f="\${binary:Package},\${db:Status-Abbrev},\${Version},\${Source},\${source:Version}\n")" > $PACK_LIST
    curl -X POST -H "Content-Type: text/plain" -H "X-Vuls-OS-Family: $(lsb_release -si | awk '{print tolower($1)}')" -H "X-Vuls-OS-Release: $(lsb_release -sr | awk '{print $1}')" -H "X-Vuls-Kernel-Release: $(uname -r)" -H "X-Vuls-Server-Name: ${HOST_FQDN}" --data-binary @$PACK_LIST "http://${VULS_SERVER}:5515/vuls" > "$LOCAL_REPORT"
    ret_code=$?
    if [[ $ret_code -eq 7 ]]; then
        echo -e "${NL}${RED}Failed to reach the scan server.${NC}${NL}"
    else
        verify_scan
    fi
    rm -f $PACK_LIST 2>/dev/null
}

# Select which function to run on the client
case $distro in
    "centos")
        scan_centos
    ;;
    "ol")
        scan_oracle
    ;;
    "rhel")
        scan_rhel
    ;;
    "rocky")
        scan_rocky
    ;;
    "pop")
        scan_pop
    ;;
    "ubuntu")
        scan_ubuntu
    ;;
    *)  # we can add more scanning commands for each distros.
        echo -e "${YELLOW}Your OS distribution [${RED}${distro}${YELLOW}] is not supported by the script yet.${NC}"
        echo -e "${YELLOW}Details:${NC}${NL}"
        if [[ $REDHAT6 == "true" ]]; then
            cat /etc/redhat-release
        else
            cat /etc/os-release
        fi
        echo -e "${NL}${YELLOW}Please contact the admins.${NC}${NL}"
    ;;
esac
