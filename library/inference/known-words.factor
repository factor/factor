IN: inference
USING: arrays alien assembler errors generic hashtables
interpreter io io-internals kernel kernel-internals lists math
math-internals memory parser sequences strings vectors words
prettyprint ;

! We transform calls to these words into 'branched' forms;
! eg, there is no VOP for fixnum<=, only fixnum<= followed
! by an #if, so if we have a 'bare' fixnum<= we add
! [ t ] [ f ] if at the end.

! This transformation really belongs in the optimizer, but it
! is simpler to do it here.
\ fixnum< [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum< t "flushable" set-word-prop
\ fixnum< t "foldable" set-word-prop

\ fixnum<= [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum<= t "flushable" set-word-prop
\ fixnum<= t "foldable" set-word-prop

\ fixnum> [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum> t "flushable" set-word-prop
\ fixnum> t "foldable" set-word-prop

\ fixnum>= [ [ fixnum fixnum ] [ object ] ] "infer-effect" set-word-prop
\ fixnum>= t "flushable" set-word-prop
\ fixnum>= t "foldable" set-word-prop

\ eq? [ [ object object ] [ object ] ] "infer-effect" set-word-prop
\ eq? t "flushable" set-word-prop
\ eq? t "foldable" set-word-prop

: manual-branch ( word -- )
    dup "infer-effect" word-prop consume/produce
    [ [ t ] [ f ] if ] infer-quot ;

{ fixnum<= fixnum< fixnum>= fixnum> eq? } [
    dup dup literalize [ manual-branch ] cons
    "infer" set-word-prop
] each

! Primitive combinators
\ call [ [ general-list ] [ ] ] "infer-effect" set-word-prop

\ call [
    pop-literal infer-quot-value
] "infer" set-word-prop

\ execute [ [ word ] [ ] ] "infer-effect" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ if [ [ object general-list general-list ] [ ] ] "infer-effect" set-word-prop

\ if [
    2 #drop node, pop-d pop-d swap 2array
    #if pop-d drop infer-branches
] "infer" set-word-prop

\ cond [ [ object ] [ ] ] "infer-effect" set-word-prop

\ cond [
    pop-literal [ first2 cons ] map reverse-slice
    [ no-cond ] swap alist>quot infer-quot-value
] "infer" set-word-prop

\ dispatch [ [ fixnum array ] [ ] ] "infer-effect" set-word-prop

\ dispatch [
    pop-literal nip [ <literal> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

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

\ string>float [ [ string ] [ float ] ] "infer-effect" set-word-prop
\ string>float t "flushable" set-word-prop
\ string>float t "foldable" set-word-prop

\ float>string [ [ float ] [ string ] ] "infer-effect" set-word-prop
\ float>string t "flushable" set-word-prop
\ float>string t "foldable" set-word-prop

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

\ bignum= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
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

\ bignum< [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum< t "flushable" set-word-prop
\ bignum< t "foldable" set-word-prop

\ bignum<= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum<= t "flushable" set-word-prop
\ bignum<= t "foldable" set-word-prop

\ bignum> [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum> t "flushable" set-word-prop
\ bignum> t "foldable" set-word-prop

\ bignum>= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
\ bignum>= t "flushable" set-word-prop
\ bignum>= t "foldable" set-word-prop

\ float= [ [ bignum bignum ] [ object ] ] "infer-effect" set-word-prop
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

\ float< [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float< t "flushable" set-word-prop
\ float< t "foldable" set-word-prop

\ float<= [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float<= t "flushable" set-word-prop
\ float<= t "foldable" set-word-prop

\ float> [ [ float float ] [ object ] ] "infer-effect" set-word-prop
\ float> t "flushable" set-word-prop
\ float> t "foldable" set-word-prop

\ float>= [ [ float float ] [ object ] ] "infer-effect" set-word-prop
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
\ compiled? [ [ word ] [ object ] ] "infer-effect" set-word-prop

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

\ char-slot [ [ fixnum object ] [ fixnum ] ] "infer-effect" set-word-prop
\ char-slot t "flushable" set-word-prop

\ set-char-slot [ [ integer fixnum object ] [ ] ] "infer-effect" set-word-prop
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
\ expired? [ [ object ] [ object ] ] "infer-effect" set-word-prop

\ <wrapper> [ [ object ] [ wrapper ] ] "infer-effect" set-word-prop
\ <wrapper> t "flushable" set-word-prop
\ <wrapper> t "foldable" set-word-prop

\ (clone) [ [ object ] [ object ] ] "infer-effect" set-word-prop
\ (clone) t "flushable" set-word-prop

\ (array>tuple) [ [ array ] [ tuple ] ] "infer-effect" set-word-prop
\ (array>tuple) t "flushable" set-word-prop

\ tuple>array [ [ tuple ] [ array ] ] "infer-effect" set-word-prop
\ tuple>array t "flushable" set-word-prop

\ array>vector [ [ array ] [ vector ] ] "infer-effect" set-word-prop
\ array>vector t "flushable" set-word-prop

\ datastack [ [ ] [ vector ] ] "infer-effect" set-word-prop
\ set-datastack [ [ vector ] [ ] ] "infer-effect" set-word-prop

\ callstack [ [ ] [ vector ] ] "infer-effect" set-word-prop
\ set-callstack [ [ vector ] [ ] ] "infer-effect" set-word-prop

\ c-stack [
    "c-stack cannot be compiled (yet)" throw
] "infer" set-word-prop

\ set-c-stack [
    "set-c-stack cannot be compiled (yet)" throw
] "infer" set-word-prop

\ flush-icache [ [ ] [ ] ] "infer-effect" set-word-prop
