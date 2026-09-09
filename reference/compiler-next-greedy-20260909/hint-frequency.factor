! Diagnostic overlay for the c1f7e4d34c greedy hint implementation.
! Load into the prepared benchmark image, then invoke run-hint-frequency
! after this file's compilation unit finishes. Do not time this overlay.
USING: accessors allocator-runtime-comparison assocs compiler.units
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges
io json kernel locals math namespaces sequences sorting ;
IN: compiler-next-greedy-frequency

SYMBOL: hint-frequency

: count-hint-event ( name -- )
    hint-frequency get [ inc-at ] [ drop ] if* ;

:: record-score-map ( scores -- )
    "score-map-builds" count-hint-event
    scores assoc-empty? [ "empty-score-maps" count-hint-event ] when ;

:: record-register-sort ( scores registers -- )
    "register-sorts" count-hint-event
    scores assoc-empty? [
        "empty-register-sorts" count-hint-event
        hint-frequency get [| counts |
            registers length "unneeded-sort-registers" counts at 0 or +
            "unneeded-sort-registers" counts set-at
        ] when*
    ] when ;

IN: compiler.cfg.register-allocation.greedy
USE: compiler-next-greedy-frequency

:: hint-scores ( interval -- scores )
    H{ } clone :> scores
    interval interval-progress hint>> [ 1 swap scores set-at ] when*
    interval vreg>> greedy-copy-hints get at [| hint |
        hint second interval ranges>> ranges-cover? [
            hint first greedy-vreg-unions get at [| peer |
                hint second peer ranges>> ranges-cover? [
                    hint third peer reg>> scores at 0 or +
                    peer reg>> scores set-at
                ] when
            ] each
        ] when
    ] each
    scores record-score-map scores ;

:: hint-score ( interval reg -- score )
    "single-register-queries" count-hint-event
    reg interval hint-scores at 0 or ;

:: allocation-order ( interval -- registers )
    interval hint-scores :> scores
    interval interval-reg-class greedy-registers get at :> registers
    scores registers record-register-sort
    registers [ scores at 0 or neg ] sort-by ;

IN: compiler-next-greedy-frequency

: run-hint-frequency ( -- )
    H{ } clone hint-frequency set
    greedy-allocator register-allocator [
        benchmark-words get-global compile
    ] with-variable
    hint-frequency get clone
    benchmark-words get-global length "selected-words" pick set-at
    >json print
    f hint-frequency set ;
