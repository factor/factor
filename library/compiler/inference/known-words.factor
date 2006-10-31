IN: inference
USING: arrays alien assembler errors generic hashtables
hashtables-internals io io-internals kernel
kernel-internals math math-internals memory parser
sequences strings vectors words prettyprint ;

\ declare [
    pop-literal nip
    dup length ensure-values
    dup length d-tail
    swap #declare
    [ 2dup set-node-in-d set-node-out-d ] keep
    node,
] "infer" set-word-prop
\ declare { object } { } <effect> "infer-effect" set-word-prop

\ fixnum< { fixnum fixnum } { object } <effect> "infer-effect" set-word-prop
\ fixnum< t "foldable" set-word-prop

\ fixnum<= { fixnum fixnum } { object } <effect> "infer-effect" set-word-prop
\ fixnum<= t "foldable" set-word-prop

\ fixnum> { fixnum fixnum } { object } <effect> "infer-effect" set-word-prop
\ fixnum> t "foldable" set-word-prop

\ fixnum>= { fixnum fixnum } { object } <effect> "infer-effect" set-word-prop
\ fixnum>= t "foldable" set-word-prop

\ eq? { object object } { object } <effect> "infer-effect" set-word-prop
\ eq? t "foldable" set-word-prop

! Primitive combinators
\ call { object } { } <effect> "infer-effect" set-word-prop

\ call [ pop-literal infer-quot-value ] "infer" set-word-prop

\ execute { word } { } <effect> "infer-effect" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ if { object object object } { } <effect> "infer-effect" set-word-prop

\ if [
    2 #drop node, pop-d pop-d swap 2array
    #if pop-d drop infer-branches
] "infer" set-word-prop

\ cond { object } { } <effect> "infer-effect" set-word-prop

\ cond [
    pop-literal <reversed>
    [ no-cond ] swap alist>quot infer-quot-value
] "infer" set-word-prop

\ dispatch { fixnum array } { } <effect> "infer-effect" set-word-prop

\ dispatch [
    pop-literal nip [ <value> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

! Non-standard control flow
\ throw { object } { } <effect>
t over set-effect-terminated?
"infer-effect" set-word-prop

! Stack effects for all primitives
\ rehash-string { string } { } <effect> "infer-effect" set-word-prop

\ string>sbuf { string } { sbuf } <effect> "infer-effect" set-word-prop

\ >fixnum { real } { fixnum } <effect> "infer-effect" set-word-prop
\ >fixnum t "foldable" set-word-prop

\ >bignum { real } { bignum } <effect> "infer-effect" set-word-prop
\ >bignum t "foldable" set-word-prop

\ >float { real } { float } <effect> "infer-effect" set-word-prop
\ >float t "foldable" set-word-prop

\ (fraction>) { integer integer } { rational } <effect> "infer-effect" set-word-prop
\ (fraction>) t "foldable" set-word-prop

\ string>float { string } { float } <effect> "infer-effect" set-word-prop
\ string>float t "foldable" set-word-prop

\ float>string { float } { string } <effect> "infer-effect" set-word-prop
\ float>string t "foldable" set-word-prop

\ float>bits { real } { integer } <effect> "infer-effect" set-word-prop
\ float>bits t "foldable" set-word-prop

\ double>bits { real } { integer } <effect> "infer-effect" set-word-prop
\ double>bits t "foldable" set-word-prop

\ bits>float { integer } { float } <effect> "infer-effect" set-word-prop
\ bits>float t "foldable" set-word-prop

\ bits>double { integer } { float } <effect> "infer-effect" set-word-prop
\ bits>double t "foldable" set-word-prop

\ <complex> { real real } { number } <effect> "infer-effect" set-word-prop
\ <complex> t "foldable" set-word-prop

\ fixnum+ { fixnum fixnum } { integer } <effect> "infer-effect" set-word-prop
\ fixnum+ t "foldable" set-word-prop

\ fixnum+fast { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum+fast t "foldable" set-word-prop

\ fixnum- { fixnum fixnum } { integer } <effect> "infer-effect" set-word-prop
\ fixnum- t "foldable" set-word-prop

\ fixnum-fast { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-fast t "foldable" set-word-prop

\ fixnum* { fixnum fixnum } { integer } <effect> "infer-effect" set-word-prop
\ fixnum* t "foldable" set-word-prop

\ fixnum/i { fixnum fixnum } { integer } <effect> "infer-effect" set-word-prop
\ fixnum/i t "foldable" set-word-prop

\ fixnum/f { fixnum fixnum } { float } <effect> "infer-effect" set-word-prop
\ fixnum/f t "foldable" set-word-prop

\ fixnum-mod { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-mod t "foldable" set-word-prop

\ fixnum/mod { fixnum fixnum } { integer fixnum } <effect> "infer-effect" set-word-prop
\ fixnum/mod t "foldable" set-word-prop

\ fixnum-bitand { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-bitand t "foldable" set-word-prop

\ fixnum-bitor { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-bitor t "foldable" set-word-prop

\ fixnum-bitxor { fixnum fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-bitxor t "foldable" set-word-prop

\ fixnum-bitnot { fixnum } { fixnum } <effect> "infer-effect" set-word-prop
\ fixnum-bitnot t "foldable" set-word-prop

\ fixnum-shift { fixnum fixnum } { integer } <effect> "infer-effect" set-word-prop
\ fixnum-shift t "foldable" set-word-prop

\ bignum= { bignum bignum } { object } <effect> "infer-effect" set-word-prop
\ bignum= t "foldable" set-word-prop

\ bignum+ { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum+ t "foldable" set-word-prop

\ bignum- { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum- t "foldable" set-word-prop

\ bignum* { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum* t "foldable" set-word-prop

\ bignum/i { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum/i t "foldable" set-word-prop

\ bignum/f { bignum bignum } { float } <effect> "infer-effect" set-word-prop
\ bignum/f t "foldable" set-word-prop

\ bignum-mod { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-mod t "foldable" set-word-prop

\ bignum/mod { bignum bignum } { bignum bignum } <effect> "infer-effect" set-word-prop
\ bignum/mod t "foldable" set-word-prop

\ bignum-bitand { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-bitand t "foldable" set-word-prop

\ bignum-bitor { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-bitor t "foldable" set-word-prop

\ bignum-bitxor { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-bitxor t "foldable" set-word-prop

\ bignum-bitnot { bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-bitnot t "foldable" set-word-prop

\ bignum-shift { bignum bignum } { bignum } <effect> "infer-effect" set-word-prop
\ bignum-shift t "foldable" set-word-prop

\ bignum< { bignum bignum } { object } <effect> "infer-effect" set-word-prop
\ bignum< t "foldable" set-word-prop

\ bignum<= { bignum bignum } { object } <effect> "infer-effect" set-word-prop
\ bignum<= t "foldable" set-word-prop

\ bignum> { bignum bignum } { object } <effect> "infer-effect" set-word-prop
\ bignum> t "foldable" set-word-prop

\ bignum>= { bignum bignum } { object } <effect> "infer-effect" set-word-prop
\ bignum>= t "foldable" set-word-prop

\ float+ { float float } { float } <effect> "infer-effect" set-word-prop
\ float+ t "foldable" set-word-prop

\ float- { float float } { float } <effect> "infer-effect" set-word-prop
\ float- t "foldable" set-word-prop

\ float* { float float } { float } <effect> "infer-effect" set-word-prop
\ float* t "foldable" set-word-prop

\ float/f { float float } { float } <effect> "infer-effect" set-word-prop
\ float/f t "foldable" set-word-prop

\ float< { float float } { object } <effect> "infer-effect" set-word-prop
\ float< t "foldable" set-word-prop

\ float-mod { float float } { float } <effect> "infer-effect" set-word-prop
\ float-mod t "foldable" set-word-prop

\ float<= { float float } { object } <effect> "infer-effect" set-word-prop
\ float<= t "foldable" set-word-prop

\ float> { float float } { object } <effect> "infer-effect" set-word-prop
\ float> t "foldable" set-word-prop

\ float>= { float float } { object } <effect> "infer-effect" set-word-prop
\ float>= t "foldable" set-word-prop

\ (word) { object object } { word } <effect> "infer-effect" set-word-prop

\ update-xt { word } { } <effect> "infer-effect" set-word-prop

\ word-xt { word } { integer } <effect> "infer-effect" set-word-prop

\ getenv { fixnum } { object } <effect> "infer-effect" set-word-prop
\ setenv { object fixnum } { } <effect> "infer-effect" set-word-prop
\ stat { string } { object object object object } <effect> "infer-effect" set-word-prop
\ (directory) { string } { array } <effect> "infer-effect" set-word-prop
\ data-gc { integer } { } <effect> "infer-effect" set-word-prop

! code-gc does not declare a stack effect since it might be
! called from a compiled word which becomes unreachable during
! the course of its execution, resulting in a crash

\ gc-time { } { integer } <effect> "infer-effect" set-word-prop
\ save-image { string } { } <effect> "infer-effect" set-word-prop
\ exit { integer } { } <effect> "infer-effect" set-word-prop
\ data-room { } { integer integer array } <effect> "infer-effect" set-word-prop
\ code-room { } { integer integer } <effect> "infer-effect" set-word-prop
\ os-env { string } { object } <effect> "infer-effect" set-word-prop
\ millis { } { integer } <effect> "infer-effect" set-word-prop

\ type { object } { fixnum } <effect> "infer-effect" set-word-prop
\ type t "foldable" set-word-prop

\ tag { object } { fixnum } <effect> "infer-effect" set-word-prop
\ tag t "foldable" set-word-prop

\ cwd { } { string } <effect> "infer-effect" set-word-prop
\ cd { string } { } <effect> "infer-effect" set-word-prop

\ dlopen { string } { dll } <effect> "infer-effect" set-word-prop
\ dlsym { string object } { integer } <effect> "infer-effect" set-word-prop
\ dlclose { dll } { } <effect> "infer-effect" set-word-prop

\ <byte-array> { integer } { byte-array } <effect> "infer-effect" set-word-prop

\ <displaced-alien> { integer c-ptr } { c-ptr } <effect> "infer-effect" set-word-prop

\ alien-signed-cell { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-signed-cell { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-unsigned-cell { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-unsigned-cell { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-signed-8 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-signed-8 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-unsigned-8 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-unsigned-8 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-signed-4 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-signed-4 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-unsigned-4 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-unsigned-4 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-signed-2 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-signed-2 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-unsigned-2 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-unsigned-2 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-signed-1 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-signed-1 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-unsigned-1 { c-ptr integer } { integer } <effect> "infer-effect" set-word-prop

\ set-alien-unsigned-1 { integer c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-float { c-ptr integer } { float } <effect> "infer-effect" set-word-prop

\ set-alien-float { float c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-float { c-ptr integer } { float } <effect> "infer-effect" set-word-prop

\ set-alien-double { float c-ptr integer } { } <effect> "infer-effect" set-word-prop
\ alien-double { c-ptr integer } { float } <effect> "infer-effect" set-word-prop

\ alien>char-string { c-ptr } { string } <effect> "infer-effect" set-word-prop

\ string>char-alien { string } { byte-array } <effect> "infer-effect" set-word-prop

\ alien>u16-string { c-ptr } { string } <effect> "infer-effect" set-word-prop

\ string>u16-alien { string } { byte-array } <effect> "infer-effect" set-word-prop

\ string>memory { string integer } { } <effect> "infer-effect" set-word-prop
\ memory>string { integer integer } { string } <effect> "infer-effect" set-word-prop

\ alien-address { alien } { integer } <effect> "infer-effect" set-word-prop

\ slot { object fixnum } { object } <effect> "infer-effect" set-word-prop

\ set-slot { object object fixnum } { } <effect> "infer-effect" set-word-prop

\ char-slot { fixnum object } { fixnum } <effect> "infer-effect" set-word-prop

\ set-char-slot { fixnum fixnum object } { } <effect> "infer-effect" set-word-prop
\ resize-array { integer array } { array } <effect> "infer-effect" set-word-prop
\ resize-string { integer string } { string } <effect> "infer-effect" set-word-prop

\ (hashtable) { } { hashtable } <effect> "infer-effect" set-word-prop

\ <array> { integer object } { array } <effect> "infer-effect" set-word-prop

\ <tuple> { integer word } { tuple } <effect> "infer-effect" set-word-prop

\ begin-scan { } { } <effect> "infer-effect" set-word-prop
\ next-object { } { object } <effect> "infer-effect" set-word-prop
\ end-scan { } { } <effect> "infer-effect" set-word-prop

\ size { object } { fixnum } <effect> "infer-effect" set-word-prop

\ die { } { } <effect> "infer-effect" set-word-prop
\ fopen { string string } { alien } <effect> "infer-effect" set-word-prop
\ fgetc { alien } { object } <effect> "infer-effect" set-word-prop
\ fwrite { string alien } { } <effect> "infer-effect" set-word-prop
\ fflush { alien } { } <effect> "infer-effect" set-word-prop
\ fclose { alien } { } <effect> "infer-effect" set-word-prop
\ expired? { object } { object } <effect> "infer-effect" set-word-prop

\ <wrapper> { object } { wrapper } <effect> "infer-effect" set-word-prop
\ <wrapper> t "foldable" set-word-prop

\ (clone) { object } { object } <effect> "infer-effect" set-word-prop

\ become { object fixnum } { object } <effect> "infer-effect" set-word-prop

\ array>vector { array } { vector } <effect> "infer-effect" set-word-prop

\ finalize-compile { array } { } <effect> "infer-effect" set-word-prop

\ <string> { integer integer } { string } <effect> "infer-effect" set-word-prop

\ <quotation> { integer } { quotation } <effect> "infer-effect" set-word-prop
