! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.registers fry kernel math
namespaces ;
IN: compiler.cfg.stacks.height

SYMBOLS: ds-heights rs-heights ;

: record-stack-heights ( ds-height rs-height bb -- )
    [ ds-heights get set-at ] [ rs-heights get set-at ] bi-curry bi* ;

GENERIC# untranslate-loc 1 ( loc bb -- loc' )

M: ds-loc untranslate-loc [ n>> ] [ ds-heights get at ] bi* + <ds-loc> ;
M: rs-loc untranslate-loc [ n>> ] [ rs-heights get at ] bi* + <rs-loc> ;
