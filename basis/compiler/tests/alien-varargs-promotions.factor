USING: accessors alien alien.c-types alien.enums alien.libraries
alien.syntax alien.varargs arrays combinators compiler.test cpu.architecture io.pathnames
kernel locals math namespaces sequences system tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.alien-varargs-promotions

<< "varargs-promotions" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library >>
LIBRARY: varargs-promotions

ENUM: vap-signed-enum < char { vap-negative -7 } ;
ENUM: vap-unsigned-enum < ushort { vap-positive 65530 } ;

FUNCTION-ALIAS: vap-bool int vap_read_integer ( int tag, ... bool value )
FUNCTION-ALIAS: vap-char int vap_read_integer ( int tag, ... char value )
FUNCTION-ALIAS: vap-uchar int vap_read_integer ( int tag, ... uchar value )
FUNCTION-ALIAS: vap-ushort int vap_read_integer ( int tag, ... ushort value )
FUNCTION-ALIAS: vap-signed int vap_read_integer ( int tag, ... vap-signed-enum value )
FUNCTION-ALIAS: vap-unsigned int vap_read_integer ( int tag, ... vap-unsigned-enum value )
FUNCTION-ALIAS: vap-float double vap_read_float ( int tag, ... float value )
FUNCTION: longlong vap_poison ( int tag, ... longlong value )
FUNCTION: int vap_control_integer ( int which )
FUNCTION: double vap_control_float ( )
FUNCTION: double vap_call_reader ( void* callback )

: promotion-unit-test ( expected quot -- ) [ compile-call ] curry unit-test ;

{ { 1 0 -1 255 65535 -7 65530 } } [
    7 <iota> [ vap_control_integer ] map
] promotion-unit-test
{ 1 } [ 0 t vap-bool ] promotion-unit-test
{ 0 } [ 0 f vap-bool ] promotion-unit-test
{ 1 } [ 0 "non-false Factor object" vap-bool ] promotion-unit-test
{ -7 } [ 0 -7 vap-char ] promotion-unit-test
{ -1 } [ 0 255 vap-char ] promotion-unit-test
{ 255 } [ 0 -1 vap-uchar ] promotion-unit-test
{ 65535 } [ 0 -1 vap-ushort ] promotion-unit-test

! Both calls share the compiled quotation's outgoing argument area. Before
! promotion the narrow enum writes leave the preceding slot's high bytes.
{ -7 } [
    0 0x5555555555555555 vap_poison drop 0 vap-negative vap-signed
] promotion-unit-test
{ 65530 } [
    0 0x5555555555555555 vap_poison drop 0 vap-positive vap-unsigned
] promotion-unit-test

! A numeric enum representation still undergoes the same source conversion.
{ -7 } [ 0 -7 vap-signed ] promotion-unit-test
{ 65530 } [ 0 65530 vap-unsigned ] promotion-unit-test
{ 0.10000000149011612 } [ vap_control_float ] promotion-unit-test
{ t } [ 0 0.1 vap-float vap_control_float = ] promotion-unit-test

: indirect-vap-bool ( tag value ptr -- result )
    int { int bool } cdecl 1 alien-indirect-varargs ;
: indirect-vap-unsigned ( tag value ptr -- result )
    int { int vap-unsigned-enum } cdecl 1 alien-indirect-varargs ;
{ 1 } [
    0 t "vap_read_integer" "varargs-promotions" library-dll dlsym
    indirect-vap-bool
] promotion-unit-test
{ 65530 } [
    0 vap-positive "vap_read_integer" "varargs-promotions" library-dll dlsym
    indirect-vap-unsigned
] promotion-unit-test

cpu arm.64? [
    SYMBOL: promotion-values
    CALLBACK: double vap-runtime-reader ( int tag, ... )
    CALLBACK: double vap-tail-reader (
        int tag, ... bool b, vap-signed-enum s, vap-unsigned-enum u, float value )

    ! Both callback interfaces expose the promoted numbers, not enum words
    ! or Factor booleans, and read the full promoted integer storage width.
    { { 1 -7 65530 0.10000000149011612 } } [
        [| tag args |
            tag drop args bool va-arg args vap-signed-enum va-arg
            args vap-unsigned-enum va-arg args float va-arg
            4array promotion-values set-global 0.0
        ] vap-runtime-reader [ vap_call_reader ] with-callback
        drop promotion-values get
    ] promotion-unit-test
    { { 1 -7 65530 0.10000000149011612 } } [
        [| tag b s u value |
            tag drop b s u value 4array promotion-values set-global 0.0
        ]
        vap-tail-reader [ vap_call_reader ] with-callback
        drop promotion-values get
    ] promotion-unit-test
] when
