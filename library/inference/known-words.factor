IN: inference
USING: alien assembler errors generic hashtables interpreter io
io-internals kernel kernel-internals lists math math-internals
memory parser sequences strings vectors words prettyprint ;

! Primitive combinators
\ call [ [ general-list ] [ ] ] "infer-effect" set-word-prop

\ call [
    pop-literal infer-quot-value
] "infer" set-word-prop

\ execute [ [ word ] [ ] ] "infer-effect" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ ifte [ [ object general-list general-list ] [ ] ] "infer-effect" set-word-prop

\ ifte [
    2 #drop node, pop-d pop-d swap 2vector
    #ifte pop-d drop infer-branches
] "infer" set-word-prop

\ cond [ [ object ] [ ] ] "infer-effect" set-word-prop

\ cond [
    pop-literal [ 2unseq cons ] map
    [ no-cond ] swap alist>quot infer-quot-value
] "infer" set-word-prop

\ dispatch [ [ fixnum vector ] [ ] ] "infer-effect" set-word-prop

\ dispatch [
    pop-literal nip [ <literal> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

! Stack manipulation
\ >r [ [ object ] [ ] ] "infer-effect" set-word-prop

\ >r [
    \ >r #call
    1 0 pick node-inputs
    pop-d push-r
    0 1 pick node-outputs
    node,
] "infer" set-word-prop

\ r> [ [ ] [ object ] ] "infer-effect" set-word-prop

\ r> [
    \ r> #call
    0 1 pick node-inputs
    pop-r push-d
    1 0 pick node-outputs
    node,
] "infer" set-word-prop

\ drop [ 1 #drop node, pop-d drop ] "infer" set-word-prop
\ drop [ [ object ] [ ] ] "infer-effect" set-word-prop

\ dup  [ \ dup  infer-shuffle ] "infer" set-word-prop
\ dup [ [ object ] [ object object ] ] "infer-effect" set-word-prop

\ swap [ \ swap infer-shuffle ] "infer" set-word-prop
\ swap [ [ object object ] [ object object ] ] "infer-effect" set-word-prop

\ over [ \ over infer-shuffle ] "infer" set-word-prop
\ over [ [ object object ] [ object object object ] ] "infer-effect" set-word-prop

\ pick [ \ pick infer-shuffle ] "infer" set-word-prop
\ pick [ [ object object object ] [ object object object object ] ] "infer-effect" set-word-prop

! Non-standard control flow
\ throw [ [ object ] [ ] ] "infer-effect" set-word-prop

\ throw [
    \ throw dup "infer-effect" word-prop consume/produce
    terminate
] "infer" set-word-prop

! Stack effects for all primitives
\ cons [ [ object object ] [ cons ] ] "infer-effect" set-word-prop
\ cons t "foldable" set-word-prop
\ cons t "flushable" set-word-prop

\ <vector> [ [ integer ] [ vector ] ] "infer-effect" set-word-prop
\ <vector> t "flushable" set-word-prop

\ rehash-string [ [ string ] [ ] ] "infer-effect" set-word-prop

\ <sbuf> [ [ integer ] [ sbuf ] ] "infer-effect" set-word-prop
\ <sbuf> t "flushable" set-word-prop

\ sbuf>string [ [ sbuf ] [ string ] ] "infer-effect" set-word-prop
\ sbuf>string t "flushable" set-word-prop

\ >fixnum [ [ number ] [ fixnum ] ] "infer-effect" set-word-prop
\ >fixnum t "flushable" set-word-prop
\ >fixnum t "foldable" set-word-prop

\ >bignum [ [ number ] [ bignum ] ] "infer-effect" set-word-prop
\ >bignum t "flushable" set-word-prop
\ >bignum t "foldable" set-word-prop

\ >float [ [ number ] [ float ] ] "infer-effect" set-word-prop
\ >float t "flushable" set-word-prop
\ >float t "foldable" set-word-prop

\ (fraction>) [ [ integer integer ] [ rational ] ] "infer-effect" set-word-prop
\ (fraction>) t "flushable" set-word-prop
\ (fraction>) t "foldable" set-word-prop

\ str>float [ [ string ] [ float ] ] "infer-effect" set-word-prop
\ str>float t "flushable" set-word-prop
\ str>float t "foldable" set-word-prop

\ (unparse-float) [ [ float ] [ string ] ] "infer-effect" set-word-prop
\ (unparse-float) t "flushable" set-word-prop
\ (unparse-float) t "foldable" set-word-prop

\ float>bits [ [ real ] [ integer ] ] "infer-effect" set-word-prop
\ float>bits t "flushable" set-word-prop
\ float>bits t "foldable" set-word-prop

\ double>bits [ [ real ] [ integer ] ] "infer-effect" set-word-prop
\ double>bits t "flushable" set-word-prop
\ double>bits t "foldable" set-word-prop

\ bits>float [ [ integer ] [ float ] ] "infer-effect" set-word-prop
\ bits>float t "flushable" set-word-prop
\ bits>float t "foldable" set-word-prop

\ bits>double [ [ integer ] [ float ] ] "infer-effect" set-word-prop
\ bits>double t "flushable" set-word-prop
\ bits>double t "foldable" set-word-prop

\ <complex> [ [ real real ] [ number ] ] "infer-effect" set-word-prop
\ <complex> t "flushable" set-word-prop
\ <complex> t "foldable" set-word-prop

\ fixnum+ [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum+ t "flushable" set-word-prop
\ fixnum+ t "foldable" set-word-prop

\ fixnum- [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum- t "flushable" set-word-prop
\ fixnum- t "foldable" set-word-prop

\ fixnum* [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum* t "flushable" set-word-prop
\ fixnum* t "foldable" set-word-prop

\ fixnum/i [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum/i t "flushable" set-word-prop
\ fixnum/i t "foldable" set-word-prop

\ fixnum/f [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum/f t "flushable" set-word-prop
\ fixnum/f t "foldable" set-word-prop

\ fixnum-mod [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-mod t "flushable" set-word-prop
\ fixnum-mod t "foldable" set-word-prop

\ fixnum/mod [ [ fixnum fixnum ] [ integer fixnum ] ] "infer-effect" set-word-prop
\ fixnum/mod t "flushable" set-word-prop
\ fixnum/mod t "foldable" set-word-prop

\ fixnum-bitand [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitand t "flushable" set-word-prop
\ fixnum-bitand t "foldable" set-word-prop

\ fixnum-bitor [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitor t "flushable" set-word-prop
\ fixnum-bitor t "foldable" set-word-prop

\ fixnum-bitxor [ [ fixnum fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitxor t "flushable" set-word-prop
\ fixnum-bitxor t "foldable" set-word-prop

\ fixnum-bitnot [ [ fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ fixnum-bitnot t "flushable" set-word-prop
\ fixnum-bitnot t "foldable" set-word-prop

\ fixnum-shift [ [ fixnum fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ fixnum-shift t "flushable" set-word-prop
\ fixnum-shift t "foldable" set-word-prop

\ fixnum< [ [ fixnum fixnum ] [ boolean ] ] "infer-effect" set-word-prop
\ fixnum< t "flushable" set-word-prop
\ fixnum< t "foldable" set-word-prop

\ fixnum<= [ [ fixnum fixnum ] [ boolean ] ] "infer-effect" set-word-prop
\ fixnum<= t "flushable" set-word-prop
\ fixnum<= t "foldable" set-word-prop

\ fixnum> [ [ fixnum fixnum ] [ boolean ] ] "infer-effect" set-word-prop
\ fixnum> t "flushable" set-word-prop
\ fixnum> t "foldable" set-word-prop

\ fixnum>= [ [ fixnum fixnum ] [ boolean ] ] "infer-effect" set-word-prop
\ fixnum>= t "flushable" set-word-prop
\ fixnum>= t "foldable" set-word-prop

\ bignum= [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ bignum= t "flushable" set-word-prop
\ bignum= t "foldable" set-word-prop

\ bignum+ [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum+ t "flushable" set-word-prop
\ bignum+ t "foldable" set-word-prop

\ bignum- [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum- t "flushable" set-word-prop
\ bignum- t "foldable" set-word-prop

\ bignum* [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum* t "flushable" set-word-prop
\ bignum* t "foldable" set-word-prop

\ bignum/i [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum/i t "flushable" set-word-prop
\ bignum/i t "foldable" set-word-prop

\ bignum/f [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum/f t "flushable" set-word-prop
\ bignum/f t "foldable" set-word-prop

\ bignum-mod [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-mod t "flushable" set-word-prop
\ bignum-mod t "foldable" set-word-prop

\ bignum/mod [ [ bignum bignum ] [ bignum bignum ] ] "infer-effect" set-word-prop
\ bignum/mod t "flushable" set-word-prop
\ bignum/mod t "foldable" set-word-prop

\ bignum-bitand [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitand t "flushable" set-word-prop
\ bignum-bitand t "foldable" set-word-prop

\ bignum-bitor [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitor t "flushable" set-word-prop
\ bignum-bitor t "foldable" set-word-prop

\ bignum-bitxor [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitxor t "flushable" set-word-prop
\ bignum-bitxor t "foldable" set-word-prop

\ bignum-bitnot [ [ bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-bitnot t "flushable" set-word-prop
\ bignum-bitnot t "foldable" set-word-prop

\ bignum-shift [ [ bignum bignum ] [ bignum ] ] "infer-effect" set-word-prop
\ bignum-shift t "flushable" set-word-prop
\ bignum-shift t "foldable" set-word-prop

\ bignum< [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ bignum< t "flushable" set-word-prop
\ bignum< t "foldable" set-word-prop

\ bignum<= [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ bignum<= t "flushable" set-word-prop
\ bignum<= t "foldable" set-word-prop

\ bignum> [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ bignum> t "flushable" set-word-prop
\ bignum> t "foldable" set-word-prop

\ bignum>= [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ bignum>= t "flushable" set-word-prop
\ bignum>= t "foldable" set-word-prop

\ float= [ [ bignum bignum ] [ boolean ] ] "infer-effect" set-word-prop
\ float= t "flushable" set-word-prop
\ float= t "foldable" set-word-prop

\ float+ [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float+ t "flushable" set-word-prop
\ float+ t "foldable" set-word-prop

\ float- [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float- t "flushable" set-word-prop
\ float- t "foldable" set-word-prop

\ float* [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float* t "flushable" set-word-prop
\ float* t "foldable" set-word-prop

\ float/f [ [ float float ] [ float ] ] "infer-effect" set-word-prop
\ float/f t "flushable" set-word-prop
\ float/f t "foldable" set-word-prop

\ float< [ [ float float ] [ boolean ] ] "infer-effect" set-word-prop
\ float< t "flushable" set-word-prop
\ float< t "foldable" set-word-prop

\ float<= [ [ float float ] [ boolean ] ] "infer-effect" set-word-prop
\ float<= t "flushable" set-word-prop
\ float<= t "foldable" set-word-prop

\ float> [ [ float float ] [ boolean ] ] "infer-effect" set-word-prop
\ float> t "flushable" set-word-prop
\ float> t "foldable" set-word-prop

\ float>= [ [ float float ] [ boolean ] ] "infer-effect" set-word-prop
\ float>= t "flushable" set-word-prop
\ float>= t "foldable" set-word-prop

\ facos [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ facos t "flushable" set-word-prop
\ facos t "foldable" set-word-prop

\ fasin [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fasin t "flushable" set-word-prop
\ fasin t "foldable" set-word-prop

\ fatan [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fatan t "flushable" set-word-prop
\ fatan t "foldable" set-word-prop

\ fatan2 [ [ real real ] [ float ] ] "infer-effect" set-word-prop
\ fatan2 t "flushable" set-word-prop
\ fatan2 t "foldable" set-word-prop

\ fcos [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fcos t "flushable" set-word-prop
\ fcos t "foldable" set-word-prop

\ fexp [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fexp t "flushable" set-word-prop
\ fexp t "foldable" set-word-prop

\ fcosh [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fcosh t "flushable" set-word-prop
\ fcosh t "foldable" set-word-prop

\ flog [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ flog t "flushable" set-word-prop
\ flog t "foldable" set-word-prop

\ fpow [ [ real real ] [ float ] ] "infer-effect" set-word-prop
\ fpow t "flushable" set-word-prop
\ fpow t "foldable" set-word-prop

\ fsin [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsin t "flushable" set-word-prop
\ fsin t "foldable" set-word-prop

\ fsinh [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsinh t "flushable" set-word-prop
\ fsinh t "foldable" set-word-prop

\ fsqrt [ [ real ] [ float ] ] "infer-effect" set-word-prop
\ fsqrt t "flushable" set-word-prop
\ fsqrt t "foldable" set-word-prop

\ <word> [ [ object object ] [ word ] ] "infer-effect" set-word-prop
\ <word> t "flushable" set-word-prop

\ update-xt [ [ word ] [ ] ] "infer-effect" set-word-prop
\ compiled? [ [ word ] [ boolean ] ] "infer-effect" set-word-prop

\ eq? [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ eq? t "flushable" set-word-prop
\ eq? t "foldable" set-word-prop

\ getenv [ [ fixnum ] [ object ] ] "infer-effect" set-word-prop
\ setenv [ [ object fixnum ] [ ] ] "infer-effect" set-word-prop
\ stat [ [ string ] [ general-list ] ] "infer-effect" set-word-prop
\ (directory) [ [ string ] [ general-list ] ] "infer-effect" set-word-prop
\ gc [ [ fixnum ] [ ] ] "infer-effect" set-word-prop
\ gc-time [ [ string ] [ ] ] "infer-effect" set-word-prop
\ save-image [ [ string ] [ ] ] "infer-effect" set-word-prop
\ exit [ [ integer ] [ ] ] "infer-effect" set-word-prop
\ room [ [ ] [ integer integer integer integer general-list ] ] "infer-effect" set-word-prop
\ os-env [ [ string ] [ object ] ] "infer-effect" set-word-prop
\ millis [ [ ] [ integer ] ] "infer-effect" set-word-prop
\ (random-int) [ [ ] [ integer ] ] "infer-effect" set-word-prop

\ type [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop
\ type t "flushable" set-word-prop
\ type t "foldable" set-word-prop

\ tag [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop
\ tag t "flushable" set-word-prop
\ tag t "foldable" set-word-prop

\ cwd [ [ ] [ string ] ] "infer-effect" set-word-prop
\ cd [ [ string ] [ ] ] "infer-effect" set-word-prop

\ compiled-offset [ [ ] [ integer ] ] "infer-effect" set-word-prop
\ compiled-offset t "flushable" set-word-prop

\ set-compiled-offset [ [ integer ] [ ] ] "infer-effect" set-word-prop

\ literal-top [ [ ] [ integer ] ] "infer-effect" set-word-prop
\ literal-top t "flushable" set-word-prop

\ set-literal-top [ [ integer ] [ ] ] "infer-effect" set-word-prop

\ address [ [ object ] [ integer ] ] "infer-effect" set-word-prop
\ address t "flushable" set-word-prop

\ dlopen [ [ string ] [ dll ] ] "infer-effect" set-word-prop
\ dlsym [ [ string object ] [ integer ] ] "infer-effect" set-word-prop
\ dlclose [ [ dll ] [ ] ] "infer-effect" set-word-prop

\ <alien> [ [ integer ] [ alien ] ] "infer-effect" set-word-prop
\ <alien> t "flushable" set-word-prop

\ <byte-array> [ [ integer ] [ byte-array ] ] "infer-effect" set-word-prop
\ <byte-array> t "flushable" set-word-prop

\ <displaced-alien> [ [ integer c-ptr ] [ displaced-alien ] ] "infer-effect" set-word-prop
\ <displaced-alien> t "flushable" set-word-prop

\ alien-signed-cell [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-signed-cell t "flushable" set-word-prop

\ set-alien-signed-cell [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-cell [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-unsigned-cell t "flushable" set-word-prop

\ set-alien-unsigned-cell [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-8 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-signed-8 t "flushable" set-word-prop

\ set-alien-signed-8 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-8 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-unsigned-8 t "flushable" set-word-prop

\ set-alien-unsigned-8 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-4 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-signed-4 t "flushable" set-word-prop

\ set-alien-signed-4 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-4 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-unsigned-4 t "flushable" set-word-prop

\ set-alien-unsigned-4 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-2 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-signed-2 t "flushable" set-word-prop

\ set-alien-signed-2 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-2 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-unsigned-2 t "flushable" set-word-prop

\ set-alien-unsigned-2 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-signed-1 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-signed-1 t "flushable" set-word-prop

\ set-alien-signed-1 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-unsigned-1 [ [ c-ptr integer ] [ integer ] ] "infer-effect" set-word-prop
\ alien-unsigned-1 t "flushable" set-word-prop

\ set-alien-unsigned-1 [ [ integer c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-float [ [ c-ptr integer ] [ float ] ] "infer-effect" set-word-prop
\ alien-float t "flushable" set-word-prop

\ set-alien-float [ [ float c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-double [ [ c-ptr integer ] [ float ] ] "infer-effect" set-word-prop
\ alien-double t "flushable" set-word-prop

\ set-alien-double [ [ float c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ alien-c-string [ [ c-ptr integer ] [ string ] ] "infer-effect" set-word-prop
\ alien-c-string t "flushable" set-word-prop

\ set-alien-c-string [ [ string c-ptr integer ] [ ] ] "infer-effect" set-word-prop
\ string>memory [ [ string integer ] [ ] ] "infer-effect" set-word-prop
\ memory>string [ [ integer integer ] [ string ] ] "infer-effect" set-word-prop
\ alien-address [ [ alien ] [ integer ] ] "infer-effect" set-word-prop

\ slot [ [ object fixnum ] [ object ] ] "infer-effect" set-word-prop
\ slot t "flushable" set-word-prop

\ set-slot [ [ object object fixnum ] [ ] ] "infer-effect" set-word-prop

\ integer-slot [ [ object fixnum ] [ integer ] ] "infer-effect" set-word-prop
\ integer-slot t "flushable" set-word-prop

\ set-integer-slot [ [ integer object fixnum ] [ ] ] "infer-effect" set-word-prop

\ char-slot [ [ object fixnum ] [ fixnum ] ] "infer-effect" set-word-prop
\ char-slot t "flushable" set-word-prop

\ set-char-slot [ [ integer object fixnum ] [ ] ] "infer-effect" set-word-prop
\ resize-array [ [ integer array ] [ array ] ] "infer-effect" set-word-prop
\ resize-string [ [ integer string ] [ string ] ] "infer-effect" set-word-prop

\ <hashtable> [ [ number ] [ hashtable ] ] "infer-effect" set-word-prop
\ <hashtable> t "flushable" set-word-prop

\ <array> [ [ number ] [ array ] ] "infer-effect" set-word-prop
\ <array> t "flushable" set-word-prop

\ <tuple> [ [ number ] [ tuple ] ] "infer-effect" set-word-prop
\ <tuple> t "flushable" set-word-prop

\ begin-scan [ [ ] [ ] ] "infer-effect" set-word-prop
\ next-object [ [ ] [ object ] ] "infer-effect" set-word-prop
\ end-scan [ [ ] [ ] ] "infer-effect" set-word-prop

\ size [ [ object ] [ fixnum ] ] "infer-effect" set-word-prop
\ size t "flushable" set-word-prop

\ die [ [ ] [ ] ] "infer-effect" set-word-prop
\ fopen [ [ string string ] [ alien ] ] "infer-effect" set-word-prop
\ fgetc [ [ alien ] [ object ] ] "infer-effect" set-word-prop
\ fwrite [ [ string alien ] [ ] ] "infer-effect" set-word-prop
\ fflush [ [ alien ] [ ] ] "infer-effect" set-word-prop
\ fclose [ [ alien ] [ ] ] "infer-effect" set-word-prop
\ expired? [ [ object ] [ boolean ] ] "infer-effect" set-word-prop

\ <wrapper> [ [ object ] [ wrapper ] ] "infer-effect" set-word-prop
\ <wrapper> t "flushable" set-word-prop
\ <wrapper> t "foldable" set-word-prop
