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

! This is a hack for combinators combinators.short-circuit.smart.
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
    { drop  ( x     --             ) }
    { 2drop ( x y   --             ) }
    { 3drop ( x y z --             ) }
    { dup   ( x     -- x x         ) }
    { 2dup  ( x y   -- x y x y     ) }
    { 3dup  ( x y z -- x y z x y z ) }
    { rot   ( x y z -- y z x       ) }
    { -rot  ( x y z -- z x y       ) }
    { dupd  ( x y   -- x x y       ) }
    { swapd ( x y z -- y x z       ) }
    { nip   ( x y   -- y           ) }
    { 2nip  ( x y z -- z           ) }
    { over  ( x y   -- x y x       ) }
    { pick  ( x y z -- x y z x     ) }
    { swap  ( x y   -- y x         ) }
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

M: literal infer-call*
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

! Stack effects for all primitives
\ (byte-array) { integer } { byte-array } define-primitive \ (byte-array) make-flushable
\ (clone) { object } { object } define-primitive \ (clone) make-flushable
\ (code-blocks) { } { array } define-primitive \ (code-blocks)  make-flushable
\ (dlopen) { byte-array } { dll } define-primitive
\ (dlsym) { byte-array object } { c-ptr } define-primitive
\ (dlsym-raw) { byte-array object } { c-ptr } define-primitive
\ (exists?) { string } { object } define-primitive
\ (exit) { integer } { } define-primitive
\ (format-float) { float byte-array } { byte-array } define-primitive \ (format-float) make-foldable
\ (fopen) { byte-array byte-array } { alien } define-primitive
\ (identity-hashcode) { object } { fixnum } define-primitive
\ (save-image) { byte-array byte-array } { } define-primitive
\ (save-image-and-exit) { byte-array byte-array } { } define-primitive
\ (set-context) { object alien } { object } define-primitive
\ (set-context-and-delete) { object alien } { } define-primitive
\ (sleep) { integer } { } define-primitive
\ (start-context) { object quotation } { object } define-primitive
\ (start-context-and-delete) { object quotation } { } define-primitive
\ (word) { object object object } { word } define-primitive \ (word) make-flushable
\ <array> { integer object } { array } define-primitive \ <array> make-flushable
\ <byte-array> { integer } { byte-array } define-primitive \ <byte-array> make-flushable
\ <callback> { integer word } { alien } define-primitive
\ <displaced-alien> { integer c-ptr } { c-ptr } define-primitive \ <displaced-alien> make-flushable
\ <string> { integer integer } { string } define-primitive \ <string> make-flushable
\ <tuple> { array } { tuple } define-primitive \ <tuple> make-flushable
\ <wrapper> { object } { wrapper } define-primitive \ <wrapper> make-foldable
\ alien-address { alien } { integer } define-primitive \ alien-address make-flushable
\ alien-cell { c-ptr integer } { pinned-c-ptr } define-primitive \ alien-cell make-flushable
\ alien-double { c-ptr integer } { float } define-primitive \ alien-double make-flushable
\ alien-float { c-ptr integer } { float } define-primitive \ alien-float make-flushable
\ alien-signed-1 { c-ptr integer } { fixnum } define-primitive \ alien-signed-1 make-flushable
\ alien-signed-2 { c-ptr integer } { fixnum } define-primitive \ alien-signed-2 make-flushable
\ alien-signed-4 { c-ptr integer } { integer } define-primitive \ alien-signed-4 make-flushable
\ alien-signed-8 { c-ptr integer } { integer } define-primitive \ alien-signed-8 make-flushable
\ alien-signed-cell { c-ptr integer } { integer } define-primitive \ alien-signed-cell make-flushable
\ alien-unsigned-1 { c-ptr integer } { fixnum } define-primitive \ alien-unsigned-1 make-flushable
\ alien-unsigned-2 { c-ptr integer } { fixnum } define-primitive \ alien-unsigned-2 make-flushable
\ alien-unsigned-4 { c-ptr integer } { integer } define-primitive \ alien-unsigned-4 make-flushable
\ alien-unsigned-8 { c-ptr integer } { integer } define-primitive \ alien-unsigned-8 make-flushable
\ alien-unsigned-cell { c-ptr integer } { integer } define-primitive \ alien-unsigned-cell make-flushable
\ all-instances { } { array } define-primitive
\ array>quotation { array } { quotation } define-primitive \ array>quotation make-foldable
\ become { array array } { } define-primitive
\ bignum* { bignum bignum } { bignum } define-primitive \ bignum* make-foldable
\ bignum+ { bignum bignum } { bignum } define-primitive \ bignum+ make-foldable
\ bignum- { bignum bignum } { bignum } define-primitive \ bignum- make-foldable
\ bignum-bit? { bignum integer } { object } define-primitive \ bignum-bit? make-foldable
\ bignum-bitand { bignum bignum } { bignum } define-primitive \ bignum-bitand make-foldable
\ bignum-bitnot { bignum } { bignum } define-primitive \ bignum-bitnot make-foldable
\ bignum-bitor { bignum bignum } { bignum } define-primitive \ bignum-bitor make-foldable
\ bignum-bitxor { bignum bignum } { bignum } define-primitive \ bignum-bitxor make-foldable
\ bignum-log2 { bignum } { bignum } define-primitive \ bignum-log2 make-foldable
\ bignum-mod { bignum bignum } { bignum } define-primitive \ bignum-mod make-foldable
\ bignum-gcd { bignum bignum } { bignum } define-primitive \ bignum-gcd make-foldable
\ bignum-shift { bignum fixnum } { bignum } define-primitive \ bignum-shift make-foldable
\ bignum/i { bignum bignum } { bignum } define-primitive \ bignum/i make-foldable
\ bignum/mod { bignum bignum } { bignum bignum } define-primitive \ bignum/mod make-foldable
\ bignum< { bignum bignum } { object } define-primitive \ bignum< make-foldable
\ bignum<= { bignum bignum } { object } define-primitive \ bignum<= make-foldable
\ bignum= { bignum bignum } { object } define-primitive \ bignum= make-foldable
\ bignum> { bignum bignum } { object } define-primitive \ bignum> make-foldable
\ bignum>= { bignum bignum } { object } define-primitive \ bignum>= make-foldable
\ bignum>fixnum { bignum } { fixnum } define-primitive \ bignum>fixnum make-foldable
\ bits>double { integer } { float } define-primitive \ bits>double make-foldable
\ bits>float { integer } { float } define-primitive \ bits>float make-foldable
\ both-fixnums? { object object } { object } define-primitive
\ callstack { } { callstack } define-primitive \ callstack make-flushable
\ callstack-bounds { } { alien alien } define-primitive \ callstack-bounds make-flushable
\ callstack-for { c-ptr } { callstack } define-primitive \ callstack make-flushable
\ callstack>array { callstack } { array } define-primitive \ callstack>array make-flushable
\ check-datastack { array integer integer } { object } define-primitive \ check-datastack make-flushable
\ (code-room) { } { byte-array } define-primitive \ (code-room)  make-flushable
\ compact-gc { } { } define-primitive
\ compute-identity-hashcode { object } { } define-primitive
\ context-object { fixnum } { object } define-primitive \ context-object make-flushable
\ context-object-for { fixnum c-ptr } { object } define-primitive \ context-object-for make-flushable
\ current-callback { } { fixnum } define-primitive \ current-callback make-flushable
\ (data-room) { } { byte-array } define-primitive \ (data-room) make-flushable
\ datastack { } { array } define-primitive \ datastack make-flushable
\ datastack-for { c-ptr } { array } define-primitive \ datastack-for make-flushable
\ die { } { } define-primitive
\ disable-gc-events { } { object } define-primitive
\ dispatch-stats { } { byte-array } define-primitive
\ dlclose { dll } { } define-primitive
\ dll-valid? { object } { object } define-primitive
\ double>bits { real } { integer } define-primitive \ double>bits make-foldable
\ enable-gc-events { } { } define-primitive
\ eq? { object object } { object } define-primitive \ eq? make-foldable
\ fclose { alien } { } define-primitive
\ ffi-signal-handler { } { } define-primitive
\ ffi-leaf-signal-handler { } { } define-primitive
\ fflush { alien } { } define-primitive
\ fgetc { alien } { object } define-primitive
\ fixnum* { fixnum fixnum } { integer } define-primitive \ fixnum* make-foldable
\ fixnum*fast { fixnum fixnum } { fixnum } define-primitive \ fixnum*fast make-foldable
\ fixnum+ { fixnum fixnum } { integer } define-primitive \ fixnum+ make-foldable
\ fixnum+fast { fixnum fixnum } { fixnum } define-primitive \ fixnum+fast make-foldable
\ fixnum- { fixnum fixnum } { integer } define-primitive \ fixnum- make-foldable
\ fixnum-bitand { fixnum fixnum } { fixnum } define-primitive \ fixnum-bitand make-foldable
\ fixnum-bitnot { fixnum } { fixnum } define-primitive \ fixnum-bitnot make-foldable
\ fixnum-bitor { fixnum fixnum } { fixnum } define-primitive \ fixnum-bitor make-foldable
\ fixnum-bitxor { fixnum fixnum } { fixnum } define-primitive \ fixnum-bitxor make-foldable
\ fixnum-fast { fixnum fixnum } { fixnum } define-primitive \ fixnum-fast make-foldable
\ fixnum-mod { fixnum fixnum } { fixnum } define-primitive \ fixnum-mod make-foldable
\ fixnum-shift { fixnum fixnum } { integer } define-primitive \ fixnum-shift make-foldable
\ fixnum-shift-fast { fixnum fixnum } { fixnum } define-primitive \ fixnum-shift-fast make-foldable
\ fixnum/i { fixnum fixnum } { integer } define-primitive \ fixnum/i make-foldable
\ fixnum/i-fast { fixnum fixnum } { fixnum } define-primitive \ fixnum/i-fast make-foldable
\ fixnum/mod { fixnum fixnum } { integer fixnum } define-primitive \ fixnum/mod make-foldable
\ fixnum/mod-fast { fixnum fixnum } { fixnum fixnum } define-primitive \ fixnum/mod-fast make-foldable
\ fixnum< { fixnum fixnum } { object } define-primitive \ fixnum< make-foldable
\ fixnum<= { fixnum fixnum } { object } define-primitive \ fixnum<= make-foldable
\ fixnum> { fixnum fixnum } { object } define-primitive \ fixnum> make-foldable
\ fixnum>= { fixnum fixnum } { object } define-primitive \ fixnum>= make-foldable
\ fixnum>bignum { fixnum } { bignum } define-primitive \ fixnum>bignum make-foldable
\ fixnum>float { fixnum } { float } define-primitive \ fixnum>float make-foldable
\ float* { float float } { float } define-primitive \ float* make-foldable
\ float+ { float float } { float } define-primitive \ float+ make-foldable
\ float- { float float } { float } define-primitive \ float- make-foldable
\ float-u< { float float } { object } define-primitive \ float-u< make-foldable
\ float-u<= { float float } { object } define-primitive \ float-u<= make-foldable
\ float-u> { float float } { object } define-primitive \ float-u> make-foldable
\ float-u>= { float float } { object } define-primitive \ float-u>= make-foldable
\ float/f { float float } { float } define-primitive \ float/f make-foldable
\ float< { float float } { object } define-primitive \ float< make-foldable
\ float<= { float float } { object } define-primitive \ float<= make-foldable
\ float= { float float } { object } define-primitive \ float= make-foldable
\ float> { float float } { object } define-primitive \ float> make-foldable
\ float>= { float float } { object } define-primitive \ float>= make-foldable
\ float>bignum { float } { bignum } define-primitive \ float>bignum make-foldable
\ float>bits { real } { integer } define-primitive \ float>bits make-foldable
\ float>fixnum { float } { fixnum } define-primitive \ bignum>fixnum make-foldable
\ fpu-state { } { } define-primitive
\ fputc { object alien } { } define-primitive
\ fread-unsafe { integer c-ptr alien } { integer } define-primitive
\ fseek { integer integer alien } { } define-primitive
\ ftell { alien } { integer } define-primitive
\ fwrite { c-ptr integer alien } { } define-primitive
\ gc { } { } define-primitive
\ innermost-frame-executing { callstack } { object } define-primitive
\ innermost-frame-scan { callstack } { fixnum } define-primitive
\ jit-compile { quotation } { } define-primitive
\ leaf-signal-handler { } { } define-primitive
\ gsp:lookup-method { object array } { word } define-primitive
\ minor-gc { } { } define-primitive
\ modify-code-heap { array object object } { } define-primitive
\ nano-count { } { integer } define-primitive \ nano-count make-flushable
\ optimized? { word } { object } define-primitive
\ profiling { object } { } define-primitive
\ (get-samples) { } { object } define-primitive
\ (clear-samples) { } { } define-primitive
\ quot-compiled? { quotation } { object } define-primitive
\ quotation-code { quotation } { integer integer } define-primitive \ quotation-code make-flushable
\ reset-dispatch-stats { } { } define-primitive
\ resize-array { integer array } { array } define-primitive
\ resize-byte-array { integer byte-array } { byte-array } define-primitive
\ resize-string { integer string } { string } define-primitive
\ retainstack { } { array } define-primitive \ retainstack make-flushable
\ retainstack-for { c-ptr } { array } define-primitive \ retainstack-for make-flushable
\ set-alien-cell { c-ptr c-ptr integer } { } define-primitive
\ set-alien-double { float c-ptr integer } { } define-primitive
\ set-alien-float { float c-ptr integer } { } define-primitive
\ set-alien-signed-1 { integer c-ptr integer } { } define-primitive
\ set-alien-signed-2 { integer c-ptr integer } { } define-primitive
\ set-alien-signed-4 { integer c-ptr integer } { } define-primitive
\ set-alien-signed-8 { integer c-ptr integer } { } define-primitive
\ set-alien-signed-cell { integer c-ptr integer } { } define-primitive
\ set-alien-unsigned-1 { integer c-ptr integer } { } define-primitive
\ set-alien-unsigned-2 { integer c-ptr integer } { } define-primitive
\ set-alien-unsigned-4 { integer c-ptr integer } { } define-primitive
\ set-alien-unsigned-8 { integer c-ptr integer } { } define-primitive
\ set-alien-unsigned-cell { integer c-ptr integer } { } define-primitive
\ set-context-object { object fixnum } { } define-primitive
\ set-fpu-state { } { } define-primitive
\ set-innermost-frame-quot { quotation callstack } { } define-primitive
\ set-slot { object object fixnum } { } define-primitive
\ set-special-object { object fixnum } { } define-primitive
\ set-string-nth-fast { fixnum fixnum string } { } define-primitive
\ signal-handler { } { } define-primitive
\ size { object } { fixnum } define-primitive \ size make-flushable
\ slot { object fixnum } { object } define-primitive \ slot make-flushable
\ special-object { fixnum } { object } define-primitive \ special-object make-flushable
\ string-nth-fast { fixnum string } { fixnum } define-primitive \ string-nth-fast make-flushable
\ strip-stack-traces { } { } define-primitive
\ tag { object } { fixnum } define-primitive \ tag make-foldable
\ unimplemented { } { } define-primitive
\ word-code { word } { integer integer } define-primitive \ word-code make-flushable
