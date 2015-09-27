! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: peg.javascript

HELP: parse-javascript
{ $values
  { "string" string }
  { "ast" "a JavaScript abstract syntax tree" }
}
{ $description
    "Parse the input string using the JavaScript parser. Throws an error if "
    "the string does not contain valid JavaScript. Returns the abstract syntax tree "
    "if successful." } ;
