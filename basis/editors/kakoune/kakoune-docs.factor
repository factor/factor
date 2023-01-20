! Copyright (C) 2022 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax editors ;
IN: editors.kakoune

HELP: actual-kak-path
{ $values
    { "path" "a pathname string" }
}
{ $description "Pushes the path to kakoune recognized by factor." } ;

HELP: find-kak-path
{ $values
    { "path" "a pathname string" }
}
{ $description "A word which finds kakoune in your unix system's PATH variable." } ;

HELP: kak-path
{ $var-description "Set this variable to a sequence of strings that indicate the command to be run when factor wants to invoke kakoune. For example, on the author's system, this is " { $snippet "{ \"alacritty\" \"-e\" \"kak\" }" } } ;

HELP: kakoune
{ $class-description "The editor class for kakoune. To switch to kakoune as your primary editor, you can set " { $link editor-class } " to this singleton class." } ;

ARTICLE: "editors.kakoune" "Kakoune support"
"The " { $link kak-path } " variable contains the name of the kak executable. The default " { $link kak-path } " is " { $snippet "\"kak\"" } ". Which is not very useful, as it starts kakoune in the same terminal where you started factor."
$nl
"You can install an editor plugin for kakoune at " { $url "https://github.com/razetime/kakoune-factor" }
;

ABOUT: "editors.kakoune"
