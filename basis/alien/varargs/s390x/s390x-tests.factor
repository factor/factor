USING: accessors alien alien.accessors alien.c-types alien.data
alien.varargs alien.varargs.private arrays classes.struct continuations
kernel libc locals namespaces sequences system tools.test ;
IN: alien.varargs.s390x.tests

STRUCT: small-va-aggregate { value uint } ;
STRUCT: large-va-aggregate { x longlong } { y longlong } ;
STRUCT: float-va-aggregate { value float } ;

:: with-s390x-va-memory ( quot -- )
    1 512 calloc :> mem
    [ [ mem quot call ] with-va-scope ] [ mem free ] finally ; inline

:: s390x-cursor ( mem -- cursor )
    256 mem <displaced-alien> 56 mem <displaced-alien>
    160 mem <displaced-alien> -40 -32 s390x <platform-va-cursor> ;

{ 11 22 } [
    [| mem |
        11 mem 52 set-alien-signed-4 22 mem 260 set-alien-signed-4
        mem s390x-cursor -8 >>gr-offs :> cursor
        cursor int va-arg cursor int va-arg
    ] with-s390x-va-memory
] unit-test

{ 1.5 2.5 3.5 } [
    [| mem |
        1.5 mem 144 set-alien-double 2.5 mem 152 set-alien-double
        3.5 mem 256 set-alien-double
        mem s390x-cursor -16 >>vr-offs :> cursor
        cursor double va-arg cursor double va-arg cursor double va-arg
    ] with-s390x-va-memory
] unit-test

{ 42 3.25 } [
    [| mem |
        42 mem 20 set-alien-unsigned-4 3.25 mem 128 set-alien-float
        mem s390x-cursor :> cursor
        cursor small-va-aggregate va-arg value>>
        cursor float-va-aggregate va-arg value>>
    ] with-s390x-va-memory
] unit-test

{ 123 456 } [
    [| mem |
        320 mem <displaced-alien> mem 16 set-alien-cell
        123 mem 320 set-alien-signed-8 456 mem 328 set-alien-signed-8
        mem s390x-cursor large-va-aggregate va-arg
        [ x>> ] [ y>> ] bi
    ] with-s390x-va-memory
] unit-test

{ 2 1 t t } [
    [| mem |
        mem s390x-cursor -24 >>gr-offs -24 >>vr-offs
        s390x-cursor>native-va-list :> native
        native 0 alien-signed-8 native 8 alien-signed-8
        native s390x-native-va-list>cursor :> copied
        copied gr-offs>> -24 = copied vr-offs>> -24 =
    ] with-s390x-va-memory
] unit-test

{ 6.5 } [
    [| mem |
        6.5 mem 260 set-alien-float
        mem s390x-cursor 0 >>vr-offs float-va-aggregate va-arg value>>
    ] with-s390x-va-memory
] unit-test
