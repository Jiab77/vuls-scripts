#!/bin/bash

# Vuls management / reporting script
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
echo -e "${NL}${BLUE}Vuls management script ${WHITE}/ Jiab77 - 2020${NC}${NL}"

((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<action> ${WHITE}(${YELLOW}server | tui | webui | history | report | report-all | reporting | reset-config | update | help${WHITE})${NC}${NL}" && exit 1

# Config
DEBUG_SERVER=false
VULS_ACTION=$1
VULS_REPORT_METHOD=$2
VULS_REPORT_LEVEL=$3
VULS_HOSTNAME="$(hostname)"
VULS_IP=$(hostname -I | cut -d' ' -f1)
VULSCTL_DIR="$HOME/vulsctl"
RESULTS_DIR="$VULSCTL_DIR/results"

# Move to the VULSCTL folder
cd $VULSCTL_DIR

# Check action
case "$1" in
    "server")
        echo -e "${WHITE}Starting ${GREEN}Vuls ${WHITE}server...${NC}"
        echo -e "${WHITE}Hit ${YELLOW}[Ctrl+C]${WHITE} to stop the server.${NC}${NL}"
        if [[ $DEBUG_SERVER == "true" ]]; then
            vuls server -debug -listen "${VULS_IP}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
        else
            vuls server -listen "${VULS_IP}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
        fi
    ;;

    "tui")
        echo -e "${WHITE}Loading ${GREEN}terminal${WHITE} user interface...${NC}${NL}"
        vuls tui
    ;;

    "webui")
        echo -e "${WHITE}Loading ${GREEN}web${WHITE} user interface...${NC}${NL}"
        if [[ $(ps -efH | grep -v grep | grep 5111 | wc -l) -eq 0 ]]; then
            # Start the webui server
            $VULSCTL_DIR/vulsrepo.sh

            # Small delay before recheck the port
            sleep 2

            # Check the port again
            [[ ! $(ps -efH | grep -v grep | grep 5111 | wc -l) -eq 0 ]] && (
                echo -e "${WHITE}[webui server]: ${GREEN}started.${NC}"
                echo -e "${WHITE}[webui server]: ${BLUE}Web Interface available here: ${GREEN}http://${VULS_HOSTNAME}:5111${NC}${NL}"
            ) || (
                echo -e "${WHITE}[webui server]: ${RED}failed to start.${NC}${NL}"
            )
        else
            # Server is already started, showing URL
            echo -e "${WHITE}[webui server]: ${GREEN}server is already started.${NC}"
            echo -e "${WHITE}[webui server]: ${BLUE}Web Interface available here: ${GREEN}http://${VULS_HOSTNAME}:5111${NC}${NL}"
        fi
    ;;

    "history")
        echo -e "${WHITE}Loading scan history...${NC}${NL}"
        vuls history ; echo ""
    ;;

    "report")
        echo -e "${WHITE}Generating recent scan reports...${NC}${NL}"
        vuls report -format-one-line-text
    ;;

    "report-all")
        echo -e "${WHITE}Generating all scan reports...${NC}${NL}"
        for R in $(vuls history | awk '{ print $1 }') ; do echo "$R" | vuls report -format-one-line-text -pipe ; done
    ;;

    "reporting")
        echo -e "${RED}Do not run this action if you have not configured any reporting methods in the ${WHITE}$VULSCTL_DIR/config.toml${RED} file.${NC}${NL}"
        if [[ $VULS_REPORT_METHOD == "" ]]; then
            echo -e "${WHITE}Usage: ${GREEN}${0} ${YELLOW}${1} ${BLUE}<reporting-method> ${PURPLE}<reporting-level>"
            echo -e "${WHITE}Available reporting methods: ${YELLOW}email${NC}"
            echo -e "${WHITE}Reporting levels: ${YELLOW}1-10${NC}${NL}"
            if [[ $VULS_REPORT_LEVEL == "" ]]; then
                echo -e "${WHITE}Defined reporting level: ${RED}Not defined${NC}${NL}"
            else
                echo -e "${WHITE}Defined reporting level: ${YELLOW}${VULS_REPORT_LEVEL}${NC}${NL}"
            fi
            echo -e "${RED}No reporting method defined.${NC}${NL}"
            exit 2
        else
            echo -e "${WHITE}Reporting method selected: ${GREEN}${VULS_REPORT_METHOD}${WHITE}.${NC}${NL}"

            case "$VULS_REPORT_METHOD" in
                "email")
                    vuls report -to-email -cvss-over=$VULS_REPORT_LEVEL
                ;;
            esac
        fi
    ;;

    "reset-config")
        echo -e "${WHITE}Saving actual config to ${GREEN}${PWD}/config.toml.old${WHITE}...${NC}${NL}"
        mv $PWD/config.toml $PWD/config.toml.old
        cp $PWD/config.toml.template $PWD/config.toml
        echo -e "${GREEN}Config reset done.${NC}${NL}"
    ;;

    "update")
        echo -e "${WHITE}Updating all vulnerabilities databases...${NC}${NL}"
        $VULSCTL_DIR/update-all.sh
    ;;

    "help")
        echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<action> ${WHITE}(${YELLOW}server | tui | webui | history | report | report-all | reporting | reset-config | update | help${WHITE})${NC}"
        echo -e "${PURPLE} - ${YELLOW}server: ${WHITE}Start the scan server${NC}"
        echo -e "${PURPLE} - ${YELLOW}tui: ${WHITE}Start the terminal interface${NC}"
        echo -e "${PURPLE} - ${YELLOW}webui: ${WHITE}Start the web interface${NC}"
        echo -e "${PURPLE} - ${YELLOW}history: ${WHITE}Show scan history${NC}"
        echo -e "${PURPLE} - ${YELLOW}report: ${WHITE}Generate recent scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}report-all: ${WHITE}Generate all scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}reporting: ${WHITE}Send scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}reset-config: ${WHITE}Reset Vuls configuration${NC}"
        echo -e "${PURPLE} - ${YELLOW}update: ${WHITE}Update all vulnerabilities databases${NC}"
        echo -e "${PURPLE} - ${YELLOW}help: ${WHITE}Show help${NC}"
        echo -e "${NL}"
    ;;
esac