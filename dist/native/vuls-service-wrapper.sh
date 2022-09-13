#!/bin/bash

# Vuls server script for systemd service
# Made by Jonathan Barda / SIB - 2020

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
echo -e "${NL}${BLUE}Vuls server script ${WHITE}/ SIB - 2020${NC}${NL}"

# Config
DEBUG_MODE=false
VULS_SERVER=0.0.0.0
VULSCTL_DIR="/root/vulsctl"
INSTALL_DIR="$VULSCTL_DIR/install-host"
RESULTS_DIR="$INSTALL_DIR/results"
ACTION=$1

# Methods
function svc_start() {
    # Start the server
    echo -e "${WHITE}Starting ${GREEN}Vuls ${WHITE}server...${NC}"
    echo -e "${WHITE}Run ${YELLOW}'systemctl stop vuls'${WHITE} to stop the server.${NC}${NL}"
    if [[ $DEBUG_MODE == "true" ]]; then
        cd $INSTALL_DIR ; vuls server -debug -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
    else
        cd $INSTALL_DIR ; vuls server -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
    fi

    # Verify service status
    if [[ $(ps aux | grep -v grep | grep "vuls server" | wc -l) -eq 1 ]]; then
        echo -e "${GREEN}Started.${NC}${NL}"
        exit 0
    else
        echo -e "${RED}Could not start the server.${NC}${NL}"
        exit 1
    fi
}
function svc_stop() {
    # Stop the server
    echo -e "${WHITE}Stopping ${GREEN}Vuls ${WHITE}server...${NC}${NL}"
    PID=$(ps -aux | grep -v grep | grep "vuls server" | awk '{ print $2 }')
    kill -WINCH $PID 2> /dev/null

    # Verify stop status
    ps aux | grep -v grep | grep "vuls server"
    if [[ $(ps aux | grep -v grep | grep "vuls server" | wc -l) -eq 0 ]]; then
        echo -e "${GREEN}Stopped.${NC}${NL}"
        exit 0
    else
        echo -e "${RED}Could not stop the server.${NC}${NL}"
        exit 1
    fi
}
function svc_restart() {
    # Stop the server
    echo -e "${WHITE}Restarting ${GREEN}Vuls ${WHITE}server...${NC}${NL}"
    PID=$(ps -aux | grep -v grep | grep "vuls server" | awk '{ print $2 }')
    kill -WINCH $PID 2> /dev/null

    # Start the server
    if [[ $DEBUG_MODE == "true" ]]; then
        cd $INSTALL_DIR ; vuls server -debug -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
    else
        cd $INSTALL_DIR ; vuls server -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
    fi

    # Verify service status
    if [[ $(ps aux | grep -v grep | grep "vuls server" | wc -l) -eq 1 ]]; then
        echo -e "${GREEN}Restarted.${NC}${NL}"
        exit 0
    else
        echo -e "${RED}Could not restart the server.${NC}${NL}"
        exit 1
    fi
}

# Service
case $ACTION in
    "start")
        svc_start
    ;;
    "stop")
        svc_stop
    ;;
    "restart")
        svc_restart
    ;;
    *)
        echo -e "${RED}Unsupported action.${NC}${NL}"
        exit 1
    ;;
esac
