! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.registers kernel math ;
IN: compiler.cfg.stacks.height

: record-stack-heights ( ds-height rs-height bb -- )
    [ rs-height<< ] keep ds-height<< ;

GENERIC# untranslate-loc 1 ( loc bb -- loc' )

M: ds-loc untranslate-loc ( loc bb -- loc' )
    [ n>> ] [ ds-height>> ] bi* + <ds-loc> ;
M: rs-loc untranslate-loc ( loc bb -- loc' )
    [ n>> ] [ rs-height>> ] bi* + <rs-loc> ;
