#!/bin/sh

# Set path to ffmpeg here
FFMPEG=ffmpeg

# Set number of threads
# Uncomment to enable threads (unsafe for xvid)
#THREADS='-threads 2'

# Video codec
VCODEC='-vcodec mpeg4 -vtag xvid'

# Video bitrate
VRATE=999000

# Audio bitrate
ARATE=128k

##
# Probably no need to change anything below this line

VID=$1
SUB=$2
ASS=/tmp/$$.ass
OUT=$3

clean_up()
{
    rm -f $ASS
}

bail_out()
{
    clean_up
    echo "Error: $1"
    exit 1
}

usage()
{
    echo "Usage: $0 <invideo> <subtitles> <outvideo>"
}

if ! test -f "$VID"; then
    usage
    bail_out "could not read videofile $VID"
fi

if ! test -f "$SUB"; then
    usage
    bail_out "could not read subtitlefile $SUB"
fi

if test "$OUT" = ""; then
    OUT='out.avi'
    echo "Warning: no output filename given, using $OUT"
fi

HASASS=`$FFMPEG --version 2>&1 | grep libass`
if test "$HASASS" = ""; then
    bail_out "enable libass support in ffmpeg and try again"
fi

$FFMPEG -v warning -y -i $SUB $ASS || bail_out "could not convert subtitlefile $SUB"
$FFMPEG -v warning -y -i $VID -b:v $VRATE -vf "ass=$ASS" $THREADS  -ab $ARATE -ac 2 $OUT || bail_out "$OUT not completed"
echo "$OUT encoded successfully"
clean_up
