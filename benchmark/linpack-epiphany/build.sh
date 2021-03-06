#!/bin/bash

set -e # exits immediately if exit 0 somewhere

ESDK=${EPIPHANY_HOME}
ELIBS="-L ${ESDK}/tools/host/lib"
EINCS="-I ${ESDK}/tools/host/include"
ELDF=${ESDK}/bsps/current/internal.ldf

# Create the binaries directory
#mkdir -p bin/

CROSS_PREFIX=
case $(uname -p) in
	arm*)
		# Use native arm compiler (no cross prefix)
		CROSS_PREFIX=
		;;
	   *)
		# Use cross compiler
		CROSS_PREFIX="arm-linux-gnueabihf-"
		;;
esac

# Build HOST side application
${CROSS_PREFIX}gcc -DSP -DROLL -O4 clinpack.c -o clinpack.elf  ${EINCS} ${ELIBS} -le-hal -le-loader -lpthread -lm

# Build DEVICE side program
# -T specifies the linker file
# -O0 reduce compilation time, specifies optimization level
OPT=0
e-gcc -T ${ELDF} -O${OPT} emain.c -o emain.elf -le-lib -lm

# Convert ebinary to SREC file
e-objcopy --srec-forceS3 --output-target srec emain.elf emain.srec
