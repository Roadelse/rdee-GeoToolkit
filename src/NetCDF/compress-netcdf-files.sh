#!/bin/bash

#@ Introduction |
#@ This script aims to compress all netcdf files in batch

#@ Prepare
#@ .General-Setting
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "\033[31mError!\033[0m The script can only be sourced rather than be executed!"
    exit 101
fi
scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && readlink -f .)
workDir=$PWD

#@ .preliminary-functions
function error() {
    echo -e '\033[31m'"Error"'\033[0m' "$1"
    exit 101
}
function progress() {
    echo -e '\033[33m-- '"($(date '+%Y/%m/%d %H:%M:%S')) ""$1"'\033[0m'
}


#@ <.arguments>
#@ <..default>
infile=
compressLevel=1
help=0
#@ <..resolve>
while getopts "hi:c:" arg; do
    case $arg in
    h)
        help=1
        ;;
    c)
        compressLevel=$OPTARG
        ;;
    i)
        infile=$OPTARG
        ;;
    ?)
        error "Unknown option: $OPTARG"
        ;;
    esac
done

#@ .help
if [[ $help == 1 ]]; then
    echo "
This script is used to compress netcdf files in batch processing via ncks

[Usage]
    bash .../compress-netcdf-files.sh <-i infile> [-c compressionLevel]

    Options:
    ● -i infile
        Required, select input file where each line denotes to one netcdf file path
    ● -c compressionLevel
        Optional, select compression level, from 0 to 9
"
    exit 0
fi

#@ <.pre-check>
#@ <..ncks>
if [[ -z $(which ncks 2>/dev/null) ]]; then
    error "Cannot find ncks executable"
fi


#@ .check-Filelist
if [[ ! -f "$infile" ]]; then
    error "This script requires [infile] to obtain target netcdf files"
fi

#@ Main
i=0
while [[ 1 ]]; do
    (( i++ ))
    fileT=$(head -n 1 "$infile")
    if [[ -z "$fileT" ]]; then
        break
    fi
    fileN=${fileT}.compress

    progress "Compressing $fileT"
    ncks -4 --deflate $compressLevel $fileT $fileN
    if [[ $? != 0 ]]; then
        error "Failed to compress netcdf file: $fileT"
    fi

    mv -f $fileN $fileT
    sed -i '1d' $infile
#    if [[ $i == 3 ]]; then
#        exit 0
#    fi
done
