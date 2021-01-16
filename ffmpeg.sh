#!/bin/bash

IN_FILE=$1
OUT_FILE=$2

# crop    http://ffmpeg.org/ffmpeg-filters.html#crop
# vflip   http://ffmpeg.org/ffmpeg-filters.html#vflip
# split   http://ffmpeg.org/ffmpeg-filters.html#split_002c-asplit
# overlay http://ffmpeg.org/ffmpeg-filters.html#overlay-1

# split video into two copies, one for the presenters and one for the board
FILTER+="split [presenters][board]"

# crop out the board
# will need to update x, y, width and height based on source video
# for the .ts (960x540) the values are roughly X=420, Y=20, W=H=540
BOARD_X=425
BOARD_Y=10
BOARD_WIDTH=530
BOARD_HEIGHT=525
FILTER+="; [board] crop=w=${BOARD_WIDTH}:h=${BOARD_HEIGHT}:x=${BOARD_X}:y=${BOARD_Y}, vflip, hflip [board_flipped]"

# utility func to get a "pretty" name for each square
RANK_LETTERS=({A..H})
sq_name () {
    echo "${RANK_LETTERS[$1]}$(($2 + 1))"
}

# split the flipped board section into a subsection for each square
FILTER+="; [board_flipped] split=64"
for RANK in {0..7}; do
    for FILE in {0..7}; do
        SQ_NAME=$(sq_name $RANK $FILE)
        FILTER+=" [$SQ_NAME]"
    done
done

SQ_WIDTH=$(($BOARD_WIDTH / 8))
SQ_HEIGHT=$(($BOARD_HEIGHT / 8))

# crop each square
# vertically flip all squares to fix the pieces being upside down
for RANK in {0..7}; do
    for FILE in {0..7}; do
        # this x and y is relative to the board
        SQ_X=$(($FILE * $SQ_WIDTH))
        SQ_Y=$(($RANK * $SQ_HEIGHT))

        SQ_NAME=$(sq_name $RANK $FILE)
        
        FILTER+="; [$SQ_NAME] crop=w=${SQ_WIDTH}:h=${SQ_HEIGHT}:x=${SQ_X}:y=${SQ_Y}, vflip, hflip [${SQ_NAME}_flipped]"
    done
done

# overlay all sections back into one video
OVERLAY_ON="presenters"
for RANK in {0..7}; do
    for FILE in {0..7}; do
        # this x and y is absolute, so we need to add the board x and y
        SQ_X=$(($BOARD_X + $FILE * $SQ_WIDTH))
        SQ_Y=$(($BOARD_Y + $RANK * $SQ_HEIGHT))
        
        SQ_NAME=$(sq_name $RANK $FILE)
        
        OVERLAY_OUT="${SQ_NAME}_overlayed"
        FILTER+="; [$OVERLAY_ON][${SQ_NAME}_flipped] overlay=x=${SQ_X}:y=${SQ_Y} [${OVERLAY_OUT}]"

        # each iteration we overlay on to the previous iteration
        OVERLAY_ON=$OVERLAY_OUT
    done
done

# send through the final overlayed output
FILTER+="; [$OVERLAY_ON] copy"

echo $FILTER

ffmpeg \
    -i $IN_FILE \
    -loglevel error \
    -nostats \
    -vcodec mpeg4 \
    -acodec copy \
    -y \
    -filter_complex "${FILTER}" \
    $OUT_FILE
