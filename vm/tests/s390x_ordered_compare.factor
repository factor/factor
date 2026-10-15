USING: compiler compiler.units continuations io kernel kernel.private literals
locals math math.floats.env math.floats.env.private math.private sequences ;
IN: s390x.fpc.ordered
: ordered ( a b -- ? ) float< ;
: quiet ( a b -- ? ) float-u< ;
{ ordered quiet } compile
{ } { } +round-nearest+ +denormal-keep+ set-fp-env
[ 0x7ff8000000000001 bits>double 1.0 ordered ] collect-fp-exceptions nip
+fp-invalid-operation+ swap member? [ "ORDERED-NAN-INVALID-PASS" print ] [ "missing invalid flag" throw ] if
[ 0x7ff8000000000001 bits>double 1.0 quiet ] collect-fp-exceptions nip
+fp-invalid-operation+ swap member? [ "quiet comparison raised invalid" throw ] [ "QUIET-NAN-NO-INVALID-PASS" print ] if
[ { +fp-invalid-operation+ } [ 0x7ff8000000000001 bits>double 1.0 ordered ] with-fp-traps drop "missing ordered trap" throw ]
[ 2 head ${ KERNEL-ERROR ERROR-FP-TRAP } = [ "ORDERED-NAN-TRAP-PASS" print ] [ "wrong FP trap" throw ] if ] recover
{ } { } +round-nearest+ +denormal-keep+ set-fp-env
