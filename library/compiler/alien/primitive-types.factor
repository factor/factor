USING: alien compiler kernel kernel-internals math namespaces ;

[ alien-unsigned-cell <alien> ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
bootstrap-cell
"box_alien"
"unbox_alien"
"void*" define-primitive-type

[ alien-signed-8 ]
[ set-alien-signed-8 ]
8
"box_signed_8"
"unbox_signed_8"
"longlong" define-primitive-type

[ alien-unsigned-8 ]
[ set-alien-unsigned-8 ]
8
"box_unsigned_8"
"unbox_unsigned_8"
"ulonglong" define-primitive-type

[ alien-signed-cell ]
[ set-alien-signed-cell ]
bootstrap-cell
"box_signed_cell"
"unbox_signed_cell"
"long" define-primitive-type

[ alien-unsigned-cell ]
[ set-alien-unsigned-cell ]
bootstrap-cell
"box_unsigned_cell"
"unbox_unsigned_cell"
"ulong" define-primitive-type

[ alien-signed-4 ]
[ set-alien-signed-4 ]
4
"box_signed_4"
"unbox_signed_4"
"int" define-primitive-type

[ alien-unsigned-4 ]
[ set-alien-unsigned-4 ]
4
"box_unsigned_4"
"unbox_unsigned_4"
"uint" define-primitive-type

[ alien-signed-2 ]
[ set-alien-signed-2 ]
2
"box_signed_2"
"unbox_signed_2"
"short" define-primitive-type

[ alien-unsigned-2 ]
[ set-alien-unsigned-2 ]
2
"box_unsigned_2"
"unbox_unsigned_2"
"ushort" define-primitive-type

[ alien-signed-1 ]
[ set-alien-signed-1 ]
1
"box_signed_1"
"unbox_signed_1"
"char" define-primitive-type

[ alien-unsigned-1 ]
[ set-alien-unsigned-1 ]
1
"box_unsigned_1"
"unbox_unsigned_1"
"uchar" define-primitive-type

! This is a hack; we need better ways of handling arrays
! inline structs
[ swap <displaced-alien> alien>char-string ]
[ swap <displaced-alien> swap set-alien-unsigned-1 ]
1
f
f
"char[]" define-primitive-type

[ alien-unsigned-4 zero? not ]
[ 1 0 ? set-alien-unsigned-4 ]
4
"box_boolean"
"unbox_boolean"
"bool" define-primitive-type

[ alien-float ]
[ >r >r >float r> r> set-alien-float ]
4
"box_float"
"unbox_float"
"float" define-primitive-type

T{ float-regs f 4 } "float" c-type set-c-type-reg-class
[ >float ] "float" c-type set-c-type-prep

[ alien-double ]
[ >r >r >float r> r> set-alien-double ]
8
"box_double"
"unbox_double"
"double" define-primitive-type

T{ float-regs f 8 } "double" c-type set-c-type-reg-class
[ >float ] "double" c-type set-c-type-prep

[ alien-unsigned-cell <alien> alien>char-string ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
bootstrap-cell
"box_char_string"
"unbox_alien"
"char*" define-primitive-type

[ string>char-alien ] "char*" c-type set-c-type-prep

[ alien-unsigned-cell <alien> alien>u16-string ]
[ >r >r alien-address r> r> set-alien-unsigned-cell ]
4
"box_u16_string"
"unbox_alien"
"ushort*" define-primitive-type

[ string>u16-alien ] "ushort*" c-type set-c-type-prep
