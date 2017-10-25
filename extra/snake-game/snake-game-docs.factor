USING: help.markup help.syntax ;
IN: snake-game

ARTICLE: "snake-game" "Snake Game"
"A remake of the popular Snake game. To start the game:"
{ $code "play-snake-game" }
{ $heading "Keys" }
{ $table
  { "Pause/Resume game" "SPACE, P" }
  { "Start a new game" "ENTER, N" }
  { "Quit and close game window" "ESCAPE, Q" }
  { "Snake movement control" "Arrow Keys" }
}
{ $notes
  "Art used from Code Project: "
  { $url "http://www.codeproject.com/Articles/420088/Snake-game-for-tablets-and-Smartphones" }
  " Art credits: Erich Duda, BSD license: "
  { $url "http://opensource.org/licenses/bsd-license.php" }
} ;

HELP: play-snake-game
{ $description "Starts the game!" } ;

ABOUT: "snake-game"
