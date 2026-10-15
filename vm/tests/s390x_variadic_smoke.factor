! System z native variadic callback smoke. Run with parser:run-file;
! runtime-compile-call deliberately supports quotations with varying effects.
USING: alien alien.c-types alien.libraries alien.syntax alien.varargs
arrays compiler.units io io.pathnames kernel locals math memory sequences stack-checker words ;
FROM: alien.c-types => float short ;
IN: s390x.variadic.smoke
<< "systemz-va-test" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: systemz-va-test
FUNCTION: longlong va_call_ints ( void* cb, int count )
CALLBACK: longlong int-reader ( int count, ... )
:: read-ints ( count args -- sum )
    count <iota> [ 1 + args int va-arg * ] map sum ;
: runtime-compile-call ( quot -- )
    [ dup infer define-temp ] with-compilation-unit execute ;
<< \ runtime-compile-call t "no-compile" set-word-prop >>
[ [ read-ints ] int-reader [ 7 va_call_ints ] with-callback ] runtime-compile-call
-28 = [ "S390X-VARIADIC-INT7-PASS" print ] [ "varargs mismatch" throw ] if
[ [ gc read-ints ] int-reader [ 12 va_call_ints ] with-callback ] runtime-compile-call
78 = [ "S390X-VARIADIC-GC12-PASS" print ] [ "varargs GC mismatch" throw ] if
FUNCTION: double va_call_mixed ( void* cb )
FUNCTION: double va_call_named_spill ( void* cb )
:: read-mixed ( tag named args -- result )
    10 <iota> [| i | i 1 + args int va-arg * i 11 + args double va-arg * + ] map sum
    tag + named + ;
[ double { int double } cdecl [ gc read-mixed ] alien-callback-varargs
  [ va_call_mixed ] with-callback ] runtime-compile-call
1259.75 = [ "S390X-VARIADIC-MIXED-GC-PASS" print ] [ "mixed varargs mismatch" throw ] if
CALLBACK: double named-spill-reader (
    int a, int b, int c, int d, int e, int f, int g, int h, int i, int j,
    ... char k, float l, longlong m, short n )
[ [| a b c d e f g h i j k l m n |
    a b + c + d + e + f + g + h + i + j + k + l 2 * + m 3 * + n 4 * +
  ] named-spill-reader [ va_call_named_spill ] with-callback ] runtime-compile-call
86.0 = [ "S390X-VARIADIC-NAMED-SPILL-PASS" print ] [ "named varargs mismatch" throw ] if

FUNCTION: longlong va_call_list ( void* cb, int count )
CALLBACK: longlong list-reader ( int count, va_list args )
[ [ gc read-ints ] list-reader
  [ 12 va_call_list ] with-callback ] runtime-compile-call
78 = [ "S390X-NATIVE-VA-LIST-GC-PASS" print ] [ "native va_list mismatch" throw ] if

USING: accessors classes.struct alien.arrays ;
STRUCT: z-pair { x float } { y float } ;
STRUCT: z-ints { x int } { y int } ;
STRUCT: z-big { x longlong } { y longlong } { z longlong } ;
STRUCT: z-array { values float[3] } ;
FUNCTION: double va_call_aggregates ( void* cb )
:: read-aggregates ( tag args -- result )
 args z-pair va-arg :> p
 args z-ints va-arg :> i
 args z-big va-arg :> b
 args z-array va-arg values>> :> a
 args longlong va-arg :> sentinel
 tag p x>> + p y>> 2 * + i x>> 3 * + i y>> 4 * +
 b x>> 5 * + b y>> 6 * + b z>> 7 * +
 a first 8 * + a second 9 * + a third 10 * + sentinel 11 * + ;
[ double { int } cdecl [ gc read-aggregates ] alien-callback-varargs
 [ va_call_aggregates ] with-callback ] runtime-compile-call
5.0 = [ "S390X-VARIADIC-AGGREGATES-GC-PASS" print ] [ "aggregate mismatch" throw ] if

FUNCTION: longlong va_sum_list ( int count, va_list args )
:: forward-list ( count args -- result )
 gc count args va_sum_list count args read-ints + ;
[ [ forward-list ] list-reader [ 12 va_call_list ] with-callback ] runtime-compile-call
156 = [ "S390X-NATIVE-VA-LIST-FORWARD-PASS" print ] [ "va_list forwarding mismatch" throw ] if
FUNCTION: longlong va_call_big_return ( void* cb )
CALLBACK: z-big big-reader ( int count, ... )
[ [| count args |
 count drop z-big <struct>
 args longlong va-arg >>x args longlong va-arg >>y args longlong va-arg >>z
 [ gc read-ints ] int-reader [ 12 va_call_ints ] with-callback drop gc
 ] big-reader [ va_call_big_return ] with-callback ] runtime-compile-call
-15769158013578 = [ "S390X-VARIADIC-HIDDEN-RETURN-PASS" print ] [ "hidden return mismatch" throw ] if
FUNCTION: double va_call_pair_return ( void* cb )
CALLBACK: z-pair pair-reader ( int count, ... double x, double y )
[ [| count x y | count drop z-pair <struct> x >>x y >>y ]
 pair-reader [ va_call_pair_return ] with-callback ] runtime-compile-call
-3.75 = [ "S390X-VARIADIC-PAIR-RETURN-PASS" print ] [ "pair return mismatch" throw ] if
