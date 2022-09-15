! File: strings.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Words for trimming and tabbing
! Copyright (C) 2014 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: ascii kernel regexp sequences splitting strings
tools.continuations ;

IN: sequences.strings

: leavemein ( -- ) break ;

: tab>space ( s -- s )
    "\t " split  ""  swap
    [
        [ SBUF" " = ] keep
        swap
        [ drop ]
        [ " " append append ]
        if
    ] each
    chop ;

: squeeze-lines ( s -- s )
    [ SBUF" " = not ] filter ;

: detab-lines ( s -- s )
    [ tab>space ] map ;
        
:: only-regexp ( seq regexp -- seq )
    seq [ regexp matches? ] filter
    ;

:: remove-regexp ( seq regexp -- seq )
    seq [ regexp matches? not ] filter
    ;
: squeeze-spaces ( seq -- seq )   [ " " split  [ "" = not ] filter  " " join ] map ;
: trim-leading ( seq -- seq )   [ [ blank? ] trim-head ] map ;
: trim-trailing ( seq -- seq )   [ [ blank? ] trim-tail ] map ;
: trim-ends ( seq -- seq )   [ [ blank? ] trim ] map ;
