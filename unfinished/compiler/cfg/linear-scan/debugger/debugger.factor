! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences sets arrays
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation ;
IN: compiler.cfg.linear-scan.debugger

: check-assigned ( live-intervals -- )
    [
        reg>>
        [ "Not all intervals have registers" throw ] unless
    ] each ;

: check-split ( live-intervals -- )
    [
        split-before>>
        [ "Split intervals returned" throw ] when
    ] each ;

: split-children ( live-interval -- seq )
    dup split-before>> [
        [ split-before>> ] [ split-after>> ] bi
        [ split-children ] bi@
        append
    ] [
        1array
    ] if ;

: check-retired ( original live-intervals -- )
    #! All original live intervals should have either been
    #! split, or ended up in the output set.
    [ [ split-children ] map concat ] dip
    2dup subset? [ "We lost some intervals" throw ] unless
    swap subset? [ "We didn't record all splits" throw ] unless ;

: check-linear-scan ( live-intervals machine-registers -- )
    [ [ clone ] map dup ] dip allocate-registers
    [ check-assigned ] [ check-split ] [ check-retired ] tri ;
