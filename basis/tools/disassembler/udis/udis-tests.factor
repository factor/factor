IN: tools.disassembler.udis.tests
USING: tools.disassembler.udis tools.test alien.c-types system combinators kernel ;

{
    {
        [ cpu x86.32? ]
        [
            os windows?
            [ [ 624 ] [ ud heap-size ] unit-test ]
            [ [ 604 ] [ ud heap-size ] unit-test ] if
        ]
    }
    { [ cpu x86.64? ] [ [ 672 ] [ ud heap-size ] unit-test ] }
    [ ]
} cond