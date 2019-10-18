! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generator kernel kernel-internals math namespaces
sequences ;
IN: alien

H{ } clone c-types set-global

[ alien-unsigned-cell <alien> ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
bootstrap-cell
"box_alien"
"alien_offset" <primitive-type>
"void*" define-primitive-type

[ alien-signed-8 ]
[ set-alien-signed-8 ]
8
"box_signed_8"
"to_signed_8" <primitive-type> <long-long-type>
"longlong" define-primitive-type

[ alien-unsigned-8 ]
[ set-alien-unsigned-8 ]
8
"box_unsigned_8"
"to_unsigned_8" <primitive-type> <long-long-type>
"ulonglong" define-primitive-type

[ alien-signed-cell ]
[ set-alien-signed-cell ]
bootstrap-cell
"box_signed_cell"
"to_fixnum" <primitive-type>
"long" define-primitive-type

[ alien-unsigned-cell ]
[ set-alien-unsigned-cell ]
bootstrap-cell
"box_unsigned_cell"
"to_cell" <primitive-type>
"ulong" define-primitive-type

[ alien-signed-4 ]
[ set-alien-signed-4 ]
4
"box_signed_4"
"to_fixnum" <primitive-type>
"int" define-primitive-type

[ alien-unsigned-4 ]
[ set-alien-unsigned-4 ]
4
"box_unsigned_4"
"to_cell" <primitive-type>
"uint" define-primitive-type

[ alien-signed-2 ]
[ set-alien-signed-2 ]
2
"box_signed_2"
"to_fixnum" <primitive-type>
"short" define-primitive-type

[ alien-unsigned-2 ]
[ set-alien-unsigned-2 ]
2
"box_unsigned_2"
"to_cell" <primitive-type>
"ushort" define-primitive-type

[ alien-signed-1 ]
[ set-alien-signed-1 ]
1
"box_signed_1"
"to_fixnum" <primitive-type>
"char" define-primitive-type

[ alien-unsigned-1 ]
[ set-alien-unsigned-1 ]
1
"box_unsigned_1"
"to_cell" <primitive-type>
"uchar" define-primitive-type

[ alien-unsigned-4 zero? not ]
[ 1 0 ? set-alien-unsigned-4 ]
4
"box_boolean"
"to_boolean" <primitive-type>
"bool" define-primitive-type

[ alien-float ]
[ >r >r >float r> r> set-alien-float ]
4
"box_float"
"to_float" <primitive-type>
"float" define-primitive-type

T{ float-regs f 4 } "float" c-type set-c-type-reg-class
[ >float ] "float" c-type set-c-type-prep

[ alien-double ]
[ >r >r >float r> r> set-alien-double ]
8
"box_double"
"to_double" <primitive-type>
"double" define-primitive-type

T{ float-regs f 8 } "double" c-type set-c-type-reg-class
[ >float ] "double" c-type set-c-type-prep

[ alien-unsigned-cell <alien> alien>char-string ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
bootstrap-cell
"box_char_string"
"alien_offset" <primitive-type>
"char*" define-primitive-type

"char*" "uchar*" typedef

[ string>char-alien ] "char*" c-type set-c-type-prep

[ alien-unsigned-cell <alien> alien>u16-string ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
4
"box_u16_string"
"alien_offset" <primitive-type>
"ushort*" define-primitive-type

[ string>u16-alien ] "ushort*" c-type set-c-type-prep

DEFER: *char
DEFER: *uchar
DEFER: *short
DEFER: *ushort
DEFER: *int
DEFER: *uint
DEFER: *long
DEFER: *ulong
DEFER: *longlong
DEFER: *ulonglong
DEFER: *float
DEFER: *double
DEFER: *void*
DEFER: *char*
DEFER: *ushort*

DEFER: <char>
DEFER: <uchar>
DEFER: <short>
DEFER: <ushort>
DEFER: <int>
DEFER: <uint>
DEFER: <long>
DEFER: <ulong>
DEFER: <longlong>
DEFER: <ulonglong>
DEFER: <float>
DEFER: <double>
DEFER: <void*>

DEFER: char-nth
DEFER: set-char-nth
DEFER: uchar-nth
DEFER: set-uchar-nth
DEFER: short-nth
DEFER: set-short-nth
DEFER: ushort-nth
DEFER: set-ushort-nth
DEFER: int-nth
DEFER: set-int-nth
DEFER: uint-nth
DEFER: set-uint-nth
DEFER: long-nth
DEFER: set-long-nth
DEFER: ulong-nth
DEFER: set-ulong-nth
DEFER: longlong-nth
DEFER: set-longlong-nth
DEFER: ulonglong-nth
DEFER: set-ulonglong-nth
DEFER: float-nth
DEFER: set-float-nth
DEFER: double-nth
DEFER: set-double-nth
DEFER: void*-nth
DEFER: set-void*-nth
DEFER: char*-nth
DEFER: ushort*-nth

: >int-array ( seq -- <int-array> )
    dup length dup "int" <c-array> -rot
    [ pick set-int-nth ] 2each ;

: >float-array ( seq -- byte-array )
    dup length dup "float" <c-array> -rot
    [ pick set-float-nth ] 2each ;
