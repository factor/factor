USING: kernel sequences slots parser words classes
slots.private mirrors ;
IN: tuple-syntax

! TUPLE: foo bar baz ;
! TUPLE{ foo bar: 1 baz: 2 }

: parse-slot-writer ( tuple -- slot# )
    scan dup "}" = [ 2drop f ] [
        1 head* swap object-slots slot-named slot-spec-offset
    ] if ;

: parse-slots ( accum tuple -- accum tuple )
    dup parse-slot-writer
    [ scan-object pick rot set-slot parse-slots ] when* ;

: TUPLE{
    scan-word new parse-slots parsed ; parsing
