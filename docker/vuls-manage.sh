#!/bin/bash

# Vuls (docker) management / reporting script
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
echo -e "${NL}${BLUE}Vuls ${PURPLE}(docker)${BLUE} management script ${WHITE}/ SIB - 2020${NC}${NL}"

((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<action> ${WHITE}(${PURPLE}server | init | local-scan | tui | webui | history | report | report-all | reporting | create-config | reset-config | config-test | update | help${WHITE})${NC}${NL}" && exit 1

# Config
DEBUG_SERVER=false
VULS_ACTION=$1
VULS_REPORT_METHOD=$2
VULS_REPORT_LEVEL=$3
VULS_HOSTNAME="$(hostname)"
VULS_IP=$(hostname -I | cut -d' ' -f1)
VULSCTL_DIR="$HOME/vulsctl"
DOCKER_DIR="$VULSCTL_DIR/docker"
RESULTS_DIR="$DOCKER_DIR/results"

# Move to the VULSCTL folder
cd $VULSCTL_DIR

# Check action
case "$1" in
    "server")
        echo -e "${WHITE}Starting ${GREEN}Vuls ${WHITE}server...${NC}"
        echo -e "${WHITE}Run ${YELLOW}docker ps -a${WHITE} to see the container.${NC}${NL}"
        if [[ $(ps -efH | grep -v grep | grep 5515 | wc -l) -eq 0 ]]; then
            # Start the scan server
            if [[ $DEBUG_SERVER == "true" ]]; then
                cd $DOCKER_DIR ; ./server.sh -debug
            else
                cd $DOCKER_DIR ; ./server.sh
            fi

            # Small delay before recheck the port
            sleep 2

            # Check the port again
            [[ ! $(ps -efH | grep -v grep | grep 5515 | wc -l) -eq 0 ]] && (
                echo -e "${WHITE}[vuls server]: ${GREEN}started.${NC}"
                echo -e "${WHITE}[vuls server]: ${BLUE}Scan available here: ${GREEN}http://${VULS_HOSTNAME}:5515/vuls${NC}"
                echo -e "${WHITE}[vuls server]: ${BLUE}Health check available here: ${GREEN}http://${VULS_HOSTNAME}:5515/health${NC}${NL}"
            ) || (
                echo -e "${WHITE}[vuls server]: ${RED}failed to start.${NC}${NL}"
            )
        else
            # Server is already started, showing URL
            echo -e "${WHITE}[vuls server]: ${GREEN}server is already started.${NC}"
            echo -e "${WHITE}[vuls server]: ${BLUE}Scan available here: ${GREEN}http://${VULS_HOSTNAME}:5515/vuls${NC}"
            echo -e "${WHITE}[vuls server]: ${BLUE}Health check available here: ${GREEN}http://${VULS_HOSTNAME}:5515/health${NC}${NL}"
        fi
    ;;

    "init")
        echo -e "${WHITE}Applying ${GREEN}initial${WHITE} config settings...${NC}${NL}"

        # Patch current config
        cd $DOCKER_DIR
        cp config.toml config.toml.before-init
        sed -e 's/#\[servers.name\]/\[servers.localhost\]/' -i config.toml
        sed -e 's/#host                = "127.0.0.1"/host                = "127.0.0.1"/' -i config.toml
        sed -e 's/#port               = "22"/port                = "local"/' -i config.toml
        # sed -e 's/#scanMode           = \["fast", "fast-root", "deep", "offline"\]/#scanMode           = \["fast"\]/' -i config.toml
        sed -e 's/\[default\]/#\[default\]/' -i config.toml
        sed -e 's/port               = "22"/#port               = "22"/' -i config.toml
        sed -e 's|keyPath            = "/root/.ssh/id_rsa"|#keyPath            = "/root/.ssh/id_rsa"|' -i config.toml

        # Test new config
        ./config-test.sh
    ;;

    "local-scan")
        echo -e "${WHITE}Running ${GREEN}initial${WHITE} local scan...${NC}${NL}"

        # Replace current config by localscan config
        cd $DOCKER_DIR
        cp config.toml config.toml.before
        cp $VULSCTL_DIR/config.toml.localscan config.toml

        # Scan without arguments
        ./scan.sh

        # Restore current config
        mv config.toml.before config.toml
    ;;

    "tui")
        echo -e "${WHITE}Loading ${GREEN}terminal${WHITE} user interface...${NC}${NL}"
        cd $DOCKER_DIR ; ./tui.sh
    ;;

    "webui")
        echo -e "${WHITE}Starting ${GREEN}Report ${WHITE}server...${NC}"
        echo -e "${WHITE}Run ${YELLOW}docker ps -a${WHITE} to see the container.${NC}${NL}"
        if [[ $(ps -efH | grep -v grep | grep 5111 | wc -l) -eq 0 ]]; then
            # Start the report server
            cd $DOCKER_DIR ; ./vulsrepo.sh

            # Small delay before recheck the port
            sleep 2

            # Check the port again
            [[ ! $(ps -efH | grep -v grep | grep 5111 | wc -l) -eq 0 ]] && (
                echo -e "${WHITE}[vulsrepo server]: ${GREEN}started.${NC}"
                echo -e "${WHITE}[vulsrepo server]: ${BLUE}Service now available here: ${GREEN}http://${VULS_HOSTNAME}:5111${NC}${NL}"
            ) || (
                echo -e "${WHITE}[vulsrepo server]: ${RED}failed to start.${NC}${NL}"
            )
        else
            # Server is already started, showing URL
            echo -e "${WHITE}[vulsrepo server]: ${GREEN}server is already started.${NC}"
            echo -e "${WHITE}[vulsrepo server]: ${BLUE}Service available here: ${GREEN}http://${VULS_HOSTNAME}:5111${NC}${NL}"
        fi
    ;;

    "history")
        echo -e "${WHITE}Loading scan history...${NC}${NL}"
        cd $DOCKER_DIR ; ./history.sh ; echo ""
    ;;

    "report")
        echo -e "${WHITE}Generating recent scan reports...${NC}${NL}"
        cd $DOCKER_DIR ; ./report.sh -format-one-line-text
    ;;

    "report-all")
        echo -e "${WHITE}Generating all scan reports...${NC}${NL}"
        cd $DOCKER_DIR
        for R in $(./history.sh | grep -vi -E -w 'using|latest|digest|status' | awk '{ print $1 }') ; do echo "$R" | ./report.sh -format-one-line-text -pipe ; done
    ;;

    "reporting")
        echo -e "${RED}Do not run this action if you have not configured any reporting methods in the file:${NL}- ${WHITE}$DOCKER_DIR/config.toml${RED}${NC}${NL}"
        if [[ $VULS_REPORT_METHOD == "" ]]; then
            echo -e "${WHITE}Usage: ${GREEN}${0} ${YELLOW}${1} ${BLUE}<reporting-method> ${PURPLE}<reporting-level>"
            echo -e "${WHITE}Available reporting methods: ${YELLOW}email, http${NC}"
            echo -e "${WHITE}Reporting levels: ${YELLOW}1-10${NC}${NL}"
            echo -e "${RED}No reporting method defined.${NC}${NL}"
            exit 2
        elif [[ $VULS_REPORT_LEVEL == "" ]]; then
            echo -e "${WHITE}Usage: ${GREEN}${0} ${YELLOW}${1} ${BLUE}<reporting-method> ${PURPLE}<reporting-level>"
            echo -e "${WHITE}Available reporting methods: ${YELLOW}email, http${NC}"
            echo -e "${WHITE}Reporting levels: ${YELLOW}1-10${NC}${NL}"
            echo -e "${RED}No reporting level defined.${NC}${NL}"
            exit 3
        else
            echo -e "${WHITE}Reporting method selected: ${GREEN}${VULS_REPORT_METHOD}${WHITE}.${NC}"
            echo -e "${WHITE}Reporting level [1-10]: ${YELLOW}${VULS_REPORT_LEVEL}${NC}${NL}"

            case "$VULS_REPORT_METHOD" in
                "email")
                    cd $DOCKER_DIR ; ./report.sh -to-email -cvss-over=$VULS_REPORT_LEVEL
                ;;
                "http")
                    cd $DOCKER_DIR ; ./report.sh -format-json -to-http -cvss-over=$VULS_REPORT_LEVEL
                ;;
            esac
        fi
    ;;

    "create-config")
        echo -e "${WHITE}Creating new config file from ${GREEN}${VULSCTL_DIR}/config.toml.template${WHITE}...${NC}${NL}"
        cp $VULSCTL_DIR/config.toml.template $DOCKER_DIR/config.toml
        echo -e "${GREEN}Initial config creation done.${NC}${NL}"
    ;;

    "reset-config")
        echo -e "${WHITE}Saving actual config to ${GREEN}${DOCKER_DIR}/config.toml.old${WHITE}...${NC}${NL}"
        mv $DOCKER_DIR/config.toml $DOCKER_DIR/config.toml.old
        cp $VULSCTL_DIR/config.toml.template $DOCKER_DIR/config.toml
        echo -e "${GREEN}Config reset done.${NC}${NL}"
    ;;

    "config-test")
        echo -e "${WHITE}Validate current config ${GREEN}${DOCKER_DIR}/config.toml${WHITE}...${NC}${NL}"
        cd $DOCKER_DIR ; ./config-test.sh
    ;;

    "update")
        echo -e "${WHITE}Updating all vulnerabilities databases...${NC}${NL}"
        cd $DOCKER_DIR ; ./update-all.sh
    ;;

    "help")
        echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<action> ${WHITE}(${PURPLE}server | init | local-scan | tui | webui | history | report | report-all | reporting | create-config | reset-config | config-test | update | help${WHITE})${NC}"
        echo -e "${PURPLE} - ${YELLOW}server: ${WHITE}Start the scan server${NC}"
        echo -e "${PURPLE} - ${YELLOW}init: ${WHITE}Apply initial config settings${NC}"
        echo -e "${PURPLE} - ${YELLOW}local-scan: ${WHITE}Run the initial local scan${NC}"
        echo -e "${PURPLE} - ${YELLOW}tui: ${WHITE}Start the terminal interface${NC}"
        echo -e "${PURPLE} - ${YELLOW}webui: ${WHITE}Start the web interface${NC}"
        echo -e "${PURPLE} - ${YELLOW}history: ${WHITE}Show scan history${NC}"
        echo -e "${PURPLE} - ${YELLOW}report: ${WHITE}Generate recent scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}report-all: ${WHITE}Generate all scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}reporting: ${WHITE}Send scan reports${NC}"
        echo -e "${PURPLE} - ${YELLOW}create-config: ${WHITE}Creating new config file from template${NC}"
        echo -e "${PURPLE} - ${YELLOW}reset-config: ${WHITE}Reset Vuls configuration${NC}"
        echo -e "${PURPLE} - ${YELLOW}config-test: ${WHITE}Validate current Vuls configuration${NC}"
        echo -e "${PURPLE} - ${YELLOW}update: ${WHITE}Update all vulnerabilities databases${NC}"
        echo -e "${PURPLE} - ${YELLOW}help: ${WHITE}Show help${NC}"
        echo -e "${NL}"
    ;;
esac
