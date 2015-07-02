! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors eval kernel lexer nested-comments tools.test ;
IN: nested-comments.tests

! Correct
[ ] [
    "USE: nested-comments (* comment *)" eval( -- )
] unit-test

[ ] [
    "USE: nested-comments (* comment*)" eval( -- )
] unit-test

[ ] [
    "USE: nested-comments (* comment
*)" eval( -- )
] unit-test

[ ] [
    "USE: nested-comments (* comment
*)" eval( -- )
] unit-test

[ ] [
    "USE: nested-comments (* comment
*)" eval( -- )
] unit-test

[ ] [
    "USE: nested-comments (* comment
    (* *)

*)" eval( -- )
] unit-test

! Malformed
[
    "USE: nested-comments (* comment
    (* *)" eval( -- )
] [
    error>> T{ unexpected f "*)" f } =
] must-fail-with
