! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax peg ;

HELP: token
{ $values 
  { "string" "a string" } }
{ $description 
    "A parser generator that returns a parser that matches the given string." }
{ $example "\"begin foo end\" \"begin\" token parse" "result-here" } ;

