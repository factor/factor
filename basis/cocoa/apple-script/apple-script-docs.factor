USING: help.markup help.syntax strings ;

IN: cocoa.apple-script

HELP: run-apple-script
{ $values { "str" string } }
{ $description "Runs the provided uncompiled AppleScript code." }
{ $notes "Currently, return values are unsupported." } ;

HELP: APPLESCRIPT:
{ $syntax "APPLESCRIPT: word ...applescript... ;APPLESCRIPT" }
{ $values { "word" "a word" } { "...applescript..." "AppleScript source text" } }
{ $description "Defines a word that when called will run the provided uncompiled AppleScript.  The word has stack effect " { $snippet "( -- )" } " due to return values being currently unsupported." } ;
