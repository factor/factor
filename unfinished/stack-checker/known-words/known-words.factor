! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors alien alien.accessors arrays byte-arrays
classes sequences.private continuations.private effects generic
hashtables hashtables.private io io.backend io.files io.files.private
io.streams.c kernel kernel.private math math.private memory
namespaces namespaces.private parser prettyprint quotations
quotations.private sbufs sbufs.private sequences
sequences.private slots.private strings strings.private system
threads.private classes.tuple classes.tuple.private vectors
vectors.private words words.private assocs summary
compiler.units system.private
stack-checker.state stack-checker.backend stack-checker.branches
stack-checker.errors stack-checker.visitor ;
IN: stack-checker.known-words

: infer-shuffle ( shuffle -- )
    [ in>> length consume-d ] keep ! inputs shuffle
    [ drop ] [ shuffle* dup copy-values dup output-d ] 2bi ! inputs outputs copies
    [ nip ] [ swap zip ] 2bi ! inputs copies mapping
    #shuffle, ;

: define-shuffle ( word shuffle -- )
    '[ , infer-shuffle ] +infer+ set-word-prop ;

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
    { tuck  (( x y   -- y x y       )) }
    { over  (( x y   -- x y x       )) }
    { pick  (( x y z -- x y z x     )) }
    { swap  (( x y   -- y x         )) }
} [ define-shuffle ] assoc-each

\ >r [ 1 infer->r ] +infer+ set-word-prop
\ r> [ 1 infer-r> ] +infer+ set-word-prop


\ declare [
    pop-literal nip
    [ length consume-d dup copy-values dup output-d ] keep
    #declare,
] +infer+ set-word-prop

! Primitive combinators
GENERIC: infer-call* ( value known -- )

: infer-call ( value -- ) dup known infer-call* ;

M: literal infer-call*
    [ 1array #drop, ] [ infer-literal-quot ] bi* ;

M: curried infer-call*
    swap push-d
    [ uncurry ] recursive-state get infer-quot
    [ quot>> known pop-d [ set-known ] keep ]
    [ obj>> known pop-d [ set-known ] keep ] bi
    push-d infer-call ;

M: composed infer-call*
    swap push-d
    [ uncompose ] recursive-state get infer-quot
    [ quot2>> known pop-d [ set-known ] keep ]
    [ quot1>> known pop-d [ set-known ] keep ] bi
    push-d push-d
    [ slip call ] recursive-state get infer-quot ;

M: object infer-call*
    \ literal-expected inference-warning ;

\ call [ pop-d infer-call ] +infer+ set-word-prop

\ call t "no-compile" set-word-prop

\ curry [
    2 consume-d
    dup first2 <curried> make-known
    [ push-d ] [ 1array ] bi
    \ curry #call,
] +infer+ set-word-prop

\ compose [
    2 consume-d
    dup first2 <composed> make-known
    [ push-d ] [ 1array ] bi
    \ compose #call,
] +infer+ set-word-prop

\ execute [
    pop-literal nip
    dup word? [
        apply-object
    ] [
        drop
        "execute must be given a word" time-bomb
    ] if
] +infer+ set-word-prop

\ execute t "no-compile" set-word-prop

\ if [
    2 consume-d
    dup [ known [ curry? ] [ composed? ] bi or ] contains? [
        output-d
        [ rot [ drop call ] [ nip call ] if ]
        recursive-state get infer-quot
    ] [
        [ #drop, ] [ [ literal ] map infer-if ] bi
    ] if
] +infer+ set-word-prop

\ dispatch [
    pop-literal nip [ <literal> ] map infer-dispatch
] +infer+ set-word-prop

\ dispatch t "no-compile" set-word-prop

! Variadic tuple constructor
\ <tuple-boa> [
    \ <tuple-boa>
    peek-d literal value>> size>> { tuple } <effect>
    apply-word/effect
] +infer+ set-word-prop

! Non-standard control flow
\ (throw) [
    \ (throw)
    peek-d literal value>> 2 + f <effect> t >>terminated?
    apply-word/effect
] +infer+ set-word-prop

:  set-primitive-effect ( word effect -- )
    [ in>> "input-classes" set-word-prop ]
    [ out>> "default-output-classes" set-word-prop ]
    [ dupd '[ , , apply-word/effect ] +infer+ set-word-prop ]
    2tri ;

! Stack effects for all primitives
\ fixnum< { fixnum fixnum } { object } <effect> set-primitive-effect
\ fixnum< make-foldable

\ fixnum<= { fixnum fixnum } { object } <effect> set-primitive-effect
\ fixnum<= make-foldable

\ fixnum> { fixnum fixnum } { object } <effect> set-primitive-effect
\ fixnum> make-foldable

\ fixnum>= { fixnum fixnum } { object } <effect> set-primitive-effect
\ fixnum>= make-foldable

\ eq? { object object } { object } <effect> set-primitive-effect
\ eq? make-foldable

\ rehash-string { string } { } <effect> set-primitive-effect

\ bignum>fixnum { bignum } { fixnum } <effect> set-primitive-effect
\ bignum>fixnum make-foldable

\ float>fixnum { float } { fixnum } <effect> set-primitive-effect
\ bignum>fixnum make-foldable

\ fixnum>bignum { fixnum } { bignum } <effect> set-primitive-effect
\ fixnum>bignum make-foldable

\ float>bignum { float } { bignum } <effect> set-primitive-effect
\ float>bignum make-foldable

\ fixnum>float { fixnum } { float } <effect> set-primitive-effect
\ fixnum>float make-foldable

\ bignum>float { bignum } { float } <effect> set-primitive-effect
\ bignum>float make-foldable

\ <ratio> { integer integer } { ratio } <effect> set-primitive-effect
\ <ratio> make-foldable

\ string>float { string } { float } <effect> set-primitive-effect
\ string>float make-foldable

\ float>string { float } { string } <effect> set-primitive-effect
\ float>string make-foldable

\ float>bits { real } { integer } <effect> set-primitive-effect
\ float>bits make-foldable

\ double>bits { real } { integer } <effect> set-primitive-effect
\ double>bits make-foldable

\ bits>float { integer } { float } <effect> set-primitive-effect
\ bits>float make-foldable

\ bits>double { integer } { float } <effect> set-primitive-effect
\ bits>double make-foldable

\ <complex> { real real } { complex } <effect> set-primitive-effect
\ <complex> make-foldable

\ fixnum+ { fixnum fixnum } { integer } <effect> set-primitive-effect
\ fixnum+ make-foldable

\ fixnum+fast { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum+fast make-foldable

\ fixnum- { fixnum fixnum } { integer } <effect> set-primitive-effect
\ fixnum- make-foldable

\ fixnum-fast { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-fast make-foldable

\ fixnum* { fixnum fixnum } { integer } <effect> set-primitive-effect
\ fixnum* make-foldable

\ fixnum*fast { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum*fast make-foldable

\ fixnum/i { fixnum fixnum } { integer } <effect> set-primitive-effect
\ fixnum/i make-foldable

\ fixnum-mod { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-mod make-foldable

\ fixnum/mod { fixnum fixnum } { integer fixnum } <effect> set-primitive-effect
\ fixnum/mod make-foldable

\ fixnum-bitand { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-bitand make-foldable

\ fixnum-bitor { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-bitor make-foldable

\ fixnum-bitxor { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-bitxor make-foldable

\ fixnum-bitnot { fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-bitnot make-foldable

\ fixnum-shift { fixnum fixnum } { integer } <effect> set-primitive-effect
\ fixnum-shift make-foldable

\ fixnum-shift-fast { fixnum fixnum } { fixnum } <effect> set-primitive-effect
\ fixnum-shift-fast make-foldable

\ bignum= { bignum bignum } { object } <effect> set-primitive-effect
\ bignum= make-foldable

\ bignum+ { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum+ make-foldable

\ bignum- { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum- make-foldable

\ bignum* { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum* make-foldable

\ bignum/i { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum/i make-foldable

\ bignum-mod { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum-mod make-foldable

\ bignum/mod { bignum bignum } { bignum bignum } <effect> set-primitive-effect
\ bignum/mod make-foldable

\ bignum-bitand { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum-bitand make-foldable

\ bignum-bitor { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum-bitor make-foldable

\ bignum-bitxor { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum-bitxor make-foldable

\ bignum-bitnot { bignum } { bignum } <effect> set-primitive-effect
\ bignum-bitnot make-foldable

\ bignum-shift { bignum bignum } { bignum } <effect> set-primitive-effect
\ bignum-shift make-foldable

\ bignum< { bignum bignum } { object } <effect> set-primitive-effect
\ bignum< make-foldable

\ bignum<= { bignum bignum } { object } <effect> set-primitive-effect
\ bignum<= make-foldable

\ bignum> { bignum bignum } { object } <effect> set-primitive-effect
\ bignum> make-foldable

\ bignum>= { bignum bignum } { object } <effect> set-primitive-effect
\ bignum>= make-foldable

\ bignum-bit? { bignum integer } { object } <effect> set-primitive-effect
\ bignum-bit? make-foldable

\ bignum-log2 { bignum } { bignum } <effect> set-primitive-effect
\ bignum-log2 make-foldable

\ byte-array>bignum { byte-array } { bignum } <effect> set-primitive-effect
\ byte-array>bignum make-foldable

\ float= { float float } { object } <effect> set-primitive-effect
\ float= make-foldable

\ float+ { float float } { float } <effect> set-primitive-effect
\ float+ make-foldable

\ float- { float float } { float } <effect> set-primitive-effect
\ float- make-foldable

\ float* { float float } { float } <effect> set-primitive-effect
\ float* make-foldable

\ float/f { float float } { float } <effect> set-primitive-effect
\ float/f make-foldable

\ float< { float float } { object } <effect> set-primitive-effect
\ float< make-foldable

\ float-mod { float float } { float } <effect> set-primitive-effect
\ float-mod make-foldable

\ float<= { float float } { object } <effect> set-primitive-effect
\ float<= make-foldable

\ float> { float float } { object } <effect> set-primitive-effect
\ float> make-foldable

\ float>= { float float } { object } <effect> set-primitive-effect
\ float>= make-foldable

\ <word> { object object } { word } <effect> set-primitive-effect
\ <word> make-flushable

\ word-xt { word } { integer integer } <effect> set-primitive-effect
\ word-xt make-flushable

\ getenv { fixnum } { object } <effect> set-primitive-effect
\ getenv make-flushable

\ setenv { object fixnum } { } <effect> set-primitive-effect

\ (exists?) { string } { object } <effect> set-primitive-effect

\ (directory) { string } { array } <effect> set-primitive-effect

\ gc { } { } <effect> set-primitive-effect

\ gc-stats { } { array } <effect> set-primitive-effect

\ save-image { string } { } <effect> set-primitive-effect

\ save-image-and-exit { string } { } <effect> set-primitive-effect

\ exit { integer } { } <effect> t >>terminated? set-primitive-effect

\ data-room { } { integer integer array } <effect> set-primitive-effect
\ data-room make-flushable

\ code-room { } { integer integer integer integer } <effect> set-primitive-effect
\ code-room  make-flushable

\ os-env { string } { object } <effect> set-primitive-effect

\ millis { } { integer } <effect> set-primitive-effect
\ millis make-flushable

\ tag { object } { fixnum } <effect> set-primitive-effect
\ tag make-foldable

\ cwd { } { string } <effect> set-primitive-effect

\ cd { string } { } <effect> set-primitive-effect

\ dlopen { string } { dll } <effect> set-primitive-effect

\ dlsym { string object } { c-ptr } <effect> set-primitive-effect

\ dlclose { dll } { } <effect> set-primitive-effect

\ <byte-array> { integer } { byte-array } <effect> set-primitive-effect
\ <byte-array> make-flushable

\ <displaced-alien> { integer c-ptr } { c-ptr } <effect> set-primitive-effect
\ <displaced-alien> make-flushable

\ alien-signed-cell { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-signed-cell make-flushable

\ set-alien-signed-cell { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-unsigned-cell { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-unsigned-cell make-flushable

\ set-alien-unsigned-cell { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-signed-8 { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-signed-8 make-flushable

\ set-alien-signed-8 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-unsigned-8 { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-unsigned-8 make-flushable

\ set-alien-unsigned-8 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-signed-4 { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-signed-4 make-flushable

\ set-alien-signed-4 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-unsigned-4 { c-ptr integer } { integer } <effect> set-primitive-effect
\ alien-unsigned-4 make-flushable

\ set-alien-unsigned-4 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-signed-2 { c-ptr integer } { fixnum } <effect> set-primitive-effect
\ alien-signed-2 make-flushable

\ set-alien-signed-2 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-unsigned-2 { c-ptr integer } { fixnum } <effect> set-primitive-effect
\ alien-unsigned-2 make-flushable

\ set-alien-unsigned-2 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-signed-1 { c-ptr integer } { fixnum } <effect> set-primitive-effect
\ alien-signed-1 make-flushable

\ set-alien-signed-1 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-unsigned-1 { c-ptr integer } { fixnum } <effect> set-primitive-effect
\ alien-unsigned-1 make-flushable

\ set-alien-unsigned-1 { integer c-ptr integer } { } <effect> set-primitive-effect

\ alien-float { c-ptr integer } { float } <effect> set-primitive-effect
\ alien-float make-flushable

\ set-alien-float { float c-ptr integer } { } <effect> set-primitive-effect

\ alien-double { c-ptr integer } { float } <effect> set-primitive-effect
\ alien-double make-flushable

\ set-alien-double { float c-ptr integer } { } <effect> set-primitive-effect

\ alien-cell { c-ptr integer } { simple-c-ptr } <effect> set-primitive-effect
\ alien-cell make-flushable

\ set-alien-cell { c-ptr c-ptr integer } { } <effect> set-primitive-effect

\ alien-address { alien } { integer } <effect> set-primitive-effect
\ alien-address make-flushable

\ slot { object fixnum } { object } <effect> set-primitive-effect
\ slot make-flushable

\ set-slot { object object fixnum } { } <effect> set-primitive-effect

\ string-nth { fixnum string } { fixnum } <effect> set-primitive-effect
\ string-nth make-flushable

\ set-string-nth { fixnum fixnum string } { } <effect> set-primitive-effect

\ resize-array { integer array } { array } <effect> set-primitive-effect
\ resize-array make-flushable

\ resize-byte-array { integer byte-array } { byte-array } <effect> set-primitive-effect
\ resize-byte-array make-flushable

\ resize-string { integer string } { string } <effect> set-primitive-effect
\ resize-string make-flushable

\ <array> { integer object } { array } <effect> set-primitive-effect
\ <array> make-flushable

\ begin-scan { } { } <effect> set-primitive-effect

\ next-object { } { object } <effect> set-primitive-effect

\ end-scan { } { } <effect> set-primitive-effect

\ size { object } { fixnum } <effect> set-primitive-effect
\ size make-flushable

\ die { } { } <effect> set-primitive-effect

\ fopen { string string } { alien } <effect> set-primitive-effect

\ fgetc { alien } { object } <effect> set-primitive-effect

\ fwrite { string alien } { } <effect> set-primitive-effect

\ fputc { object alien } { } <effect> set-primitive-effect

\ fread { integer string } { object } <effect> set-primitive-effect

\ fflush { alien } { } <effect> set-primitive-effect

\ fclose { alien } { } <effect> set-primitive-effect

\ <wrapper> { object } { wrapper } <effect> set-primitive-effect
\ <wrapper> make-foldable

\ (clone) { object } { object } <effect> set-primitive-effect
\ (clone) make-flushable

\ <string> { integer integer } { string } <effect> set-primitive-effect
\ <string> make-flushable

\ array>quotation { array } { quotation } <effect> set-primitive-effect
\ array>quotation make-flushable

\ quotation-xt { quotation } { integer } <effect> set-primitive-effect
\ quotation-xt make-flushable

\ <tuple> { tuple-layout } { tuple } <effect> set-primitive-effect
\ <tuple> make-flushable

\ <tuple-layout> { word fixnum array fixnum } { tuple-layout } <effect> set-primitive-effect
\ <tuple-layout> make-foldable

\ datastack { } { array } <effect> set-primitive-effect
\ datastack make-flushable

\ retainstack { } { array } <effect> set-primitive-effect
\ retainstack make-flushable

\ callstack { } { callstack } <effect> set-primitive-effect
\ callstack make-flushable

\ callstack>array { callstack } { array } <effect> set-primitive-effect
\ callstack>array make-flushable

\ (sleep) { integer } { } <effect> set-primitive-effect

\ become { array array } { } <effect> set-primitive-effect

\ innermost-frame-quot { callstack } { quotation } <effect> set-primitive-effect

\ innermost-frame-scan { callstack } { fixnum } <effect> set-primitive-effect

\ set-innermost-frame-quot { quotation callstack } { } <effect> set-primitive-effect

\ (os-envs) { } { array } <effect> set-primitive-effect

\ set-os-env { string string } { } <effect> set-primitive-effect

\ unset-os-env { string } { } <effect> set-primitive-effect

\ (set-os-envs) { array } { } <effect> set-primitive-effect

\ do-primitive [ \ do-primitive cannot-infer-effect ] +infer+ set-word-prop

\ dll-valid? { object } { object } <effect> set-primitive-effect

\ modify-code-heap { array object } { } <effect> set-primitive-effect

\ unimplemented { } { } <effect> set-primitive-effect
