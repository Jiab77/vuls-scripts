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
echo -e "${NL}${BLUE}Vuls ${PURPLE}(native)${BLUE} server script ${WHITE}/ SIB - 2020${NC}${NL}"

((!$#)) && echo -e "${WHITE}Usage:${GREEN} $0 ${YELLOW}<listen-ip>${NC}${NL}" && exit 1

# Config
DEBUG_MODE=false
VULS_SERVER=$1
VULSCTL_DIR="$HOME/vulsctl"
INSTALL_DIR="$VULSCTL_DIR/install-host"
RESULTS_DIR="$INSTALL_DIR/results"

# Start the server
echo -e "${WHITE}Starting ${GREEN}Vuls ${WHITE}server...${NC}"
echo -e "${WHITE}Hit ${YELLOW}[Ctrl+C]${WHITE} to stop the server.${NC}${NL}"
if [[ $DEBUG_MODE == "true" ]]; then
    cd $INSTALL_DIR ; vuls server -debug -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
else
    cd $INSTALL_DIR ; vuls server -listen "${VULS_SERVER}:5515" -results-dir $RESULTS_DIR -to-localfile -format-json
fi
