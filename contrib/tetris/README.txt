This is a simple tetris game. To play, open factor (in GUI mode), and run:

"contrib/tetris" require
USING: tetris-gadget tetris ;
tetris-window

This should open a new window with a running tetris game. The commands are:

left, right arrows: move the current piece left or right
up arrow:           rotate the piece clockwise
down arrow:         lower the piece one row
space bar:          drop the piece
p:                  pause/unpause
n:                  start a new game
q:                  quit (currently just stops updating, see TODO)

Running tetris-window will leave a tetris-gadget on your stack. To get your
current score you can do:

tetris-gadget-tetris tetris-score

TODO:
- close the window on quit
- rotation of pieces when they're on the far right of the board
- show the score and level, maybe floating about the screen somewhere
- make blocks prettier
