! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.libraries alien.syntax
continuations kernel math sequences tools.test ;
IN: compiler.tests.mach-exception-ports

CONSTANT: MACH_PORT_RIGHT_SEND 0

FUNCTION: int mach_port_get_refs ( uint task, uint name, uint right, uint* refs )

: mach-task-self ( -- port )
    "mach_task_self_" f dlsym uint deref ;

: task-send-refs ( -- n )
    mach-task-self dup MACH_PORT_RIGHT_SEND
    { uint } [ mach_port_get_refs drop ] with-out-parameters ;

: datastack-underflow ( -- )
    [ { } [ drop ] with-datastack drop ] [ drop ] recover ;

{ t } [
    task-send-refs
    100 [ datastack-underflow ] times
    task-send-refs swap - 10 <
] unit-test
