! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
PROVIDE: libs/xml
{ +files+ {
    "char-class.factor"
    "data.factor"
    "errors.factor"
    "state-parser.factor"
    "tokenize.factor"
    "writer.factor"
    "utilities.factor"
    "presentation.factor"
    "xml.facts"
} }
{ +tests+ {
    "test/test.factor"
    "test/arithmetic.factor"
    "test/soap.factor"
    "test/templating.factor"
} }
{ +help+ { "xml" "intro" } } ;
