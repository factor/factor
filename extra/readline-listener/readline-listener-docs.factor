! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ui.theme.switching ;
IN: readline-listener

HELP: readline-listener
{ $description "Invokes a listener that uses libreadline for editing, history and word completion." } ;

ARTICLE: "readline-listener" "Readline listener"
{ $vocab-link "readline-listener" }
$nl
"By default, the terminal listener does not provide any command history or completion. This vocabulary uses libreadline to provide a listener with history, word completion and more convenient editing facilities. History is stored in the file named by $FACTOR_HISTORY, or ~/.factor-history if that isn't set."
$nl
"If the terminal supports 16-colour or 256-colour modes, and " { $snippet "$NO_COLOR" } " isn't set, it will automatically enable coloured and styled output as well. Unlike the GUI listener, it defaults to a light-on-dark theme; if you use a dark-on-light terminal, you may want to add " { $link light-mode } " to your " { $snippet "~/.factor-rc" } "."
$nl
"The vocabulary defines an entry point, so you can either invoke " { $link readline-listener } " directly, or run the vocabulary using " { $snippet "\"readline-listener\" run" } " or, from the command line, " { $snippet "factor -run=readline-listener" } "."
;

ABOUT: "readline-listener"
