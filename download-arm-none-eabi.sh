#!/usr/bin/sh

help()
{
    echo "Usage: download-arm-none-eabi.sh [ -p | --path ] /path/to/dir
               [ -h | --help  ]"
    exit 0
}

PATH_TO_INSTALL="/home/$USER"


install_arm()
{
    wget https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz
    tar -xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz -C "$PATH_TO_INSTALL"
    echo "arm-none-eabi installed at $PATH_TO_INSTALL"
}




if [ $# -eq 0 ]
then
    printf "Do you want to install arm-none-eabi at $PATH_TO_INSTALL? [y/N] "
    read response
if [ "$response" != "${response#[Yy]}" ] ;
    then
       install_arm
    else
        help
    fi
    exit 0
fi



case "$1" in
-p | --path )
    PATH_TO_INSTALL=$2
    if [[ ! -d "$PATH_TO_INSTALL" ]]
    then
        echo "$PATH_TO_INSTALL doesn't exists on your filesystem."
    else
        install_arm
    fi
    ;;

-h | --help)
    help
    ;;

*)
    echo "Unexpected option: $1"
    help
    ;;
esac





