USING: help.markup help.syntax ;

IN: minesweeper

ARTICLE: "minesweeper" "Minesweeper"
"The game starts with a grid of cells. Some cells contain a mine, others do not. If you click on a cell containing a mine, you " { $strong "lose" } " (it blows up!). If you click on all the cells (without clicking on any mines), you " { $strong "win" } "!"
$nl
"Three levels of difficulty are available:"
$nl
{ $table
    { { $strong "Difficulty" } { $strong "Grid Size" } { $strong "Mines" } }
    { "Easy"   { $snippet "8 x 8" } "10" }
    { "Medium" { $snippet "16 x 16" } "40" }
    { "Hard"   { $snippet "16 x 30" } "99" }
}
$nl
"The upper left corner contains a counter of the number of mines left to find. This number will update as you flag or unflag cells."
$nl
"The upper right corner contains a timer. This timer will count the number of seconds since beginning to play, maxing out at " { $snippet "999" } " (16 minutes and 39 seconds)."
$nl
"Clicking on a cell which doesn't have a mine reveals the number of neighboring cells that contain mines. Use this information (plus good guessing!) to avoid the mines."
$nl
"To open a cell, point at the cell with your mouse and click on it. The first cell you click to open is never a mine."
$nl
"Every cell has up to " { $snippet "8" } " neighbors: the cells adjacent above, below, left, right, and all " { $snippet "4" } " diagonals. The cells on the sides of the board (and its corners) have fewer neighbors."
$nl
"If you open a cell with " { $snippet "0" } " neighboring mines, all of its neighbors will automatically open. This can sometimes be a large area."
$nl
"If you middle-click an opened cell, and the number of adjacent flags match the number of adjacent mines, it will open all of the neighbors. This can improve the speed at which you can complete the game. However, if you have not flagged the adjacent cells correctly, you can lose when this opens the mined cell that was not marked."
$nl
"To flag a cell you think is a mine, point and right-click (or hover with the mouse and press " { $snippet "SPACE" } "). Do this again to mark with a question mark symbol (useful if you are unsure about a cell). Do this again to return the cell to blank."
$nl
"If you flag a mine incorrectly, you will need to correct that mistake before you can win."
$nl
"You do not have to flag all the mines to win, you only need to open all the cells that do not contain mines."
$nl
"Click the yellow smiley face (or the desired difficulty) to start a new game."
;

ABOUT: "minesweeper"
