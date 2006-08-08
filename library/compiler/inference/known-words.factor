IN: inference
USING: arrays alien assembler errors generic hashtables
hashtables-internals interpreter io io-internals kernel
kernel-internals math math-internals memory parser
sequences strings vectors words prettyprint ;

\ declare [
    pop-literal nip
    dup length ensure-values
    dup #declare [ >r length d-tail r> set-node-in-d ] keep
    node,
] "infer" set-word-prop
\ declare [ [ object ] [ ] ] "infer-effect" set-word-prop

\ fixnum< [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum< t "foldable" set-word-prop

\ fixnum<= [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum<= t "foldable" set-word-prop

\ fixnum> [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum> t "foldable" set-word-prop

\ fixnum>= [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum>= t "foldable" set-word-prop

\ eq? [ [ object object ] [ object ] ] "infer-effect" set-word-prop
\ eq? t "foldable" set-word-prop

! Primitive combinators
\ call [ [ object ] [ ] ] "infer-effect" set-word-prop

\ call [ pop-literal infer-quot-value ] "infer" set-word-prop

\ execute [ [ word ] [ ] ] "infer-effect" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ if [ [ object object object ] [ ] ] "infer-effect" set-word-prop

\ if [
    2 #drop node, pop-d pop-d swap 2array
    #if pop-d drop infer-branches
] "infer" set-word-prop

\ cond [ [ object ] [ ] ] "infer-effect" set-word-prop

\ cond [
    pop-literal <reversed>
    [ no-cond ] swap alist>quot infer-quot-value
] "infer" set-word-prop

\ dispatch [ [ fixnum array ] [ ] ] "infer-effect" set-word-prop

\ dispatch [
    pop-literal nip [ <value> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

! Non-standard control flow
\ throw [ [ object ] [ ] ] "infer-effect" set-word-prop

\ throw [
    \ throw dup "infer-effect" word-prop consume/produce
    terminate
] "infer" set-word-prop

! Stack effects for all primitives
\ <vector> [ [ integer ] [ vector ] ] "infer-effect" set-word-prop

\ rehash-string [ [ string ] [ ] ] "infer-effect" set-word-prop

\ <sbuf> [ [ integer ] [ sbuf ] ] "infer-effect" set-word-prop

\ >fixnum [ [ real ] [ fixnum ] ] "infer-effect" set-word-prop
\ >fixnum t "foldable" set-word-prop

\ >bignum [ [ real ] [ bignum ] ] "infer-effect" set-word-prop
\ >bignum t "foldable" set-word-prop

\ >float [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ >float t "foldable" set-word-prop

\ (fraction>) [ [ integer integer ] [ rational ] ] "infer-effect" set-word-prop
\ (fraction>) t "foldable" set-word-prop

\ string>float [ [ string ] [ float ] ] "infer-effect" set-word-prop
\ string>float t "foldable" set-word-prop

\ float>string [ [ float ] [ string ] ] "infer-effect" set-word-prop
\ float>string t "foldable" set-word-prop

\ float>bits [ [ real ] [ integer ] ] "infer-effect" set-word-prop
\ float>bits t "foldable" set-word-prop

\ double>bits [ [ real ] [ integer ] ] "infer-effect" set-word-prop
\ double>bits t "foldable" set-word-prop

\ bits>float [ [ integer ] [ float ] ] "infer-effect" set-word-prop
\ bits>float t "foldable" set-word-prop

\ bits>double [ [ integer ] [ float ] ] "infer-effect" set-word-prop
\ bits>double t "foldable" set-word-prop

\ <complex> [ [ real real ] [ number ] ] "infer-effect" set-word-prop
\ <complex> t "foldable" set-word-prop

\ fixnum+ [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum+ t "foldable" set-word-prop

\ fixnum+fast [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum+fast t "foldable" set-word-prop

\ fixnum- [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum- t "foldable" set-word-prop

\ fixnum-fast [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-fast t "foldable" set-word-prop

\ fixnum* [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum* t "foldable" set-word-prop

\ fixnum/i [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum/i t "foldable" set-word-prop

\ fixnum/f [ [ fixnum fixnum ] [ float ] ] "infer-effect" set-word-prop
\ fixnum/f t "foldable" set-word-prop

\ fixnum-mod [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-mod t "foldable" set-word-prop

\ fixnum/mod [ [ fixnum fixnum ] [ integer fixnum ] ] "infer-effect" set-word-prop
\ fixnum/mod t "foldable" set-word-prop

\ fixnum-bitand [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitand t "foldable" set-word-prop

\ fixnum-bitor [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitor t "foldable" set-word-prop

\ fixnum-bitxor [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitxor t "foldable" set-word-prop

\ fixnum-bitnot [ [ fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitnot t "foldable" set-word-prop

\ fixnum-shift [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum-shift t "foldable" set-word-prop

\ bignum= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum= t "foldable" set-word-prop

\ bignum+ [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum+ t "foldable" set-word-prop

\ bignum- [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum- t "foldable" set-word-prop

\ bignum* [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum* t "foldable" set-word-prop

\ bignum/i [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum/i t "foldable" set-word-prop

\ bignum/f [ [ bignum bignum ] [ float ] ] "infer-effect" set-word-prop
\ bignum/f t "foldable" set-word-prop

\ bignum-mod [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-mod t "foldable" set-word-prop

\ bignum/mod [ [ bignum bignum ] [ bignum bignum ] ] "infer-effect" set-word-prop
\ bignum/mod t "foldable" set-word-prop

\ bignum-bitand [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitand t "foldable" set-word-prop

\ bignum-bitor [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitor t "foldable" set-word-prop

\ bignum-bitxor [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitxor t "foldable" set-word-prop

\ bignum-bitnot [ [ bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitnot t "foldable" set-word-prop

\ bignum-shift [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-shift t "foldable" set-word-prop

\ bignum< [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum< t "foldable" set-word-prop

\ bignum<= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum<= t "foldable" set-word-prop

\ bignum> [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum> t "foldable" set-word-prop

\ bignum>= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum>= t "foldable" set-word-prop

\ float+ [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float+ t "foldable" set-word-prop

\ float- [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float- t "foldable" set-word-prop

\ float* [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float* t "foldable" set-word-prop

\ float/f [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float/f t "foldable" set-word-prop

\ float< [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float< t "foldable" set-word-prop

\ float-mod [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float-mod t "foldable" set-word-prop

\ float<= [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float<= t "foldable" set-word-prop

\ float> [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float> t "foldable" set-word-prop

\ float>= [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float>= t "foldable" set-word-prop

\ facos [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ facos t "foldable" set-word-prop

\ fasin [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fasin t "foldable" set-word-prop

\ fatan [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fatan t "foldable" set-word-prop

\ fatan2 [ [ real real ] [ float ] ] "infer-effect" set-word-prop
\ fatan2 t "foldable" set-word-prop

\ fcos [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fcos t "foldable" set-word-prop

\ fexp [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fexp t "foldable" set-word-prop

\ fcosh [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fcosh t "foldable" set-word-prop

\ flog [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ flog t "foldable" set-word-prop

\ fpow [ [ real real ] [ float ] ] "infer-effect" set-word-prop
\ fpow t "foldable" set-word-prop

\ fsin [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsin t "foldable" set-word-prop

\ fsinh [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsinh t "foldable" set-word-prop

\ fsqrt [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsqrt t "foldable" set-word-prop

\ (word) [ [ object object ] [ word ] ] "infer-effect" set-word-prop

\ update-xt [ [ word ] [ ] ] "infer-effect" set-word-prop
\ compiled? [ [ word ] [ object ] ] "infer-effect" set-word-prop

\ getenv [ [ fixnum ] [ object ] ] "infer-effect" set-word-prop
\ setenv [ [ object fixnum ] [ ] ] "infer-effect" set-word-prop
\ stat [ [ string ] [ object ] ] "infer-effect" set-word-prop
\ (directory) [ [ string ] [ array ] ] "infer-effect" set-word-prop
\ gc [ [ integer ] [ ] ] "infer-effect" set-word-prop
\ gc-time [ [ ] [ integer ] ] "infer-effect" set-word-prop
\ save-image [ [ string ] [ ] ] "infer-effect" set-word-prop
\ exit [ [ integer ] [ ] ] "infer-effect" set-word-prop
\ room [ [ ] [ integer integer integer integer array ] ] "infer-effect" set-word-prop
\ os-env [ [ string ] [ object ] ] "infer-effect" set-word-prop
\ millis [ [ ] [ integer ] ] "infer-effect" set-word-prop

\ type [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop
\ type t "foldable" set-word-prop

\ tag [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop
\ tag t "foldable" set-word-prop

\ cwd [ [ ] [ string ] ] "infer-effect" set-word-prop
\ cd [ [ string ] [ ] ] "infer-effect" set-word-prop

\ add-compiled-block [ [ vector integer vector vector ] [ integer ] ] "infer-effect" set-word-prop

\ dlopen [ [ string ] [ dll ] ] "infer-effect" set-word-prop
\ dlsym [ [ string object ] [ integer ] ] "infer-effect" set-word-prop
\ dlclose [ [ dll ] [ ] ] "infer-effect" set-word-prop

\ <byte-array> [ [ integer ] [ byte-array ] ] "infer-effect" set-word-prop

\ <displaced-alien> [ [ integer c-ptr ] [ c-ptr ] ] "infer-effect" set-word-prop

\ alien-signed-cell [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-signed-cell [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-cell [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-unsigned-cell [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-8 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-signed-8 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-8 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-unsigned-8 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-4 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-signed-4 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-4 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-unsigned-4 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-2 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-signed-2 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-2 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-unsigned-2 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-1 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-signed-1 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-1 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop

\ set-alien-unsigned-1 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-float [ [ c-ptr integer ] [ float ] ] "infer-effect" set-word-prop

\ set-alien-float [ [ float c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-float [ [ c-ptr integer ] [ float ] ] "infer-effect" set-word-prop

\ set-alien-double [ [ float c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-double [ [ c-ptr integer ] [ float ] ] "infer-effect" set-word-prop

\ alien>char-string [ [ c-ptr ] [ string ] ] "infer-effect" set-word-prop

\ string>char-alien [ [ string ] [ byte-array ] ] "infer-effect" set-word-prop

\ alien>u16-string [ [ c-ptr ] [ string ] ] "infer-effect" set-word-prop

\ string>u16-alien [ [ string ] [ byte-array ] ] "infer-effect" set-word-prop

\ string>memory [ [ string integer ] [ ] ] "infer-effect" set-word-prop
\ memory>string [ [ integer integer ] [ string ] ] "infer-effect" set-word-prop

\ alien-address [ [ alien ] [ integer ] ] "infer-effect" set-word-prop

\ slot [ [ object fixnum ] [ object ] ] "infer-effect" set-word-prop

\ set-slot [ [ object object fixnum ] [ ] ] "infer-effect" set-word-prop

\ integer-slot [ [ object fixnum ] [ integer ] ] "infer-effect" set-word-prop

\ set-integer-slot [ [ integer object fixnum ] [ ] ] "infer-effect" set-word-prop

\ char-slot [ [ fixnum object ] [ fixnum ] ] "infer-effect" set-word-prop

\ set-char-slot [ [ fixnum fixnum object ] [ ] ] "infer-effect" set-word-prop
\ resize-array [ [ integer array ] [ array ] ] "infer-effect" set-word-prop
\ resize-string [ [ integer string ] [ string ] ] "infer-effect" set-word-prop

\ (hashtable) [ [ ] [ hashtable ] ] "infer-effect" set-word-prop

\ <array> [ [ integer object ] [ array ] ] "infer-effect" set-word-prop

\ <tuple> [ [ integer word ] [ tuple ] ] "infer-effect" set-word-prop

\ begin-scan [ [ ] [ ] ] "infer-effect" set-word-prop
\ next-object [ [ ] [ object ] ] "infer-effect" set-word-prop
\ end-scan [ [ ] [ ] ] "infer-effect" set-word-prop

\ size [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop

\ die [ [ ] [ ] ] "infer-effect" set-word-prop
\ fopen [ [ string string ] [ alien ] ] "infer-effect" set-word-prop
\ fgetc [ [ alien ] [ object ] ] "infer-effect" set-word-prop
\ fwrite [ [ string alien ] [ ] ] "infer-effect" set-word-prop
\ fflush [ [ alien ] [ ] ] "infer-effect" set-word-prop
\ fclose [ [ alien ] [ ] ] "infer-effect" set-word-prop
\ expired? [ [ object ] [ object ] ] "infer-effect" set-word-prop

\ <wrapper> [ [ object ] [ wrapper ] ] "infer-effect" set-word-prop
\ <wrapper> t "foldable" set-word-prop

\ (clone) [ [ object ] [ object ] ] "infer-effect" set-word-prop

\ array>tuple [ [ array ] [ tuple ] ] "infer-effect" set-word-prop

\ tuple>array [ [ tuple ] [ array ] ] "infer-effect" set-word-prop

\ array>vector [ [ array ] [ vector ] ] "infer-effect" set-word-prop

\ finalize-compile [ [ ] [ ] ] "infer-effect" set-word-prop

\ <string> [ [ integer integer ] [ string ] ] "infer-effect" set-word-prop

\ <quotation> [ [ integer ] [ quotation ] ] "infer-effect" set-word-prop
