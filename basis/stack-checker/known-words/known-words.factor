! Copyright (C) 2004, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors alien alien.accessors arrays byte-arrays
classes continuations.private effects generic hashtables
hashtables.private io io.backend io.files io.files.private
io.streams.c kernel kernel.private math math.private
math.parser.private memory memory.private namespaces
namespaces.private parser quotations quotations.private sbufs
sbufs.private sequences sequences.private slots.private strings
strings.private system threads.private classes.tuple
classes.tuple.private vectors vectors.private words
words.private definitions assocs summary compiler.units
system.private combinators combinators.short-circuit locals
locals.backend locals.types combinators.private
stack-checker.values generic.single generic.single.private
alien.libraries tools.dispatch.private tools.profiler.private
stack-checker.alien
stack-checker.state
stack-checker.errors
stack-checker.visitor
stack-checker.backend
stack-checker.branches
stack-checker.transforms
stack-checker.dependencies
stack-checker.recursive-state ;
IN: stack-checker.known-words

: infer-primitive ( word -- )
    dup
    [ "input-classes" word-prop ]
    [ "default-output-classes" word-prop ] bi <effect>
    apply-word/effect ;

{
    { drop  (( x     --             )) }
    { 2drop (( x y   --             )) }
    { 3drop (( x y z --             )) }
    { dup   (( x     -- x x         )) }
    { 2dup  (( x y   -- x y x y     )) }
    { 3dup  (( x y z -- x y z x y z )) }
    { rot   (( x y z -- y z x       )) }
    { -rot  (( x y z -- z x y       )) }
    { dupd  (( x y   -- x x y       )) }
    { swapd (( x y z -- y x z       )) }
    { nip   (( x y   -- y           )) }
    { 2nip  (( x y z -- z           )) }
    { over  (( x y   -- x y x       )) }
    { pick  (( x y z -- x y z x     )) }
    { swap  (( x y   -- y x         )) }
} [ "shuffle" set-word-prop ] assoc-each

: infer-shuffle ( shuffle -- )
    [ in>> length consume-d ] keep ! inputs shuffle
    [ drop ] [ shuffle dup copy-values dup output-d ] 2bi ! inputs outputs copies
    [ nip f f ] [ swap zip ] 2bi ! in-d out-d in-r out-r mapping
    #shuffle, ;

: infer-shuffle-word ( word -- )
    "shuffle" word-prop infer-shuffle ;

: check-declaration ( declaration -- declaration )
    dup { [ array? ] [ [ class? ] all? ] } 1&&
    [ bad-declaration-error ] unless ;

: infer-declare ( -- )
    pop-literal nip check-declaration
    [ length ensure-d ] keep zip
    #declare, ;

\ declare [ infer-declare ] "special" set-word-prop

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

ERROR: bad-executable obj ;

M: bad-executable summary
    drop "execute must be given a word" ;

: infer-execute ( -- )
    pop-literal nip
    dup word? [
        apply-object
    ] [
        \ bad-executable boa time-bomb
    ] if ;

\ execute [ infer-execute ] "special" set-word-prop

\ (execute) [ infer-execute ] "special" set-word-prop

: infer-<tuple-boa> ( -- )
    \ <tuple-boa>
    peek-d literal value>> second 1 + { tuple } <effect>
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

: infer-exit ( -- )
    \ exit (( n -- * )) apply-word/effect ;

\ exit [ infer-exit ] "special" set-word-prop

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

\ do-primitive [ unknown-primitive-error ] "special" set-word-prop

\ if [ infer-if ] "special" set-word-prop
\ dispatch [ infer-dispatch ] "special" set-word-prop

\ alien-invoke [ infer-alien-invoke ] "special" set-word-prop
\ alien-indirect [ infer-alien-indirect ] "special" set-word-prop
\ alien-callback [ infer-alien-callback ] "special" set-word-prop

: infer-special ( word -- )
    [ current-word set ] [ "special" word-prop call( -- ) ] bi ;

: infer-local-reader ( word -- )
    (( -- value )) apply-word/effect ;

: infer-local-writer ( word -- )
    (( value -- )) apply-word/effect ;

: infer-local-word ( word -- )
    "local-word-def" word-prop infer-quot-here ;

{
    declare call (call) dip 2dip 3dip curry compose
    execute (execute) call-effect-unsafe execute-effect-unsafe if
    dispatch <tuple-boa> exit load-local load-locals get-local
    drop-locals do-primitive alien-invoke alien-indirect
    alien-callback
} [ t "no-compile" set-word-prop ] each

! Exceptions to the above
\ curry f "no-compile" set-word-prop
\ compose f "no-compile" set-word-prop

! More words not to compile
\ clear t "no-compile" set-word-prop

: non-inline-word ( word -- )
    dup called-dependency depends-on
    {
        { [ dup "shuffle" word-prop ] [ infer-shuffle-word ] }
        { [ dup "special" word-prop ] [ infer-special ] }
        { [ dup "primitive" word-prop ] [ infer-primitive ] }
        { [ dup "transform-quot" word-prop ] [ apply-transform ] }
        { [ dup "macro" word-prop ] [ apply-macro ] }
        { [ dup local? ] [ infer-local-reader ] }
        { [ dup local-reader? ] [ infer-local-reader ] }
        { [ dup local-writer? ] [ infer-local-writer ] }
        { [ dup local-word? ] [ infer-local-word ] }
        [ infer-word ]
    } cond ;

: define-primitive ( word inputs outputs -- )
    [ 2drop t "primitive" set-word-prop ]
    [ drop "input-classes" set-word-prop ]
    [ nip "default-output-classes" set-word-prop ]
    3tri ;

! Stack effects for all primitives
\ fixnum< { fixnum fixnum } { object } define-primitive
\ fixnum< make-foldable

\ fixnum<= { fixnum fixnum } { object } define-primitive
\ fixnum<= make-foldable

\ fixnum> { fixnum fixnum } { object } define-primitive
\ fixnum> make-foldable

\ fixnum>= { fixnum fixnum } { object } define-primitive
\ fixnum>= make-foldable

\ eq? { object object } { object } define-primitive
\ eq? make-foldable

\ bignum>fixnum { bignum } { fixnum } define-primitive
\ bignum>fixnum make-foldable

\ float>fixnum { float } { fixnum } define-primitive
\ bignum>fixnum make-foldable

\ fixnum>bignum { fixnum } { bignum } define-primitive
\ fixnum>bignum make-foldable

\ float>bignum { float } { bignum } define-primitive
\ float>bignum make-foldable

\ fixnum>float { fixnum } { float } define-primitive
\ fixnum>float make-foldable

\ bignum>float { bignum } { float } define-primitive
\ bignum>float make-foldable

\ (string>float) { byte-array } { float } define-primitive
\ (string>float) make-foldable

\ (float>string) { float } { byte-array } define-primitive
\ (float>string) make-foldable

\ float>bits { real } { integer } define-primitive
\ float>bits make-foldable

\ double>bits { real } { integer } define-primitive
\ double>bits make-foldable

\ bits>float { integer } { float } define-primitive
\ bits>float make-foldable

\ bits>double { integer } { float } define-primitive
\ bits>double make-foldable

\ both-fixnums? { object object } { object } define-primitive

\ fixnum+ { fixnum fixnum } { integer } define-primitive
\ fixnum+ make-foldable

\ fixnum+fast { fixnum fixnum } { fixnum } define-primitive
\ fixnum+fast make-foldable

\ fixnum- { fixnum fixnum } { integer } define-primitive
\ fixnum- make-foldable

\ fixnum-fast { fixnum fixnum } { fixnum } define-primitive
\ fixnum-fast make-foldable

\ fixnum* { fixnum fixnum } { integer } define-primitive
\ fixnum* make-foldable

\ fixnum*fast { fixnum fixnum } { fixnum } define-primitive
\ fixnum*fast make-foldable

\ fixnum/i { fixnum fixnum } { integer } define-primitive
\ fixnum/i make-foldable

\ fixnum/i-fast { fixnum fixnum } { fixnum } define-primitive
\ fixnum/i-fast make-foldable

\ fixnum-mod { fixnum fixnum } { fixnum } define-primitive
\ fixnum-mod make-foldable

\ fixnum/mod { fixnum fixnum } { integer fixnum } define-primitive
\ fixnum/mod make-foldable

\ fixnum/mod-fast { fixnum fixnum } { fixnum fixnum } define-primitive
\ fixnum/mod-fast make-foldable

\ fixnum-bitand { fixnum fixnum } { fixnum } define-primitive
\ fixnum-bitand make-foldable

\ fixnum-bitor { fixnum fixnum } { fixnum } define-primitive
\ fixnum-bitor make-foldable

\ fixnum-bitxor { fixnum fixnum } { fixnum } define-primitive
\ fixnum-bitxor make-foldable

\ fixnum-bitnot { fixnum } { fixnum } define-primitive
\ fixnum-bitnot make-foldable

\ fixnum-shift { fixnum fixnum } { integer } define-primitive
\ fixnum-shift make-foldable

\ fixnum-shift-fast { fixnum fixnum } { fixnum } define-primitive
\ fixnum-shift-fast make-foldable

\ bignum= { bignum bignum } { object } define-primitive
\ bignum= make-foldable

\ bignum+ { bignum bignum } { bignum } define-primitive
\ bignum+ make-foldable

\ bignum- { bignum bignum } { bignum } define-primitive
\ bignum- make-foldable

\ bignum* { bignum bignum } { bignum } define-primitive
\ bignum* make-foldable

\ bignum/i { bignum bignum } { bignum } define-primitive
\ bignum/i make-foldable

\ bignum-mod { bignum bignum } { bignum } define-primitive
\ bignum-mod make-foldable

\ bignum/mod { bignum bignum } { bignum bignum } define-primitive
\ bignum/mod make-foldable

\ bignum-bitand { bignum bignum } { bignum } define-primitive
\ bignum-bitand make-foldable

\ bignum-bitor { bignum bignum } { bignum } define-primitive
\ bignum-bitor make-foldable

\ bignum-bitxor { bignum bignum } { bignum } define-primitive
\ bignum-bitxor make-foldable

\ bignum-bitnot { bignum } { bignum } define-primitive
\ bignum-bitnot make-foldable

\ bignum-shift { bignum fixnum } { bignum } define-primitive
\ bignum-shift make-foldable

\ bignum< { bignum bignum } { object } define-primitive
\ bignum< make-foldable

\ bignum<= { bignum bignum } { object } define-primitive
\ bignum<= make-foldable

\ bignum> { bignum bignum } { object } define-primitive
\ bignum> make-foldable

\ bignum>= { bignum bignum } { object } define-primitive
\ bignum>= make-foldable

\ bignum-bit? { bignum integer } { object } define-primitive
\ bignum-bit? make-foldable

\ bignum-log2 { bignum } { bignum } define-primitive
\ bignum-log2 make-foldable

\ byte-array>bignum { byte-array } { bignum } define-primitive
\ byte-array>bignum make-foldable

\ float= { float float } { object } define-primitive
\ float= make-foldable

\ float+ { float float } { float } define-primitive
\ float+ make-foldable

\ float- { float float } { float } define-primitive
\ float- make-foldable

\ float* { float float } { float } define-primitive
\ float* make-foldable

\ float/f { float float } { float } define-primitive
\ float/f make-foldable

\ float-mod { float float } { float } define-primitive
\ float-mod make-foldable

\ float< { float float } { object } define-primitive
\ float< make-foldable

\ float<= { float float } { object } define-primitive
\ float<= make-foldable

\ float> { float float } { object } define-primitive
\ float> make-foldable

\ float>= { float float } { object } define-primitive
\ float>= make-foldable

\ float-u< { float float } { object } define-primitive
\ float-u< make-foldable

\ float-u<= { float float } { object } define-primitive
\ float-u<= make-foldable

\ float-u> { float float } { object } define-primitive
\ float-u> make-foldable

\ float-u>= { float float } { object } define-primitive
\ float-u>= make-foldable

\ (word) { object object object } { word } define-primitive
\ (word) make-flushable

\ word-xt { word } { integer integer } define-primitive
\ word-xt make-flushable

\ getenv { fixnum } { object } define-primitive
\ getenv make-flushable

\ setenv { object fixnum } { } define-primitive

\ (exists?) { string } { object } define-primitive

\ minor-gc { } { } define-primitive

\ gc { } { } define-primitive

\ compact-gc { } { } define-primitive

\ (save-image) { byte-array } { } define-primitive

\ (save-image-and-exit) { byte-array } { } define-primitive

\ data-room { } { byte-array } define-primitive
\ data-room make-flushable

\ code-room { } { byte-array } define-primitive
\ code-room  make-flushable

\ micros { } { integer } define-primitive
\ micros make-flushable

\ tag { object } { fixnum } define-primitive
\ tag make-foldable

\ (dlopen) { byte-array } { dll } define-primitive

\ (dlsym) { byte-array object } { c-ptr } define-primitive

\ dlclose { dll } { } define-primitive

\ <byte-array> { integer } { byte-array } define-primitive
\ <byte-array> make-flushable

\ (byte-array) { integer } { byte-array } define-primitive
\ (byte-array) make-flushable

\ <displaced-alien> { integer c-ptr } { c-ptr } define-primitive
\ <displaced-alien> make-flushable

\ alien-signed-cell { c-ptr integer } { integer } define-primitive
\ alien-signed-cell make-flushable

\ set-alien-signed-cell { integer c-ptr integer } { } define-primitive

\ alien-unsigned-cell { c-ptr integer } { integer } define-primitive
\ alien-unsigned-cell make-flushable

\ set-alien-unsigned-cell { integer c-ptr integer } { } define-primitive

\ alien-signed-8 { c-ptr integer } { integer } define-primitive
\ alien-signed-8 make-flushable

\ set-alien-signed-8 { integer c-ptr integer } { } define-primitive

\ alien-unsigned-8 { c-ptr integer } { integer } define-primitive
\ alien-unsigned-8 make-flushable

\ set-alien-unsigned-8 { integer c-ptr integer } { } define-primitive

\ alien-signed-4 { c-ptr integer } { integer } define-primitive
\ alien-signed-4 make-flushable

\ set-alien-signed-4 { integer c-ptr integer } { } define-primitive

\ alien-unsigned-4 { c-ptr integer } { integer } define-primitive
\ alien-unsigned-4 make-flushable

\ set-alien-unsigned-4 { integer c-ptr integer } { } define-primitive

\ alien-signed-2 { c-ptr integer } { fixnum } define-primitive
\ alien-signed-2 make-flushable

\ set-alien-signed-2 { integer c-ptr integer } { } define-primitive

\ alien-unsigned-2 { c-ptr integer } { fixnum } define-primitive
\ alien-unsigned-2 make-flushable

\ set-alien-unsigned-2 { integer c-ptr integer } { } define-primitive

\ alien-signed-1 { c-ptr integer } { fixnum } define-primitive
\ alien-signed-1 make-flushable

\ set-alien-signed-1 { integer c-ptr integer } { } define-primitive

\ alien-unsigned-1 { c-ptr integer } { fixnum } define-primitive
\ alien-unsigned-1 make-flushable

\ set-alien-unsigned-1 { integer c-ptr integer } { } define-primitive

\ alien-float { c-ptr integer } { float } define-primitive
\ alien-float make-flushable

\ set-alien-float { float c-ptr integer } { } define-primitive

\ alien-double { c-ptr integer } { float } define-primitive
\ alien-double make-flushable

\ set-alien-double { float c-ptr integer } { } define-primitive

\ alien-cell { c-ptr integer } { pinned-c-ptr } define-primitive
\ alien-cell make-flushable

\ set-alien-cell { c-ptr c-ptr integer } { } define-primitive

\ alien-address { alien } { integer } define-primitive
\ alien-address make-flushable

\ slot { object fixnum } { object } define-primitive
\ slot make-flushable

\ set-slot { object object fixnum } { } define-primitive

\ string-nth { fixnum string } { fixnum } define-primitive
\ string-nth make-flushable

\ set-string-nth-slow { fixnum fixnum string } { } define-primitive
\ set-string-nth-fast { fixnum fixnum string } { } define-primitive

\ resize-array { integer array } { array } define-primitive
\ resize-array make-flushable

\ resize-byte-array { integer byte-array } { byte-array } define-primitive
\ resize-byte-array make-flushable

\ resize-string { integer string } { string } define-primitive
\ resize-string make-flushable

\ <array> { integer object } { array } define-primitive
\ <array> make-flushable

\ all-instances { } { array } define-primitive

\ size { object } { fixnum } define-primitive
\ size make-flushable

\ die { } { } define-primitive

\ (fopen) { byte-array byte-array } { alien } define-primitive

\ fgetc { alien } { object } define-primitive

\ fwrite { string alien } { } define-primitive

\ fputc { object alien } { } define-primitive

\ fread { integer string } { object } define-primitive

\ fflush { alien } { } define-primitive

\ fseek { alien integer integer } { } define-primitive

\ fclose { alien } { } define-primitive

\ <wrapper> { object } { wrapper } define-primitive
\ <wrapper> make-foldable

\ (clone) { object } { object } define-primitive
\ (clone) make-flushable

\ <string> { integer integer } { string } define-primitive
\ <string> make-flushable

\ array>quotation { array } { quotation } define-primitive
\ array>quotation make-flushable

\ quotation-xt { quotation } { integer } define-primitive
\ quotation-xt make-flushable

\ <tuple> { tuple-layout } { tuple } define-primitive
\ <tuple> make-flushable

\ datastack { } { array } define-primitive
\ datastack make-flushable

\ check-datastack { array integer integer } { object } define-primitive
\ check-datastack make-flushable

\ retainstack { } { array } define-primitive
\ retainstack make-flushable

\ callstack { } { callstack } define-primitive
\ callstack make-flushable

\ callstack>array { callstack } { array } define-primitive
\ callstack>array make-flushable

\ (sleep) { integer } { } define-primitive

\ become { array array } { } define-primitive

\ innermost-frame-executing { callstack } { object } define-primitive

\ innermost-frame-scan { callstack } { fixnum } define-primitive

\ set-innermost-frame-quot { quotation callstack } { } define-primitive

\ dll-valid? { object } { object } define-primitive

\ modify-code-heap { array } { } define-primitive

\ unimplemented { } { } define-primitive

\ jit-compile { quotation } { } define-primitive

\ lookup-method { object array } { word } define-primitive

\ reset-dispatch-stats { } { } define-primitive
\ dispatch-stats { } { byte-array } define-primitive

\ optimized? { word } { object } define-primitive

\ strip-stack-traces { } { } define-primitive

\ <callback> { word } { alien } define-primitive

\ enable-gc-events { } { } define-primitive
\ disable-gc-events { } { object } define-primitive

\ profiling { object } { } define-primitive

\ (identity-hashcode) { object } { fixnum } define-primitive

\ compute-identity-hashcode { object } { } define-primitive
