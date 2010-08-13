USING: math.floats.env math.floats.env.x86 tools.test
alien.c-types alien.syntax classes.struct compiler.test
math kernel sequences ;
IN: math.floats.env.x86.tests

! the sqrtl function is really long double sqrtl ( long double x ) 
! calling it as if it had a void return leaves the return value on
! the x87 stack, so 9 calls will be guaranteed to cause a stack
! fault
STRUCT: fake-long-double { x char[20] } ;
FUNCTION-ALIAS: busted-sqrtl
    void sqrtl ( fake-long-double x ) ;

[ t ] [
    [
        [
            9 [ fake-long-double <struct> busted-sqrtl ] times
        ] collect-fp-exceptions
    ] compile-call
    +fp-x87-stack-fault+ swap member?
] unit-test
