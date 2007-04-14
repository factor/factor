! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors arrays bit-arrays byte-arrays
classes sequences.private continuations.private effects
float-arrays generic hashtables hashtables.private
inference.state inference.backend inference.dataflow io
io.backend io.files io.files.private io.streams.c kernel
kernel.private math math.private memory namespaces
namespaces.private parser prettyprint quotations
quotations.private sbufs sbufs.private sequences
sequences.private slots.private strings strings.private system
threads.private tuples tuples.private vectors vectors.private
words words.private assocs inspector compiler.units
system.private ;
IN: inference.known-words

! Shuffle words
: infer-shuffle-inputs ( shuffle node -- )
    >r effect-in length 0 r> node-inputs ;

: shuffle-stacks ( shuffle -- )
    meta-d [ swap shuffle ] change ;

: infer-shuffle-outputs ( shuffle node -- )
    >r effect-out length 0 r> node-outputs ;

: infer-shuffle ( shuffle -- )
    dup effect-in ensure-values
    #shuffle
    2dup infer-shuffle-inputs
    over shuffle-stacks
    2dup infer-shuffle-outputs
    node, drop ;

: define-shuffle ( word shuffle -- )
    [ infer-shuffle ] curry "infer" set-word-prop ;

{
    { drop  T{ effect f 1 {             } } }
    { 2drop T{ effect f 2 {             } } }
    { 3drop T{ effect f 3 {             } } }
    { dup   T{ effect f 1 { 0 0         } } }
    { 2dup  T{ effect f 2 { 0 1 0 1     } } }
    { 3dup  T{ effect f 3 { 0 1 2 0 1 2 } } }
    { rot   T{ effect f 3 { 1 2 0       } } }
    { -rot  T{ effect f 3 { 2 0 1       } } }
    { dupd  T{ effect f 2 { 0 0 1       } } }
    { swapd T{ effect f 3 { 1 0 2       } } }
    { nip   T{ effect f 2 { 1           } } }
    { 2nip  T{ effect f 3 { 2           } } }
    { tuck  T{ effect f 2 { 1 0 1       } } }
    { over  T{ effect f 2 { 0 1 0       } } }
    { pick  T{ effect f 3 { 0 1 2 0     } } }
    { swap  T{ effect f 2 { 1 0         } } }
} [ define-shuffle ] assoc-each

\ >r [ infer->r ] "infer" set-word-prop

\ r> [ infer-r> ] "infer" set-word-prop

\ declare [
    1 ensure-values
    pop-literal nip
    dup ensure-values
    dup length d-tail
    swap #declare
    [ 2dup set-node-in-d set-node-out-d ] keep
    node,
] "infer" set-word-prop

! Primitive combinators
GENERIC: infer-call ( value -- )

M: value infer-call
    drop
    1 #drop node,
    pop-d infer-quot-value ;

M: curried infer-call
    infer-uncurry peek-d infer-call ;

M: composed infer-call
    infer-uncurry
    infer->r peek-d infer-call
    terminated? get [ infer-r> peek-d infer-call ] unless ;

M: object infer-call
    \ literal-expected inference-warning ;

\ call [
    1 ensure-values
    peek-d infer-call
] "infer" set-word-prop

\ execute [
    1 ensure-values
    pop-literal nip
    dup word? [
        apply-object
    ] [
        drop
        "execute must be given a word" time-bomb
    ] if
] "infer" set-word-prop

\ if [
    3 ensure-values
    2 d-tail [ special? ] contains? [
        [ rot [ drop call ] [ nip call ] if ]
        recursive-state get infer-quot
    ] [
        [ #values ]
        2 #drop node, pop-d pop-d swap 2array
        [ #if ] infer-branches
    ] if
] "infer" set-word-prop

\ dispatch [
    2 ensure-values
    [ gensym #return ]
    pop-literal nip [ <value> ] map
    [ #dispatch ] infer-branches
] "infer" set-word-prop

\ curry [
    2 ensure-values
    pop-d pop-d swap <curried> push-d
] "infer" set-word-prop

\ compose [
    2 ensure-values
    pop-d pop-d swap <composed> push-d
] "infer" set-word-prop

! Variadic tuple constructor
\ <tuple-boa> [
    \ <tuple-boa>
    peek-d value-literal layout-size { tuple } <effect>
    make-call-node
] "infer" set-word-prop

! Non-standard control flow
\ (throw) [
    \ (throw)
    peek-d value-literal 2 + { } <effect>
    t over set-effect-terminated?
    make-call-node
] "infer" set-word-prop

:  set-primitive-effect ( word effect -- )
    2dup effect-out "default-output-classes" set-word-prop
    dupd [ make-call-node ] 2curry "infer" set-word-prop ;

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

\ exists? { string } { object } <effect> set-primitive-effect

\ (directory) { string } { array } <effect> set-primitive-effect

\ data-gc { } { } <effect> set-primitive-effect

\ code-gc { } { } <effect> set-primitive-effect

\ gc-time { } { integer } <effect> set-primitive-effect

\ save-image { string } { } <effect> set-primitive-effect

\ save-image-and-exit { string } { } <effect> set-primitive-effect

\ exit { integer } { } <effect>
t over set-effect-terminated?
set-primitive-effect

\ data-room { } { integer array } <effect> set-primitive-effect
\ data-room make-flushable

\ code-room { } { integer integer } <effect> set-primitive-effect
\ code-room  make-flushable

\ os-env { string } { object } <effect> set-primitive-effect

\ millis { } { integer } <effect> set-primitive-effect
\ millis make-flushable

\ type { object } { fixnum } <effect> set-primitive-effect
\ type make-foldable

\ tag { object } { fixnum } <effect> set-primitive-effect
\ tag make-foldable

\ class-hash { object } { fixnum } <effect> set-primitive-effect
\ class-hash make-foldable

\ cwd { } { string } <effect> set-primitive-effect

\ cd { string } { } <effect> set-primitive-effect

\ dlopen { string } { dll } <effect> set-primitive-effect

\ dlsym { string object } { c-ptr } <effect> set-primitive-effect

\ dlclose { dll } { } <effect> set-primitive-effect

\ <byte-array> { integer } { byte-array } <effect> set-primitive-effect
\ <byte-array> make-flushable

\ <bit-array> { integer } { bit-array } <effect> set-primitive-effect
\ <bit-array> make-flushable

\ <float-array> { integer float } { float-array } <effect> set-primitive-effect
\ <float-array> make-flushable

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

\ alien>char-string { c-ptr } { string } <effect> set-primitive-effect
\ alien>char-string make-flushable

\ string>char-alien { string } { byte-array } <effect> set-primitive-effect
\ string>char-alien make-flushable

\ alien>u16-string { c-ptr } { string } <effect> set-primitive-effect
\ alien>u16-string make-flushable

\ string>u16-alien { string } { byte-array } <effect> set-primitive-effect
\ string>u16-alien make-flushable

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

\ resize-bit-array { integer bit-array } { bit-array } <effect> set-primitive-effect
\ resize-bit-array make-flushable

\ resize-float-array { integer float-array } { float-array } <effect> set-primitive-effect
\ resize-float-array make-flushable

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

\ expired? { object } { object } <effect> set-primitive-effect
\ expired? make-flushable

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

\ (set-os-envs) { array } { } <effect> set-primitive-effect

\ do-primitive [ \ do-primitive no-effect ] "infer" set-word-prop

\ dll-valid? { object } { object } <effect> set-primitive-effect

\ modify-code-heap { array object } { } <effect> set-primitive-effect
