USING: accessors combinators.short-circuit compiler.units kernel
locals math random sequences tools.memory tools.test vocabs words ;
IN: compiler.tests.code-heap

! This is a test for filling up the code heap.
!
! We take 100 random words and continuously run modify-code-heap with
! them until the code heap fills up, prompting a compaction of it from
! allot_code_block() in code_blocks.cpp. Then compaction must work
! despite there being a number of uninitialized code blocks in the
! heap. See #1715.
: special-word? ( word -- ? )
    {
        [ "macro" word-prop ]
        [ "no-compile" word-prop ]
        [ "special" word-prop ]
        [ "custom-inlining" word-prop ]
    } 1|| ;

: normal-words ( -- words )
    all-words [ special-word? ] reject ;

: random-compilation-data ( -- compiled-data )
    [
        normal-words 50 sample recompile
    ] with-compilation-unit ;

: heap-free ( -- n )
    code-room total-free>> ;

:: (trash-code-heap) ( data last-free -- )
    data f f modify-code-heap heap-free :> new-free
    last-free new-free > [ data new-free (trash-code-heap) ] when ;

: trash-code-heap ( -- )
    random-compilation-data heap-free (trash-code-heap) ;

{ } [
    trash-code-heap
] unit-test
