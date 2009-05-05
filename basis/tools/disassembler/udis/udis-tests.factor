IN: tools.disassembler.udis.tests
USING: tools.disassembler.udis tools.test alien.c-types system combinators kernel ;

{
    { [ os linux? cpu x86.64? and ] [ [ 656 ] [ "ud" heap-size ] unit-test ] }
    { [ os macosx? cpu x86.32? and ] [ [ 592 ] [ "ud" heap-size ] unit-test ] }
    { [ os macosx? cpu x86.64? and ] [ [ 656 ] [ "ud" heap-size ] unit-test ] }
    [ ]
} cond