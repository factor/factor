! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: readline-listener

HELP: readline-listener
{ $description "Invokes a listener that uses libreadline for editing, history and word completion." } ;

ARTICLE: "readline-listener" "Readline listener"
{ $vocab-link "readline-listener" }
$nl
"By default, the terminal listener does not provide any command history or completion. This vocabulary uses libreadline to provide a listener with history, word completion and more convenient editing facilities. History is stored in the file named by $FACTOR_HISTORY, or ~/.factor-history if that isn't set."
$nl
{ $code "\"readline-listener\" run" }
;

ABOUT: "readline-listener"
