! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.parser prettyprint
sequences summary ;
IN: alien.debugger

M: no-c-type summary name>> unparse "“" "” is not a C type" surround ;

M: *-in-c-type-name summary
    name>> "Cannot define a C type “" "” that ends with an asterisk (*)" surround ;
