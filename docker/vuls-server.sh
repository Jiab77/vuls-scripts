#!/bin/bash

# Vuls server script
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
echo -e "${NL}${BLUE}Vuls ${PURPLE}(docker)${BLUE} server script ${WHITE}/ Jiab77 - 2020${NC}${NL}"

((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<listen-ip>${NC}${NL}" && exit 1

# Config
DEBUG_MODE=false
VULS_SERVER=$1
VULSCTL_DIR="$HOME/vulsctl"
DOCKER_DIR="$VULSCTL_DIR/docker"
RESULTS_DIR="$VULSCTL_DIR/results"

# Start the server
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
