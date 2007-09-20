! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference.known-words
USING: alien arrays bit-arrays byte-arrays classes
combinators.private continuations.private effects float-arrays
generic hashtables hashtables.private
inference.backend inference.dataflow io io.backend io.files
io.files.private io.streams.c kernel kernel.private math
math.private memory namespaces namespaces.private parser
prettyprint quotations quotations.private sbufs sbufs.private
sequences sequences.private slots.private strings
strings.private system threads.private tuples tuples.private
vectors vectors.private words ;

\ declare [
    1 ensure-values
    pop-literal nip
    dup ensure-values
    dup length d-tail
    swap #declare
    [ 2dup set-node-in-d set-node-out-d ] keep
    node,
] "infer" set-word-prop

\ fixnum< { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum< make-foldable

\ fixnum<= { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum<= make-foldable

\ fixnum> { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum> make-foldable

\ fixnum>= { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum>= make-foldable

\ eq? { object object } { object } <effect> "inferred-effect" set-word-prop
\ eq? make-foldable

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
    infer->r peek-d infer-call infer-r>
    peek-d infer-call ;

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
        [ "execute must be given a word" throw ]
        infer-quot
    ] if
] "infer" set-word-prop

\ if [
    3 ensure-values
    2 d-tail [ special? ] contains? [
        [ rot [ drop call ] [ nip call ] if ] infer-quot
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

\ curry { object object } { curry } <effect> "inferred-effect" set-word-prop

\ compose [
    2 ensure-values
    pop-d pop-d swap <composed> push-d
] "infer" set-word-prop

\ compose { object object } { curry } <effect> "inferred-effect" set-word-prop

! Variadic tuple constructor
\ <tuple-boa> [
    \ <tuple-boa>
    peek-d value-literal { tuple } <effect>
    make-call-node
] "infer" set-word-prop

! We need this for default-output-classes
\ <tuple-boa> 2 { tuple } <effect> "inferred-effect" set-word-prop

! Non-standard control flow
\ (throw) { callable } { } <effect>
t over set-effect-terminated?
"inferred-effect" set-word-prop

! Stack effects for all primitives
\ rehash-string { string } { } <effect> "inferred-effect" set-word-prop

\ string>sbuf { string integer } { sbuf } <effect> "inferred-effect" set-word-prop
\ string>sbuf make-flushable

\ bignum>fixnum { bignum } { fixnum } <effect> "inferred-effect" set-word-prop
\ bignum>fixnum make-foldable

\ float>fixnum { float } { fixnum } <effect> "inferred-effect" set-word-prop
\ bignum>fixnum make-foldable

\ fixnum>bignum { fixnum } { bignum } <effect> "inferred-effect" set-word-prop
\ fixnum>bignum make-foldable

\ float>bignum { float } { bignum } <effect> "inferred-effect" set-word-prop
\ float>bignum make-foldable

\ fixnum>float { fixnum } { float } <effect> "inferred-effect" set-word-prop
\ fixnum>float make-foldable

\ bignum>float { bignum } { float } <effect> "inferred-effect" set-word-prop
\ bignum>float make-foldable

\ <ratio> { integer integer } { ratio } <effect> "inferred-effect" set-word-prop
\ <ratio> make-foldable

\ string>float { string } { float } <effect> "inferred-effect" set-word-prop
\ string>float make-foldable

\ float>string { float } { string } <effect> "inferred-effect" set-word-prop
\ float>string make-foldable

\ float>bits { real } { integer } <effect> "inferred-effect" set-word-prop
\ float>bits make-foldable

\ double>bits { real } { integer } <effect> "inferred-effect" set-word-prop
\ double>bits make-foldable

\ bits>float { integer } { float } <effect> "inferred-effect" set-word-prop
\ bits>float make-foldable

\ bits>double { integer } { float } <effect> "inferred-effect" set-word-prop
\ bits>double make-foldable

\ <complex> { real real } { complex } <effect> "inferred-effect" set-word-prop
\ <complex> make-foldable

\ fixnum+ { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum+ make-foldable

\ fixnum+fast { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum+fast make-foldable

\ fixnum- { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum- make-foldable

\ fixnum-fast { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-fast make-foldable

\ fixnum* { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum* make-foldable

\ fixnum*fast { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum*fast make-foldable

\ fixnum/i { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum/i make-foldable

\ fixnum-mod { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-mod make-foldable

\ fixnum/mod { fixnum fixnum } { integer fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum/mod make-foldable

\ fixnum-bitand { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitand make-foldable

\ fixnum-bitor { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitor make-foldable

\ fixnum-bitxor { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitxor make-foldable

\ fixnum-bitnot { fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitnot make-foldable

\ fixnum-shift { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum-shift make-foldable

\ bignum= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum= make-foldable

\ bignum+ { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum+ make-foldable

\ bignum- { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum- make-foldable

\ bignum* { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum* make-foldable

\ bignum/i { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum/i make-foldable

\ bignum-mod { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-mod make-foldable

\ bignum/mod { bignum bignum } { bignum bignum } <effect> "inferred-effect" set-word-prop
\ bignum/mod make-foldable

\ bignum-bitand { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitand make-foldable

\ bignum-bitor { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitor make-foldable

\ bignum-bitxor { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitxor make-foldable

\ bignum-bitnot { bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitnot make-foldable

\ bignum-shift { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-shift make-foldable

\ bignum< { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum< make-foldable

\ bignum<= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum<= make-foldable

\ bignum> { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum> make-foldable

\ bignum>= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum>= make-foldable

\ bignum-bit? { bignum integer } { object } <effect> "inferred-effect" set-word-prop
\ bignum-bit? make-foldable

\ bignum-log2 { bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-log2 make-foldable

\ byte-array>bignum { byte-array } { bignum } <effect> "inferred-effect" set-word-prop
\ byte-array>bignum make-foldable

\ float= { float float } { object } <effect> "inferred-effect" set-word-prop
\ float= make-foldable

\ float+ { float float } { float } <effect> "inferred-effect" set-word-prop
\ float+ make-foldable

\ float- { float float } { float } <effect> "inferred-effect" set-word-prop
\ float- make-foldable

\ float* { float float } { float } <effect> "inferred-effect" set-word-prop
\ float* make-foldable

\ float/f { float float } { float } <effect> "inferred-effect" set-word-prop
\ float/f make-foldable

\ float< { float float } { object } <effect> "inferred-effect" set-word-prop
\ float< make-foldable

\ float-mod { float float } { float } <effect> "inferred-effect" set-word-prop
\ float-mod make-foldable

\ float<= { float float } { object } <effect> "inferred-effect" set-word-prop
\ float<= make-foldable

\ float> { float float } { object } <effect> "inferred-effect" set-word-prop
\ float> make-foldable

\ float>= { float float } { object } <effect> "inferred-effect" set-word-prop
\ float>= make-foldable

\ <word> { object object } { word } <effect> "inferred-effect" set-word-prop
\ <word> make-flushable

\ update-xt { word } { } <effect> "inferred-effect" set-word-prop

\ word-xt { word } { integer } <effect> "inferred-effect" set-word-prop
\ word-xt make-flushable

\ getenv { fixnum } { object } <effect> "inferred-effect" set-word-prop
\ getenv make-flushable

\ setenv { object fixnum } { } <effect> "inferred-effect" set-word-prop

\ (stat) { string } { object object object object } <effect> "inferred-effect" set-word-prop

\ (directory) { string } { array } <effect> "inferred-effect" set-word-prop

\ data-gc { } { } <effect> "inferred-effect" set-word-prop

\ code-gc { } { } <effect> "inferred-effect" set-word-prop

\ gc-time { } { integer } <effect> "inferred-effect" set-word-prop

\ save-image { string } { } <effect> "inferred-effect" set-word-prop

\ save-image-and-exit { string } { } <effect> "inferred-effect" set-word-prop

\ exit { integer } { } <effect>
t over set-effect-terminated?
"inferred-effect" set-word-prop

\ data-room { } { integer array } <effect> "inferred-effect" set-word-prop
\ data-room make-flushable

\ code-room { } { integer integer } <effect> "inferred-effect" set-word-prop
\ code-room  make-flushable

\ os-env { string } { object } <effect> "inferred-effect" set-word-prop

\ millis { } { integer } <effect> "inferred-effect" set-word-prop
\ millis make-flushable

\ type { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ type make-foldable

\ tag { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ tag make-foldable

\ class-hash { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ class-hash make-foldable

\ cwd { } { string } <effect> "inferred-effect" set-word-prop

\ cd { string } { } <effect> "inferred-effect" set-word-prop

\ dlopen { string } { dll } <effect> "inferred-effect" set-word-prop

\ dlsym { string object } { c-ptr } <effect> "inferred-effect" set-word-prop

\ dlclose { dll } { } <effect> "inferred-effect" set-word-prop

\ <byte-array> { integer } { byte-array } <effect> "inferred-effect" set-word-prop
\ <byte-array> make-flushable

\ <bit-array> { integer } { bit-array } <effect> "inferred-effect" set-word-prop
\ <bit-array> make-flushable

\ <float-array> { integer float } { float-array } <effect> "inferred-effect" set-word-prop
\ <float-array> make-flushable

\ <displaced-alien> { integer c-ptr } { c-ptr } <effect> "inferred-effect" set-word-prop
\ <displaced-alien> make-flushable

\ alien-signed-cell { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-cell { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-unsigned-cell { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-cell { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-signed-8 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-8 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-unsigned-8 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-8 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-signed-4 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-4 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-unsigned-4 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-4 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-signed-2 { c-ptr integer } { fixnum } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-2 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-unsigned-2 { c-ptr integer } { fixnum } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-2 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-signed-1 { c-ptr integer } { fixnum } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-1 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-unsigned-1 { c-ptr integer } { fixnum } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-1 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-float { c-ptr integer } { float } <effect> "inferred-effect" set-word-prop

\ set-alien-float { float c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-double { c-ptr integer } { float } <effect> "inferred-effect" set-word-prop

\ set-alien-double { float c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien-cell { c-ptr integer } { simple-c-ptr } <effect> "inferred-effect" set-word-prop

\ set-alien-cell { c-ptr c-ptr integer } { } <effect> "inferred-effect" set-word-prop

\ alien>char-string { c-ptr } { string } <effect> "inferred-effect" set-word-prop

\ string>char-alien { string } { byte-array } <effect> "inferred-effect" set-word-prop

\ alien>u16-string { c-ptr } { string } <effect> "inferred-effect" set-word-prop

\ string>u16-alien { string } { byte-array } <effect> "inferred-effect" set-word-prop

\ string>memory { string c-ptr } { } <effect> "inferred-effect" set-word-prop

\ memory>string { c-ptr integer } { string } <effect> "inferred-effect" set-word-prop

\ alien-address { alien } { integer } <effect> "inferred-effect" set-word-prop
\ alien-address make-flushable

\ slot { object fixnum } { object } <effect> "inferred-effect" set-word-prop
\ slot make-flushable

\ set-slot { object object fixnum } { } <effect> "inferred-effect" set-word-prop

\ char-slot { fixnum object } { fixnum } <effect> "inferred-effect" set-word-prop
\ char-slot make-flushable

\ set-char-slot { fixnum fixnum object } { } <effect> "inferred-effect" set-word-prop

\ resize-array { integer array } { array } <effect> "inferred-effect" set-word-prop
\ resize-array make-flushable

\ resize-string { integer string } { string } <effect> "inferred-effect" set-word-prop
\ resize-string make-flushable

\ (hashtable) { } { hashtable } <effect> "inferred-effect" set-word-prop
\ (hashtable) make-flushable

\ <array> { integer object } { array } <effect> "inferred-effect" set-word-prop
\ <array> make-flushable

\ begin-scan { } { } <effect> "inferred-effect" set-word-prop

\ next-object { } { object } <effect> "inferred-effect" set-word-prop

\ end-scan { } { } <effect> "inferred-effect" set-word-prop

\ size { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ size make-flushable

\ die { } { } <effect> "inferred-effect" set-word-prop

\ fopen { string string } { alien } <effect> "inferred-effect" set-word-prop

\ fgetc { alien } { object } <effect> "inferred-effect" set-word-prop

\ fwrite { string alien } { } <effect> "inferred-effect" set-word-prop

\ fread { integer string } { object } <effect> "inferred-effect" set-word-prop

\ fflush { alien } { } <effect> "inferred-effect" set-word-prop

\ fclose { alien } { } <effect> "inferred-effect" set-word-prop

\ expired? { object } { object } <effect> "inferred-effect" set-word-prop
\ expired? make-flushable

\ <wrapper> { object } { wrapper } <effect> "inferred-effect" set-word-prop
\ <wrapper> make-foldable

\ (clone) { object } { object } <effect> "inferred-effect" set-word-prop
\ (clone) make-flushable

\ array>vector { array integer } { vector } <effect> "inferred-effect" set-word-prop
\ array>vector make-flushable

\ <string> { integer integer } { string } <effect> "inferred-effect" set-word-prop
\ <string> make-flushable

\ array>quotation { array } { quotation } <effect> "inferred-effect" set-word-prop
\ array>quotation make-flushable

\ quotation-xt { quotation } { integer } <effect> "inferred-effect" set-word-prop
\ quotation-xt make-flushable

\ <tuple> { word integer } { quotation } <effect> "inferred-effect" set-word-prop
\ <tuple> make-flushable

\ (>tuple) { array } { tuple } <effect> "inferred-effect" set-word-prop
\ (>tuple) make-flushable

\ tuple>array { tuple } { array } <effect> "inferred-effect" set-word-prop
\ tuple>array make-flushable

\ datastack { } { array } <effect> "inferred-effect" set-word-prop
\ datastack make-flushable

\ retainstack { } { array } <effect> "inferred-effect" set-word-prop
\ retainstack make-flushable

\ callstack { } { callstack } <effect> "inferred-effect" set-word-prop
\ callstack make-flushable

\ callstack>array { callstack } { array } <effect> "inferred-effect" set-word-prop
\ callstack>array make-flushable

\ array>callstack { array } { callstack } <effect> "inferred-effect" set-word-prop
\ array>callstack make-flushable

\ (sleep) { integer } { } <effect> "inferred-effect" set-word-prop

\ become { array array } { } <effect> "inferred-effect" set-word-prop
