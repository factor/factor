IN: inference

! Primitive combinators
\ call [
    pop-literal infer-quot-value
] "infer" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

\ ifte [
    2 #drop node, pop-d pop-d swap 2vector
    #ifte pop-d drop infer-branches
] "infer" set-word-prop

\ dispatch [
    pop-literal nip [ <literal> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop

! Stack manipulation
\ >r [
    \ >r #call
    1 0 pick node-inputs
    pop-d push-r
    0 1 pick node-outputs
    node,
] "infer" set-word-prop

\ r> [
    \ r> #call
    0 1 pick node-inputs
    pop-r push-d
    1 0 pick node-outputs
    node,
] "infer" set-word-prop

\ drop [ 1 #drop node, pop-d drop ] "infer" set-word-prop
\ dup  [ \ dup  infer-shuffle ] "infer" set-word-prop
\ swap [ \ swap infer-shuffle ] "infer" set-word-prop
\ over [ \ over infer-shuffle ] "infer" set-word-prop
\ pick [ \ pick infer-shuffle ] "infer" set-word-prop

! Type conversion
{
    { >boolean boolean      }
    { >list    general-list }
    { >bignum  bignum       }
    { >fixnum  fixnum       }
    { >float   float        }
    { >sbuf    sbuf         }
    { >string  string       }
    { >vector  vector       }
} [ 2unseq "converter" set-word-prop ] each

! These hacks will go away soon
\ delegate [ [ object ] [ object ] ] "infer-effect" set-word-prop
\ no-method t "terminator" set-word-prop
\ no-method [ [ object word ] [ ] ] "infer-effect" set-word-prop
\ <no-method> [ [ object object ] [ tuple ] ] "infer-effect" set-word-prop
\ set-no-method-generic [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ set-no-method-object [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ not-a-number t "terminator" set-word-prop
\ inference-error t "terminator" set-word-prop
\ throw t "terminator" set-word-prop
\ = [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ integer/ [ [ integer integer ] [ rational ] ] "infer-effect" set-word-prop
\ gcd [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
\ car [ [ general-list ] [ object ] ] "infer-effect" set-word-prop
\ cdr [ [ general-list ] [ object ] ] "infer-effect" set-word-prop
\ < [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ <= [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ > [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ >= [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ number= [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ + [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ - [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ * [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ / [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ /i [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ /f [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ mod [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ /mod [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
\ bitand [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitor [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitxor [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ shift [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitnot [ [ integer ] [ integer ] ] "infer-effect" set-word-prop
\ real [ [ number ] [ real ] ] "infer-effect" set-word-prop
\ imaginary [ [ number ] [ real ] ] "infer-effect" set-word-prop
