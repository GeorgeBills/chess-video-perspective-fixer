# Chess Video Perspective Fixer™

The Chess Video Perspective Fixer™ takes a video with a 2D chessboard at fixed
pixel co-ordinates and flips the board such that if it was shown from white's
perspective it's now shown from black's perspective and vice-versa.

## Why

There's a course on Chessable - [My First Chess Opening Repertoire for
Black][mfcorb] - that's for learning openings for black, but is displayed from
white's perspective. This is annoying, and I thought it would be a solvable
problem with ffmpeg. Clearly I enjoy shaving yaks.

[mfcorb]: https://www.chessable.com/my-first-chess-opening-repertoire-for-black/course/9014/

## How

```
docker build . -t ffmpeg
docker run --rm -v ${pwd}/data:/var/data ffmpeg /var/data/seg-25-v1-a1.ts /var/data/output.mp4
```

Or just run `ffmpeg.sh` directly if you're on Linux with ffmpeg installed.

You'll need to update the `BOARD_X`, `BOARD_Y`, `BOARD_WIDTH` and `BOARD_HEIGHT`
variables to match the pixels for the chess board displayed 

## What

The original:

![Original](original.png "Original")

Crop out and then flip the board, both vertically (to put black on the bottom)
and horizontally (to put the H file on the left).

![Board cropped and flipped](board-cropped-flipped.png "Board cropped and flipped")

Since we've flipped the board, we've also flipped all of the individual pieces.
We reflip each piece so it's right-side up. We could just do this by rank
instead of by square, except for the coordinate notation (a - h, 1 - 8) visible in
the top right of some of the individual squares.

![E8 cropped and flipped](e8-cropped-flipped.png "E8 cropped and flipped")

Then we overlay flipped pieces back on top of the original image.

Here's the result with just E8 overlayed.

![E8 overlayed on top of the board](e8-overlayed.png "E8 overlayed on top of the board")

Here's the result with all squares overlayed.

Sadly the demonstration arrows are mangled. I don't think this is a solvable
problem with this approach. 

The squares are all slightly off, because the `BOARD_X`, `BOARD_Y`,
`BOARD_WIDTH` and `BOARD_HEIGHT` variables are slightly off and I can't be
bothered manually tweaking for hours to get them right. There might also be
issues to do with bash doing integer rounding, and pixels not quite dividing
evenly by the board width and/or height.

![Final result](final.png "Final result")