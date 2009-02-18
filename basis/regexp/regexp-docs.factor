! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings help.markup help.syntax ;
IN: regexp

HELP: <regexp>
{ $values { "string" string } { "regexp" regexp } }
{ $description "Compiles a regular expression into a DFA and returns this object.  Regular expressions only have to be compiled once and can then be used multiple times to match input strings." } ;
