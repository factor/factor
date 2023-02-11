! Copyright (C) 2004, 2011 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: fry accessors alien alien.accessors alien.private arrays
byte-arrays classes continuations.private effects generic
hashtables hashtables.private io io.backend io.files
io.files.private io.streams.c kernel kernel.private math
math.private math.parser.private memory memory.private
namespaces namespaces.private parser quotations
quotations.private sbufs sbufs.private sequences
sequences.private slots.private strings strings.private system
threads.private classes.tuple classes.tuple.private vectors
vectors.private words words.private definitions assocs summary
compiler.units system.private combinators tools.memory.private
combinators.short-circuit locals locals.backend locals.types
combinators.private stack-checker.values generic.single
generic.single.private alien.libraries tools.dispatch.private
macros tools.profiler.sampling.private classes.algebra
stack-checker.alien
stack-checker.state
stack-checker.errors
stack-checker.visitor
stack-checker.backend
stack-checker.branches
stack-checker.transforms
stack-checker.dependencies
stack-checker.recursive-state
stack-checker.row-polymorphism ;
QUALIFIED-WITH: generic.single.private gsp
IN: stack-checker.known-words

: infer-special ( word -- )
    [ current-word set ] [ "special" word-prop call( -- ) ] bi ;

: infer-shuffle ( shuffle -- )
    [ in>> length consume-d ] keep ! inputs shuffle
    [ drop ] [ shuffle dup copy-values dup output-d ] 2bi ! inputs outputs copies
    [ nip f f ] [ swap zip ] 2bi ! in-d out-d in-r out-r mapping
    #shuffle, ;

: infer-shuffle-word ( word -- )
    "shuffle" word-prop infer-shuffle ;

: infer-local-reader ( word -- )
    ( -- value ) apply-word/effect ;

: infer-local-writer ( word -- )
    ( value -- ) apply-word/effect ;

: non-inline-word ( word -- )
    dup +effect+ depends-on
    {
        { [ dup "shuffle" word-prop ] [ infer-shuffle-word ] }
        { [ dup "special" word-prop ] [ infer-special ] }
        { [ dup "transform-quot" word-prop ] [ apply-transform ] }
        { [ dup macro? ] [ apply-macro ] }
        { [ dup local? ] [ infer-local-reader ] }
        { [ dup local-reader? ] [ infer-local-reader ] }
        { [ dup local-writer? ] [ infer-local-writer ] }
        { [ dup "no-compile" word-prop ] [ do-not-compile ] }
        [ dup required-stack-effect apply-word/effect ]
    } cond ;

{
    { drop  ( x         --                 ) }
    { 2drop ( x y       --                 ) }
    { 3drop ( x y z     --                 ) }
    { 4drop ( w x y z   --                 ) }
    { dup   ( x         -- x x             ) }
    { 2dup  ( x y       -- x y x y         ) }
    { 3dup  ( x y z     -- x y z x y z     ) }
    { 4dup  ( w x y z   -- w x y z w x y z ) }
    { rot   ( x y z     -- y z x           ) }
    { -rot  ( x y z     -- z x y           ) }
    { roll  ( w x y z   -- x y z w         ) }
    { -roll ( w x y z   -- z w x y         ) }
    { reach ( w x y z   -- w x y z w       ) }
    { dupd  ( x y       -- x x y           ) }
    { swapd ( x y z     -- y x z           ) }
    { nip   ( x y       -- y               ) }
    { 2nip  ( x y z     -- z               ) }
    { 3nip  ( w x y z   -- z               ) }
    { 4nip  ( v w x y z -- z               ) }
    { nipd  ( x y z     -- y z             ) }
    { 2nipd ( w x y z   -- y z             ) }
    { 3nipd ( v w x y z -- y z             ) }
    { over  ( x y       -- x y x           ) }
    { overd ( x y z     -- x y x z         ) }
    { pick  ( x y z     -- x y z x         ) }
    { pickd ( w x y z   -- w x y w z       ) }
    { swap  ( x y       -- y x             ) }
    { tuck  ( x y       -- y x y           ) }
} [ "shuffle" set-word-prop ] assoc-each

: check-declaration ( declaration -- declaration )
    dup { [ array? ] [ [ classoid? ] all? ] } 1&&
    [ bad-declaration-error ] unless ;

: infer-declare ( -- )
    pop-literal check-declaration
    [ length ensure-d ] keep zip
    #declare, ;

\ declare [ infer-declare ] "special" set-word-prop

! Call
GENERIC: infer-call* ( value known -- )

: (infer-call) ( value -- ) dup known infer-call* ;

: infer-call ( -- ) pop-d (infer-call) ;

\ call [ infer-call ] "special" set-word-prop

\ (call) [ infer-call ] "special" set-word-prop

M: literal-tuple infer-call*
    [ 1array #drop, ] [ infer-literal-quot ] bi* ;

M: curried-effect infer-call*
    swap push-d
    [ uncurry ] infer-quot-here
    [ quot>> known pop-d [ set-known ] keep ]
    [ obj>> known pop-d [ set-known ] keep ] bi
    push-d (infer-call) ;

M: composed-effect infer-call*
    swap push-d
    [ uncompose ] infer-quot-here
    [ quot2>> known pop-d [ set-known ] keep ]
    [ quot1>> known pop-d [ set-known ] keep ] bi
    push-d push-d
    1 infer->r infer-call
    terminated? get [ 1 infer-r> infer-call ] unless ;

M: declared-effect infer-call*
    [ [ known>> infer-call* ] keep ] with-effect-here check-declared-effect ;

M: input-parameter infer-call* \ call unknown-macro-input ;

M: object infer-call* \ call bad-macro-input ;

:: infer-ndip ( word n -- )
    literals get [
        word def>> infer-quot-here
    ] [
        pop n [ infer->r infer-quot-here ] [ infer-r> ] bi
    ] if-empty ;

: infer-dip ( -- ) \ dip 1 infer-ndip ;

\ dip [ infer-dip ] "special" set-word-prop

: infer-2dip ( -- ) \ 2dip 2 infer-ndip ;

\ 2dip [ infer-2dip ] "special" set-word-prop

: infer-3dip ( -- ) \ 3dip 3 infer-ndip ;

\ 3dip [ infer-3dip ] "special" set-word-prop

:: infer-builder ( quot word -- )
    2 consume-d dup first2 quot call make-known
    [ push-d ] [ 1array ] bi word #call, ; inline

: infer-curry ( -- ) [ <curried-effect> ] \ curry infer-builder ;

\ curry [ infer-curry ] "special" set-word-prop

: infer-compose ( -- ) [ <composed-effect> ] \ compose infer-builder ;

\ compose [ infer-compose ] "special" set-word-prop

: infer-execute ( -- )
    pop-literal
    dup word? [
        apply-object
    ] [
        \ execute time-bomb
    ] if ;

\ execute [ infer-execute ] "special" set-word-prop

\ (execute) [ infer-execute ] "special" set-word-prop

: infer-<tuple-boa> ( -- )
    \ <tuple-boa>
    peek-d literal value>> second 1 + "obj" <array> { tuple } <effect>
    apply-word/effect ;

\ <tuple-boa> [ infer-<tuple-boa> ] "special" set-word-prop

: infer-effect-unsafe ( word -- )
    pop-literal
    add-effect-input
    apply-word/effect ;

: infer-execute-effect-unsafe ( -- )
    \ (execute) infer-effect-unsafe ;

\ execute-effect-unsafe [ infer-execute-effect-unsafe ] "special" set-word-prop

: infer-call-effect-unsafe ( -- )
    \ call infer-effect-unsafe ;

\ call-effect-unsafe [ infer-call-effect-unsafe ] "special" set-word-prop

: infer-load-locals ( -- )
    pop-literal
    consume-d dup copy-values dup output-r
    [ [ f f ] dip ] [ swap zip ] 2bi #shuffle, ;

\ load-locals [ infer-load-locals ] "special" set-word-prop

: infer-load-local ( -- )
    1 infer->r ;

\ load-local [ infer-load-local ] "special" set-word-prop

:: infer-get-local ( -- )
    pop-literal 1 swap - :> n
    n consume-r :> in-r
    in-r first copy-value 1array :> out-d
    in-r copy-values :> out-r

    out-d output-d
    out-r output-r
    f out-d in-r out-r
    out-r in-r zip out-d first in-r first 2array suffix
    #shuffle, ;

\ get-local [ infer-get-local ] "special" set-word-prop

: infer-drop-locals ( -- )
    f f pop-literal consume-r f f #shuffle, ;

\ drop-locals [ infer-drop-locals ] "special" set-word-prop

: infer-call-effect ( word -- )
    1 ensure-d first literal value>>
    add-effect-input add-effect-input
    apply-word/effect ;

{ call-effect execute-effect } [
    dup t "no-compile" set-word-prop
    dup '[ _ infer-call-effect ] "special" set-word-prop
] each

\ if [ infer-if ] "special" set-word-prop
\ dispatch [ infer-dispatch ] "special" set-word-prop

\ alien-invoke [ infer-alien-invoke ] "special" set-word-prop
\ alien-indirect [ infer-alien-indirect ] "special" set-word-prop
\ alien-assembly [ infer-alien-assembly ] "special" set-word-prop
\ alien-callback [ infer-alien-callback ] "special" set-word-prop

{
    c-to-factor
    do-primitive
    mega-cache-lookup
    mega-cache-miss
    inline-cache-miss
    inline-cache-miss-tail
    lazy-jit-compile
    set-callstack
    set-datastack
    set-retainstack
    unwind-native-frames
} [ dup '[ _ do-not-compile ] "special" set-word-prop ] each

{
    declare call (call) dip 2dip 3dip curry compose
    execute (execute) call-effect-unsafe execute-effect-unsafe
    if dispatch <tuple-boa> do-primitive
    load-local load-locals get-local drop-locals
    alien-invoke alien-indirect alien-callback alien-assembly
} [ t "no-compile" set-word-prop ] each

! Exceptions to the above
\ curry f "no-compile" set-word-prop
\ compose f "no-compile" set-word-prop

! More words not to compile
\ clear t "no-compile" set-word-prop
