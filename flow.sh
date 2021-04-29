#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
set -euf -o pipefail

# Current script path; doesn't support symlink
FRISCVDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Bash color codes
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
# Reset
Color_Off='\033[0m'

function printerror {
    echo -e "${Red}ERROR: ${1}${Color_Off}"
}

function printwarning {
    echo -e "${Yellow}WARNING: ${1}${Color_Off}"
}

function printinfo {
    echo -e "${Blue}INFO: ${1}${Color_Off}"
}

function printsuccess {
    echo -e "${Green}INFO: ${1}${Color_Off}"
}

help() {
    echo -e "${Blue}"
    echo ""
    echo "NAME"
    echo ""
    echo "      FRISCV Flow"
    echo ""
    echo "SYNOPSIS"
    echo ""
    echo "      ./flow.sh -h"
    echo ""
    echo "      ./flow.sh help"
    echo ""
    echo "      ./flow.sh syn"
    echo ""
    echo "      ./flow.sh sim"
    echo ""
    echo "DESCRIPTION"
    echo ""
    echo "      This flow handles the different operations available"
    echo ""
    echo "      ./flow.sh help|-h"
    echo ""
    echo "      Print the help menu"
    echo ""
    echo "      ./flow.sh syn"
    echo ""
    echo "      Launch the synthesis script relying on Yosys"
    echo ""
    echo "      ./flow.sh sim"
    echo ""
    echo "      Launch all available testsuites"
    echo ""
    echo -e "${Color_Off}"
}

main() {

    echo ""
    printinfo "Start FRISCV Flow"

    # If no argument provided, preint help and exit
    if [[ $# -eq 0 ]]; then
        help
        exit 1
    fi

    # Print help
    if [[ $1 == "-h" || $1 == "help" ]]; then

        help
        exit 0
    fi

    # source scripts/setup.sh

    iverilog -V

    if [[ $1 == "lint" ]]; then
        printinfo "Start linting"
        verilator --lint-only +1800-2017ext+sv -Wall -cdc \
            -I./rtl\
            ./rtl/friscv_h.sv\
            ./rtl/friscv_registers.sv\
            ./rtl/friscv_rv32i.sv\
            ./rtl/friscv_rv32i_alu.sv\
            ./rtl/friscv_rv32i_control.sv\
            ./rtl/friscv_rv32i_decoder.sv\
            ./rtl/friscv_scfifo.sv\
            ./rtl/friscv_scfifo_ram.sv\
            --top-module friscv_rv32i
    fi
    if [[ $1 == "sim" ]]; then
        printinfo "Start simulation"
        cd "$FRISCVDIR/test/rtl_unit_tests"
        return $?
    fi

    if [[ $1 == "syn" ]]; then
        printinfo "Start synthesis"
        cd "$FRISCVDIR/syn"
        ./run.sh
        return $?
    fi
}

main "$@"