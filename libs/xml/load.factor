! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/memoize libs/state-parser ;
PROVIDE: libs/xml
{ +files+ {
    "char-class.factor"
    "entities.factor"
    "data.factor"
    "writer.factor"
    "errors.factor"
    "utilities.factor"
    "tokenize.factor"
    "presentation.factor"
    "xml.facts"
} }
{ +tests+ {
    "test/test.factor"
    "test/arithmetic.factor"
    "test/soap.factor"
    "test/templating.factor"
    "test/errors.factor"
} }
{ +help+ { "xml" "intro" } } ;
