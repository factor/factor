IN: tools.disassembler.udis.tests
USING: tools.disassembler.udis tools.test alien.c-types system combinators kernel ;

{
    { [ cpu x86.32? ] [ [ 604 ] [ ud heap-size ] unit-test ] }
    { [ cpu x86.64? ] [ [ 672 ] [ ud heap-size ] unit-test ] }
    [ ]
} cond