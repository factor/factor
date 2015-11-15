! Copyright (C) 2004, 2011 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
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
    dup add-depends-on-effect
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
    { drop  ( x       --                 ) }
    { 2drop ( x y     --                 ) }
    { 3drop ( x y z   --                 ) }
    { 4drop ( w x y z --                 ) }
    { dup   ( x       -- x x             ) }
    { 2dup  ( x y     -- x y x y         ) }
    { 3dup  ( x y z   -- x y z x y z     ) }
    { 4dup  ( w x y z -- w x y z w x y z ) }
    { rot   ( x y z   -- y z x           ) }
    { -rot  ( x y z   -- z x y           ) }
    { dupd  ( x y     -- x x y           ) }
    { swapd ( x y z   -- y x z           ) }
    { nip   ( x y     -- y               ) }
    { 2nip  ( x y z   -- z               ) }
    { over  ( x y     -- x y x           ) }
    { pick  ( x y z   -- x y z x         ) }
    { swap  ( x y     -- y x             ) }
} [ "shuffle" set-word-prop ] assoc-each

: check-declaration ( declaration -- declaration )
    dup { [ array? ] [ [ classoid? ] all? ] } 1&&
    [ bad-declaration-error ] unless ;

: infer-declare ( -- )
    pop-literal nip check-declaration
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

M: curried infer-call*
    swap push-d
    [ uncurry ] infer-quot-here
    [ quot>> known pop-d [ set-known ] keep ]
    [ obj>> known pop-d [ set-known ] keep ] bi
    push-d (infer-call) ;

M: composed infer-call*
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

: infer-ndip ( word n -- )
    [ literals get ] 2dip
    [ '[ _ def>> infer-quot-here ] ]
    [ '[ _ [ pop ] dip [ infer->r infer-quot-here ] [ infer-r> ] bi ] ] bi*
    if-empty ;

: infer-dip ( -- ) \ dip 1 infer-ndip ;

\ dip [ infer-dip ] "special" set-word-prop

: infer-2dip ( -- ) \ 2dip 2 infer-ndip ;

\ 2dip [ infer-2dip ] "special" set-word-prop

: infer-3dip ( -- ) \ 3dip 3 infer-ndip ;

\ 3dip [ infer-3dip ] "special" set-word-prop

: infer-builder ( quot word -- )
    [
        [ 2 consume-d ] dip
        [ dup first2 ] dip call make-known
        [ push-d ] [ 1array ] bi
    ] dip #call, ; inline

: infer-curry ( -- ) [ <curried> ] \ curry infer-builder ;

\ curry [ infer-curry ] "special" set-word-prop

: infer-compose ( -- ) [ <composed> ] \ compose infer-builder ;

\ compose [ infer-compose ] "special" set-word-prop

: infer-execute ( -- )
    pop-literal nip
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

\ <tuple-boa> t "flushable" set-word-prop

: infer-effect-unsafe ( word -- )
    pop-literal nip
    add-effect-input
    apply-word/effect ;

: infer-execute-effect-unsafe ( -- )
    \ (execute) infer-effect-unsafe ;

\ execute-effect-unsafe [ infer-execute-effect-unsafe ] "special" set-word-prop

: infer-call-effect-unsafe ( -- )
    \ call infer-effect-unsafe ;

\ call-effect-unsafe [ infer-call-effect-unsafe ] "special" set-word-prop

: infer-load-locals ( -- )
    pop-literal nip
    consume-d dup copy-values dup output-r
    [ [ f f ] dip ] [ swap zip ] 2bi #shuffle, ;

\ load-locals [ infer-load-locals ] "special" set-word-prop

: infer-load-local ( -- )
    1 infer->r ;

\ load-local [ infer-load-local ] "special" set-word-prop

:: infer-get-local ( -- )
    pop-literal nip 1 swap - :> n
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
    f f pop-literal nip consume-r f f #shuffle, ;

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

: define-primitive ( word inputs outputs -- )
    [ "input-classes" set-word-prop ]
    [ "default-output-classes" set-word-prop ]
    bi-curry* bi ;

: define-primitives ( seq -- )
    [ first3 define-primitive ] each ;

: make-flushable-primitives ( flushables -- )
    dup define-primitives [ first make-flushable ] each ;

: make-foldable-primitives ( flushables -- )
    dup define-primitives [ first make-foldable ] each ;

! ! Stack effects for all primitives

! Alien getters
{
    { alien-cell { c-ptr integer } { pinned-c-ptr } }
    { alien-double { c-ptr integer } { float } }
    { alien-float { c-ptr integer } { float } }
    { alien-signed-1 { c-ptr integer } { fixnum } }
    { alien-signed-2 { c-ptr integer } { fixnum } }
    { alien-signed-4 { c-ptr integer } { integer } }
    { alien-signed-8 { c-ptr integer } { integer } }
    { alien-signed-cell { c-ptr integer } { integer } }
    { alien-unsigned-1 { c-ptr integer } { fixnum } }
    { alien-unsigned-2 { c-ptr integer } { fixnum } }
    { alien-unsigned-4 { c-ptr integer } { integer } }
    { alien-unsigned-8 { c-ptr integer } { integer } }
    { alien-unsigned-cell { c-ptr integer } { integer } }
} make-flushable-primitives

! Alien setters
{
    { set-alien-cell { c-ptr c-ptr integer } { } }
    { set-alien-double { float c-ptr integer } { } }
    { set-alien-float { float c-ptr integer } { } }
    { set-alien-signed-1 { integer c-ptr integer } { } }
    { set-alien-signed-2 { integer c-ptr integer } { } }
    { set-alien-signed-4 { integer c-ptr integer } { } }
    { set-alien-signed-8 { integer c-ptr integer } { } }
    { set-alien-signed-cell { integer c-ptr integer } { } }
    { set-alien-unsigned-1 { integer c-ptr integer } { } }
    { set-alien-unsigned-2 { integer c-ptr integer } { } }
    { set-alien-unsigned-4 { integer c-ptr integer } { } }
    { set-alien-unsigned-8 { integer c-ptr integer } { } }
    { set-alien-unsigned-cell { integer c-ptr integer } { } }
} define-primitives

! Container constructors
{
    { (byte-array) { integer } { byte-array } }
    { <array> { integer object } { array } }
    { <byte-array> { integer } { byte-array } }
    { <string> { integer integer } { string } }
    { <tuple> { array } { tuple } }
} make-flushable-primitives

! Misc flushables
{
    { (callback-room) { } { byte-array } }
    { (clone) { object } { object } }
    { (code-blocks) { } { array } }
    { (code-room) { } { byte-array } }
    { (data-room) { } { byte-array } }
    { (word) { object object object } { word } }
    { <displaced-alien> { integer c-ptr } { c-ptr } }
    { alien-address { alien } { integer } }
    { callstack-bounds { } { alien alien } }
    { callstack-for { c-ptr } { callstack } }
    { callstack>array { callstack } { array } }
    { check-datastack { array integer integer } { object } }
    { context-object { fixnum } { object } }
    { context-object-for { fixnum c-ptr } { object } }
    { current-callback { } { fixnum } }
    { datastack-for { c-ptr } { array } }
    { nano-count { } { integer } }
    { quotation-code { quotation } { integer integer } }
    { retainstack-for { c-ptr } { array } }
    { size { object } { fixnum } }
    { slot { object fixnum } { object } }
    { special-object { fixnum } { object } }
    { string-nth-fast { fixnum string } { fixnum } }
    { word-code { word } { integer integer } }
} make-flushable-primitives

! Misc foldables
{
    { <wrapper> { object } { wrapper } }
    { array>quotation { array } { quotation } }
    { eq? { object object } { object } }
    { tag { object } { fixnum } }
} make-foldable-primitives

! Numeric primitives
{
    ! bignum
    { bignum* { bignum bignum } { bignum } }
    { bignum+ { bignum bignum } { bignum } }
    { bignum- { bignum bignum } { bignum } }
    { bignum-bit? { bignum integer } { object } }
    { bignum-bitand { bignum bignum } { bignum } }
    { bignum-bitnot { bignum } { bignum } }
    { bignum-bitor { bignum bignum } { bignum } }
    { bignum-bitxor { bignum bignum } { bignum } }
    { bignum-log2 { bignum } { bignum } }
    { bignum-mod { bignum bignum } { integer } }
    { bignum-gcd { bignum bignum } { bignum } }
    { bignum-shift { bignum fixnum } { bignum } }
    { bignum/i { bignum bignum } { bignum } }
    { bignum/mod { bignum bignum } { bignum integer } }
    { bignum< { bignum bignum } { object } }
    { bignum<= { bignum bignum } { object } }
    { bignum= { bignum bignum } { object } }
    { bignum> { bignum bignum } { object } }
    { bignum>= { bignum bignum } { object } }
    { bignum>fixnum { bignum } { fixnum } }
    { bignum>fixnum-strict { bignum } { fixnum } }

    ! fixnum
    { fixnum* { fixnum fixnum } { integer } }
    { fixnum*fast { fixnum fixnum } { fixnum } }
    { fixnum+ { fixnum fixnum } { integer } }
    { fixnum+fast { fixnum fixnum } { fixnum } }
    { fixnum- { fixnum fixnum } { integer } }
    { fixnum-bitand { fixnum fixnum } { fixnum } }
    { fixnum-bitnot { fixnum } { fixnum } }
    { fixnum-bitor { fixnum fixnum } { fixnum } }
    { fixnum-bitxor { fixnum fixnum } { fixnum } }
    { fixnum-fast { fixnum fixnum } { fixnum } }
    { fixnum-mod { fixnum fixnum } { fixnum } }
    { fixnum-shift { fixnum fixnum } { integer } }
    { fixnum-shift-fast { fixnum fixnum } { fixnum } }
    { fixnum/i { fixnum fixnum } { integer } }
    { fixnum/i-fast { fixnum fixnum } { fixnum } }
    { fixnum/mod { fixnum fixnum } { integer fixnum } }
    { fixnum/mod-fast { fixnum fixnum } { fixnum fixnum } }
    { fixnum< { fixnum fixnum } { object } }
    { fixnum<= { fixnum fixnum } { object } }
    { fixnum> { fixnum fixnum } { object } }
    { fixnum>= { fixnum fixnum } { object } }
    { fixnum>bignum { fixnum } { bignum } }
    { fixnum>float { fixnum } { float } }

    ! float
    { (format-float) { float byte-array } { byte-array } }
    { bits>float { integer } { float } }
    { float* { float float } { float } }
    { float+ { float float } { float } }
    { float- { float float } { float } }
    { float-u< { float float } { object } }
    { float-u<= { float float } { object } }
    { float-u> { float float } { object } }
    { float-u>= { float float } { object } }
    { float/f { float float } { float } }
    { float< { float float } { object } }
    { float<= { float float } { object } }
    { float= { float float } { object } }
    { float> { float float } { object } }
    { float>= { float float } { object } }
    { float>bignum { float } { bignum } }
    { float>bits { real } { integer } }
    { float>fixnum { float } { fixnum } }

    ! double
    { bits>double { integer } { float } }
    { double>bits { real } { integer } }
} make-foldable-primitives

! ! Misc primitives
{
    ! Contexts
    { (set-context) { object alien } { object } }
    { (set-context-and-delete) { object alien } { } }
    { (sleep) { integer } { } }
    { (start-context) { object quotation } { object } }
    { (start-context-and-delete) { object quotation } { } }
    { set-context-object { object fixnum } { } }

    ! Dispatch stats
    { dispatch-stats { } { byte-array } }
    { reset-dispatch-stats { } { } }

    ! FFI
    { (dlopen) { byte-array } { dll } }
    { (dlsym) { byte-array object } { c-ptr } }
    { (dlsym-raw) { byte-array object } { c-ptr } }
    { dlclose { dll } { } }
    { dll-valid? { object } { object } }

    ! GC
    { compact-gc { } { } }
    { disable-gc-events { } { object } }
    { enable-gc-events { } { } }
    { gc { } { } }
    { minor-gc { } { } }

    ! Hashing
    { (identity-hashcode) { object } { fixnum } }
    { compute-identity-hashcode { object } { } }

    ! IO
    { (exists?) { string } { object } }
    { (fopen) { byte-array byte-array } { alien } }
    { fclose { alien } { } }
    { fflush { alien } { } }
    { fgetc { alien } { object } }
    { fputc { object alien } { } }
    { fread-unsafe { integer c-ptr alien } { integer } }
    { fseek { integer integer alien } { } }
    { ftell { alien } { integer } }
    { fwrite { c-ptr integer alien } { } }

    ! Profiling
    { (clear-samples) { } { } }
    { (get-samples) { } { object } }
    { profiling { object } { } }

    ! Resizing
    { resize-array { integer array } { array } }
    { resize-byte-array { integer byte-array } { byte-array } }
    { resize-string { integer string } { string } }

    ! Other primitives
    { (exit) { integer } { } }
    { (save-image) { byte-array byte-array object } { } }
    { <callback> { word integer } { alien } }
    { all-instances { } { array } }
    { become { array array } { } }
    { both-fixnums? { object object } { object } }
    { die { } { } }
    { fpu-state { } { } }
    { free-callback { alien } { } }
    { innermost-frame-executing { callstack } { object } }
    { innermost-frame-scan { callstack } { fixnum } }
    { jit-compile { quotation } { } }
    { leaf-signal-handler { } { } }
    { gsp:lookup-method { object array } { word } }
    { modify-code-heap { array object object } { } }
    { quotation-compiled? { quotation } { object } }
    { set-fpu-state { } { } }
    { set-innermost-frame-quotation { quotation callstack } { } }
    { set-slot { object object fixnum } { } }
    { set-special-object { object fixnum } { } }
    { set-string-nth-fast { fixnum fixnum string } { } }
    { signal-handler { } { } }
    { strip-stack-traces { } { } }
    { unimplemented { } { } }
    { word-optimized? { word } { object } }
} define-primitives
