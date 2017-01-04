#!/bin/bash
PROJECTDIR=`pwd`
SPLINTDIR=/home/jeff_liu/prac/makefiletest/splint-3.1.2/bin
export TOOLCHAINS_PATH=${PROJECTDIR}/toolchain/gcc-arm-none-eabi-4_8-2014q3
export PATH+=:${TOOLCHAINS_PATH}/bin:
export PROJECTDIR
export SPLINTDIR

