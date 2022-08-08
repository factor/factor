USING: alien generalizations io io.ports kernel math sequences
sequences.private tools.annotations ;
IN: tools.annotations.assertions

ERROR: invalid-nth-unsafe n seq word ;

: check-nth-unsafe ( n seq word -- n seq )
    2over length >= [ invalid-nth-unsafe ] [ drop ] if ; inline

: (assert-nth-unsafe) ( word -- )
    dup [ swap '[ _ check-nth-unsafe @ ] ] curry annotate ;

: assert-nth-unsafe ( -- )
    \ nth-unsafe (assert-nth-unsafe)
    \ set-nth-unsafe (assert-nth-unsafe) ;

: reset-nth-unsafe ( -- )
    \ nth-unsafe reset
    \ set-nth-unsafe reset ;

ERROR: invalid-stream-read-unsafe len buf port word ;
ERROR: invalid-stream-read-unsafe-return out-len in-len buf port word ;

:: check-stream-read-unsafe-before ( n buf stream word -- n buf stream )
    buf alien? [ n buf port ] [
        n buf byte-length >
        [ n buf stream word invalid-stream-read-unsafe ]
        [ n buf stream ] if
    ] if ; inline

:: check-stream-read-unsafe-after ( count n buf stream word -- count )
    count n >
    [ count n buf stream word invalid-stream-read-unsafe-return ]
    [ count ] if ;

: (assert-stream-read-unsafe) ( word -- )
    dup [ swap '[ _
        [ check-stream-read-unsafe-before @ ]
        [ check-stream-read-unsafe-after ] 4 nbi
    ] ] curry annotate ;

: assert-stream-read-unsafe ( -- )
    \ stream-read-unsafe (assert-stream-read-unsafe)
    \ stream-read-partial-unsafe (assert-stream-read-unsafe) ;

: reset-stream-read-unsafe ( -- )
    \ stream-read-unsafe reset
    \ stream-read-partial-unsafe reset ;
