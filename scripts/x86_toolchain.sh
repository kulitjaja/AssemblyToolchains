#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022

;this script compiles and runs x86 assembly

;Input validation: Check if the assembly filename contains only alphanumeric chracters and underscores
validate_input() {
    if [[ ! $1 =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid asembly filename."
        exit 1
    fi
}
;This is to check if there are at least 1 command-line arguement; if not, display usage instructions
if [ $# -lt 1 ]; then
	echo "Usage:"
	echo ""
	echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	echo ""
	echo "-v | --verbose                Show some information about steps performed."
	echo "-g | --gdb                    Run gdb command on executable."
	echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
	echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
	echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
	echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
	echo "-o | --output <filename>      Output filename."

	exit 1
fi
;This initializes variabes
POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=False
QEMU=False
BREAK="_start"
RUN=False
;Parse command-line arguements
while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)
			GDB=True
			shift # past argument
			;;
		-o|--output)
			OUTPUT_FILE="$2"
			shift # past argument
			shift # past value
			;;
		-v|--verbose)
			VERBOSE=True
			shift # past argument
			;;
		-64|--x84-64)
			BITS=True
			shift # past argument
			;;
		-q|--qemu)
			QEMU=True
			shift # past argument
			;;
		-r|--run)
			RUN=True
			shift # past argument
			;;
		-b|--break)
			BREAK="$2"
			shift # past argument
			shift # past value
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

;Check if the specified file exists
if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi
;set the output filename if not provided
if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi
;Displays configuration if in verbose mode
if [ "$VERBOSE" == "True" ]; then
	echo "Arguments being set:"
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	64 bit mode = $BITS" 
	echo ""

	echo "NASM started..."

fi
;Compile assembly code using NASM
if [ "$BITS" == "True" ]; then

	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


elif [ "$BITS" == "False" ]; then

	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""

fi
;Display progress if in verbose mode
if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
fi
;Display progress if in verbose mode
if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
fi
;Link the compiled code using ld
if [ "$BITS" == "True" ]; then

	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

;Link the compiled code using ld
elif [ "$BITS" == "False" ]; then

	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

fi

;Display progress if in verbose mode
if [ "$VERBOSE" == "True" ]; then

	echo "Linking finished"

fi
;Run the program in QEMU if QEMU flag is enabled
if [ "$QEMU" == "True" ]; then

	echo "Starting QEMU ..."
	echo ""

	if [ "$BITS" == "True" ]; then
	
		qemu-x86_64 $OUTPUT_FILE && echo ""

	elif [ "$BITS" == "False" ]; then

		qemu-i386 $OUTPUT_FILE && echo ""

	fi

	exit 0
	
fi
;RUn GDB flag is enabled
if [ "$GDB" == "True" ]; then

	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi
