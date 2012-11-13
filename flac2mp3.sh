#!/bin/bash

# Execute getopt on the arguments passed to this program, identified by the special character $@
#mac OS X => use brew gnu-getopt, bash
#getopt='/usr/local/Cellar/gnu-getopt/1.1.4/bin/getopt'

PARSED_OPTIONS=$(getopt -n "$0" -o hdp:s:b:n --long "help,delete,path:,samplerate:,bitrate:,dry-run"  -- "$@")

# Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ]; then echo "Terminating..."; >&2; exit 1; fi

# defaults
DELETE=false
FLAC_DIR=.
SAMPLERATE='44100'
BITRATE='192k'
DRYRUN=false


usage()
{
	echo "
usage: $0 options

This script will convert all the flac found in the path given.
Default mp3 settings are 192Kbps VBR 44.1KHz

OPTIONS:
	-h, --help         Show this message
	-d, --delete       Delete after sucesful encoding (default to keep)
	-p, --path         Path to files (default to current directory)
	-s, --samplerate   Sampling rate (default to 44100KHz)
	-b, --bitrate      Bitrate (default to 192Kbps)
	-n, --dry-run      Don't do nothing, just show what would be done
"
}


# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

while true ; do
        case "$1" in
                -h|--help) usage; exit 1 ; shift ;;
                -d|--delete) DELETE=true ; shift ;;
                -p|--path) FLAC_DIR="$2" ; shift 2;;
                -s|--samplerate) SAMPLERATE="$2" ; shift 2 ;;
                -b|--bitrate) BITRATE="$2" ; shift 2 ;;
				-n|--dry-run) DRYRUN=true ; shift ;;

                --) shift ; break ;;
                *) echo "Internal error!" ; exit 1 ;;
        esac
done

IFS=
while read -r flac; do 

	TRACK=`basename "$flac" .flac`;
	DIR=`dirname "$flac"`;
	``
	if [ $DRYRUN == true ]
	then
		echo ffmpeg -i "$flac" -ac 2 -ab "$BITRATE" -ar "$SAMPLERATE" "$DIR/$TRACK.mp3"; 
	else
		ffmpeg -i "$flac" -ac 2 -ab "$BITRATE" -ar "$SAMPLERATE" "$DIR/$TRACK.mp3";
	fi

	# only delete if everythings ok
	if [ $DELETE == true -a $? == 0 ]
	then
		if [ $DRYRUN == true ]
		then
			echo rm "$flac"
		else
			rm "$flac"
		fi
	fi
done < <(find $FLAC_DIR -iname \*flac)