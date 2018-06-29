USING: help.markup help.syntax strings ;
IN: cocoa.apple-script

HELP: quote-apple-script 
{ $values { "str" string } }
{ $description { "Escape special characters in a string to make it suitable as a literal string in AppleScript code." }
{ $notes "Because this word is a port from Barney Gale's Elevate.py ("{ $vocab-link elevate }"), the only characters escaped are keys in " { $link apple-script-charmap } "; other special characters are unchanged." } ;

HELP: run-apple-script
{ $values { "str" string } }
{ $description "Runs the provided uncompiled AppleScript code." }
{ $notes "Currently, return values are unsupported." } ;

HELP: APPLESCRIPT:
{ $syntax "APPLESCRIPT: word [[ ...applescript string... ]] " }
{ $values { "word" "a new word to define" } { "...applescript string..." "AppleScript source text" } }
{ $description "Defines a word that when called will run the provided uncompiled AppleScript. The word has stack effect " { $snippet "( -- )" } " due to return values being currently unsupported." } ;
