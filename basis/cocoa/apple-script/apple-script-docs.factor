USING: help.markup help.syntax strings ;
IN: cocoa.apple-script

HELP: quote-apple-script
{ $values { "str" string } { "str'" string } }
{ $description "Escape special characters in a string to make it suitable as a literal string in AppleScript code." } ;

HELP: run-apple-script
{ $values { "str" string } }
{ $description "Runs the provided uncompiled AppleScript code." }
{ $notes "Currently, return values are unsupported." } ;

HELP: APPLESCRIPT:
{ $syntax "APPLESCRIPT: word [[ ...applescript string... ]] " }
{ $values { "word" "a new word to define" } { "...applescript string..." "AppleScript source text" } }
{ $description "Defines a word that when called will run the provided uncompiled AppleScript. The word has stack effect " { $snippet "( -- )" } " due to return values being currently unsupported." } ;
