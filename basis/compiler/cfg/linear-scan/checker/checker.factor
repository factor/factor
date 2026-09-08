! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges kernel locals math sequences sorting ;
IN: compiler.cfg.linear-scan.checker

ERROR: invalid-allocated-ranges interval ;
ERROR: invalid-allocated-register interval ;
ERROR: uncovered-allocated-use interval use ;
ERROR: overlapping-allocated-ranges first-interval second-interval ;

:: check-interval ( interval registers -- )
    interval ranges>> valid-ranges?
    [ interval invalid-allocated-ranges ] unless
    interval reg>> interval interval-reg-class registers at member?
    [ interval invalid-allocated-register ] unless
    interval uses>> [| use |
        use n>> interval ranges>> ranges-cover?
        [ interval use uncovered-allocated-use ] unless
    ] each ;

:: check-register-ranges ( intervals -- )
    intervals [| interval |
        interval ranges>> [ interval suffix ] map
    ] map concat [ first ] sort-by :> ranges
    f :> previous!
    ranges [| range |
        previous [
            range first previous second <= [
                previous third range third overlapping-allocated-ranges
            ] when
        ] when
        range previous!
    ] each ;

:: check-allocated-intervals ( intervals registers -- )
    H{ } clone :> groups
    intervals [| interval |
        interval registers check-interval
        interval interval interval-reg-class interval reg>> 2array groups push-at
    ] each
    groups values [ check-register-ranges ] each ;
