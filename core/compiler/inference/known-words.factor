! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays alien assembler errors generic hashtables
hashtables-internals io io-internals kernel
kernel-internals math math-internals memory parser
sequences strings vectors words prettyprint namespaces ;

\ declare [
    pop-literal nip
    dup ensure-values
    dup length d-tail
    swap #declare
    [ 2dup set-node-in-d set-node-out-d ] keep
    node,
] "infer" set-word-prop
\ declare { object } { } <effect> "inferred-effect" set-word-prop

\ fixnum< { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum< t "foldable" set-word-prop

\ fixnum<= { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum<= t "foldable" set-word-prop

\ fixnum> { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum> t "foldable" set-word-prop

\ fixnum>= { fixnum fixnum } { object } <effect> "inferred-effect" set-word-prop
\ fixnum>= t "foldable" set-word-prop

\ eq? { object object } { object } <effect> "inferred-effect" set-word-prop
\ eq? t "foldable" set-word-prop

! Primitive combinators
\ call { object } { } <effect> "inferred-effect" set-word-prop

\ call [ pop-literal infer-quot-value ] "infer" set-word-prop

\ execute { word } { } <effect> "inferred-effect" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ if { object object object } { } <effect> "inferred-effect" set-word-prop

\ if [
    2 #drop node, pop-d pop-d swap 2array
    #if pop-d drop infer-branches
] "infer" set-word-prop

\ cond { object } { } <effect> "inferred-effect" set-word-prop

\ cond [
    pop-literal <reversed>
    [ no-cond ] swap alist>quot infer-quot-value
] "infer" set-word-prop

\ dispatch { fixnum array } { } <effect> "inferred-effect" set-word-prop

\ dispatch [
    pop-literal nip [ <value> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

! Non-standard control flow
\ throw { object } { } <effect>
t over set-effect-terminated?
"inferred-effect" set-word-prop

! Stack effects for all primitives
\ rehash-string { string } { } <effect> "inferred-effect" set-word-prop

\ string>sbuf { string } { sbuf } <effect> "inferred-effect" set-word-prop

\ bignum>fixnum { bignum } { fixnum } <effect> "inferred-effect" set-word-prop
\ bignum>fixnum t "foldable" set-word-prop

\ float>fixnum { float } { fixnum } <effect> "inferred-effect" set-word-prop
\ bignum>fixnum t "foldable" set-word-prop

\ fixnum>bignum { fixnum } { bignum } <effect> "inferred-effect" set-word-prop
\ fixnum>bignum t "foldable" set-word-prop

\ float>bignum { float } { bignum } <effect> "inferred-effect" set-word-prop
\ float>bignum t "foldable" set-word-prop

\ fixnum>float { fixnum } { float } <effect> "inferred-effect" set-word-prop
\ fixnum>float t "foldable" set-word-prop

\ bignum>float { bignum } { float } <effect> "inferred-effect" set-word-prop
\ bignum>float t "foldable" set-word-prop

\ (fraction>) { integer integer } { rational } <effect> "inferred-effect" set-word-prop
\ (fraction>) t "foldable" set-word-prop

\ string>float { string } { float } <effect> "inferred-effect" set-word-prop
\ string>float t "foldable" set-word-prop

\ float>string { float } { string } <effect> "inferred-effect" set-word-prop
\ float>string t "foldable" set-word-prop

\ float>bits { real } { integer } <effect> "inferred-effect" set-word-prop
\ float>bits t "foldable" set-word-prop

\ double>bits { real } { integer } <effect> "inferred-effect" set-word-prop
\ double>bits t "foldable" set-word-prop

\ bits>float { integer } { float } <effect> "inferred-effect" set-word-prop
\ bits>float t "foldable" set-word-prop

\ bits>double { integer } { float } <effect> "inferred-effect" set-word-prop
\ bits>double t "foldable" set-word-prop

\ <complex> { real real } { number } <effect> "inferred-effect" set-word-prop
\ <complex> t "foldable" set-word-prop

\ fixnum+ { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum+ t "foldable" set-word-prop

\ fixnum+fast { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum+fast t "foldable" set-word-prop

\ fixnum- { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum- t "foldable" set-word-prop

\ fixnum-fast { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-fast t "foldable" set-word-prop

\ fixnum* { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum* t "foldable" set-word-prop

\ fixnum/i { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum/i t "foldable" set-word-prop

\ fixnum-mod { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-mod t "foldable" set-word-prop

\ fixnum/mod { fixnum fixnum } { integer fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum/mod t "foldable" set-word-prop

\ fixnum-bitand { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitand t "foldable" set-word-prop

\ fixnum-bitor { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitor t "foldable" set-word-prop

\ fixnum-bitxor { fixnum fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitxor t "foldable" set-word-prop

\ fixnum-bitnot { fixnum } { fixnum } <effect> "inferred-effect" set-word-prop
\ fixnum-bitnot t "foldable" set-word-prop

\ fixnum-shift { fixnum fixnum } { integer } <effect> "inferred-effect" set-word-prop
\ fixnum-shift t "foldable" set-word-prop

\ bignum= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum= t "foldable" set-word-prop

\ bignum+ { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum+ t "foldable" set-word-prop

\ bignum- { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum- t "foldable" set-word-prop

\ bignum* { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum* t "foldable" set-word-prop

\ bignum/i { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum/i t "foldable" set-word-prop

\ bignum-mod { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-mod t "foldable" set-word-prop

\ bignum/mod { bignum bignum } { bignum bignum } <effect> "inferred-effect" set-word-prop
\ bignum/mod t "foldable" set-word-prop

\ bignum-bitand { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitand t "foldable" set-word-prop

\ bignum-bitor { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitor t "foldable" set-word-prop

\ bignum-bitxor { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitxor t "foldable" set-word-prop

\ bignum-bitnot { bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-bitnot t "foldable" set-word-prop

\ bignum-shift { bignum bignum } { bignum } <effect> "inferred-effect" set-word-prop
\ bignum-shift t "foldable" set-word-prop

\ bignum< { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum< t "foldable" set-word-prop

\ bignum<= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum<= t "foldable" set-word-prop

\ bignum> { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum> t "foldable" set-word-prop

\ bignum>= { bignum bignum } { object } <effect> "inferred-effect" set-word-prop
\ bignum>= t "foldable" set-word-prop

\ float+ { float float } { float } <effect> "inferred-effect" set-word-prop
\ float+ t "foldable" set-word-prop

\ float- { float float } { float } <effect> "inferred-effect" set-word-prop
\ float- t "foldable" set-word-prop

\ float* { float float } { float } <effect> "inferred-effect" set-word-prop
\ float* t "foldable" set-word-prop

\ float/f { float float } { float } <effect> "inferred-effect" set-word-prop
\ float/f t "foldable" set-word-prop

\ float< { float float } { object } <effect> "inferred-effect" set-word-prop
\ float< t "foldable" set-word-prop

\ float-mod { float float } { float } <effect> "inferred-effect" set-word-prop
\ float-mod t "foldable" set-word-prop

\ float<= { float float } { object } <effect> "inferred-effect" set-word-prop
\ float<= t "foldable" set-word-prop

\ float> { float float } { object } <effect> "inferred-effect" set-word-prop
\ float> t "foldable" set-word-prop

\ float>= { float float } { object } <effect> "inferred-effect" set-word-prop
\ float>= t "foldable" set-word-prop

\ (word) { object object } { word } <effect> "inferred-effect" set-word-prop

\ update-xt { word } { } <effect> "inferred-effect" set-word-prop

\ word-xt { word } { integer } <effect> "inferred-effect" set-word-prop

\ getenv { fixnum } { object } <effect> "inferred-effect" set-word-prop
\ setenv { object fixnum } { } <effect> "inferred-effect" set-word-prop
\ stat { string } { object object object object } <effect> "inferred-effect" set-word-prop
\ (directory) { string } { array } <effect> "inferred-effect" set-word-prop
\ data-gc { integer } { } <effect> "inferred-effect" set-word-prop

! code-gc does not declare a stack effect since it might be
! called from a compiled word which becomes unreachable during
! the course of its execution, resulting in a crash

\ gc-time { } { integer } <effect> "inferred-effect" set-word-prop
\ save-image { string } { } <effect> "inferred-effect" set-word-prop
\ exit { integer } { } <effect> "inferred-effect" set-word-prop
\ data-room { } { integer integer array } <effect> "inferred-effect" set-word-prop
\ code-room { } { integer integer } <effect> "inferred-effect" set-word-prop
\ os-env { string } { object } <effect> "inferred-effect" set-word-prop
\ millis { } { integer } <effect> "inferred-effect" set-word-prop

\ type { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ type t "foldable" set-word-prop

\ tag { object } { fixnum } <effect> "inferred-effect" set-word-prop
\ tag t "foldable" set-word-prop

\ cwd { } { string } <effect> "inferred-effect" set-word-prop
\ cd { string } { } <effect> "inferred-effect" set-word-prop

\ dlopen { string } { dll } <effect> "inferred-effect" set-word-prop
\ dlsym { string object } { integer } <effect> "inferred-effect" set-word-prop
\ dlclose { dll } { } <effect> "inferred-effect" set-word-prop

\ <byte-array> { integer } { byte-array } <effect> "inferred-effect" set-word-prop

\ <displaced-alien> { integer c-ptr } { c-ptr } <effect> "inferred-effect" set-word-prop

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
\ alien-signed-2 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-2 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-unsigned-2 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-2 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-signed-1 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-signed-1 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-unsigned-1 { c-ptr integer } { integer } <effect> "inferred-effect" set-word-prop

\ set-alien-unsigned-1 { integer c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-float { c-ptr integer } { float } <effect> "inferred-effect" set-word-prop

\ set-alien-float { float c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-float { c-ptr integer } { float } <effect> "inferred-effect" set-word-prop

\ set-alien-double { float c-ptr integer } { } <effect> "inferred-effect" set-word-prop
\ alien-double { c-ptr integer } { float } <effect> "inferred-effect" set-word-prop

\ alien>char-string { c-ptr } { string } <effect> "inferred-effect" set-word-prop

\ string>char-alien { string } { byte-array } <effect> "inferred-effect" set-word-prop

\ alien>u16-string { c-ptr } { string } <effect> "inferred-effect" set-word-prop

\ string>u16-alien { string } { byte-array } <effect> "inferred-effect" set-word-prop

\ string>memory { string integer } { } <effect> "inferred-effect" set-word-prop
\ memory>string { integer integer } { string } <effect> "inferred-effect" set-word-prop

\ alien-address { alien } { integer } <effect> "inferred-effect" set-word-prop

\ slot { object fixnum } { object } <effect> "inferred-effect" set-word-prop

\ set-slot { object object fixnum } { } <effect> "inferred-effect" set-word-prop

\ char-slot { fixnum object } { fixnum } <effect> "inferred-effect" set-word-prop

\ set-char-slot { fixnum fixnum object } { } <effect> "inferred-effect" set-word-prop
\ resize-array { integer array } { array } <effect> "inferred-effect" set-word-prop
\ resize-string { integer string } { string } <effect> "inferred-effect" set-word-prop

\ (hashtable) { } { hashtable } <effect> "inferred-effect" set-word-prop

\ <array> { integer object } { array } <effect> "inferred-effect" set-word-prop

\ begin-scan { } { } <effect> "inferred-effect" set-word-prop
\ next-object { } { object } <effect> "inferred-effect" set-word-prop
\ end-scan { } { } <effect> "inferred-effect" set-word-prop

\ size { object } { fixnum } <effect> "inferred-effect" set-word-prop

\ die { } { } <effect> "inferred-effect" set-word-prop
\ fopen { string string } { alien } <effect> "inferred-effect" set-word-prop
\ fgetc { alien } { object } <effect> "inferred-effect" set-word-prop
\ fwrite { string alien } { } <effect> "inferred-effect" set-word-prop
\ fflush { alien } { } <effect> "inferred-effect" set-word-prop
\ fclose { alien } { } <effect> "inferred-effect" set-word-prop
\ expired? { object } { object } <effect> "inferred-effect" set-word-prop

\ <wrapper> { object } { wrapper } <effect> "inferred-effect" set-word-prop
\ <wrapper> t "foldable" set-word-prop

\ (clone) { object } { object } <effect> "inferred-effect" set-word-prop

\ become { object fixnum } { object } <effect> "inferred-effect" set-word-prop

\ array>vector { array } { vector } <effect> "inferred-effect" set-word-prop

\ finalize-compile { array } { } <effect> "inferred-effect" set-word-prop

\ <string> { integer integer } { string } <effect> "inferred-effect" set-word-prop

\ <quotation> { integer } { quotation } <effect> "inferred-effect" set-word-prop

! Dynamic scope inference
: if-tos-literal ( quot -- )
    peek-d dup value? [ value-literal swap call ] [ 2drop ] if ;
    inline

\ >n [ H{ } clone push-n ] "infer-vars" set-word-prop

\ >n { object } { } <effect> "inferred-effect" set-word-prop

TUPLE: too-many-n> ;

: apply-n> ( -- )
    meta-n get empty? [
        <too-many-n>> inference-error
    ] [
        pop-n drop
    ] if ;

\ n> [ apply-n> ] "infer-vars" set-word-prop

\ n> { } { object } <effect> "inferred-effect" set-word-prop

\ ndrop [ apply-n> ] "infer-vars" set-word-prop

\ ndrop { } { } <effect> "inferred-effect" set-word-prop

\ get [
    [ apply-var-read ] if-tos-literal
] "infer-vars" set-word-prop

\ get { object } { object } <effect> "inferred-effect" set-word-prop

\ set [
    [ apply-var-write ] if-tos-literal
] "infer-vars" set-word-prop

\ set { object object } { } <effect> "inferred-effect" set-word-prop

\ get-global [
    [ apply-global-read ]
    if-tos-literal
] "infer-vars" set-word-prop

\ get-global { object } { object } <effect> "inferred-effect" set-word-prop

\ set-global [
    [ apply-global-write ]
    if-tos-literal
] "infer-vars" set-word-prop

\ set-global { object object } { } <effect> "inferred-effect" set-word-prop
