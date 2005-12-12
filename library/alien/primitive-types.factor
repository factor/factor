USING: alien compiler-backend kernel kernel-internals
math namespaces ;

[
    [ alien-unsigned-cell <alien> ] "getter" set
    [
        >r >r alien-address r> r> set-alien-unsigned-cell
    ] "setter" set
    cell "width" set
    cell "align" set
    "box_alien" "boxer" set
    "unbox_alien" "unboxer" set
] "void*" define-primitive-type

[
    [ alien-signed-8 ] "getter" set
    [ set-alien-signed-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_signed_8" "boxer" set
    "unbox_signed_8" "unboxer" set
] "longlong" define-primitive-type

[
    [ alien-unsigned-8 ] "getter" set
    [ set-alien-unsigned-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_unsinged_8" "boxer" set
    "unbox_unsigned_8" "unboxer" set
] "ulonglong" define-primitive-type

[
    [ alien-signed-cell ] "getter" set
    [ set-alien-signed-cell ] "setter" set
    cell "width" set
    cell "align" set
    "box_signed_cell" "boxer" set
    "unbox_signed_cell" "unboxer" set
] "long" define-primitive-type

[
    [ alien-unsigned-cell ] "getter" set
    [ set-alien-unsigned-cell ] "setter" set
    cell "width" set
    cell "align" set
    "box_unsigned_cell" "boxer" set
    "unbox_unsigned_cell" "unboxer" set
] "ulong" define-primitive-type

[
    [ alien-signed-4 ] "getter" set
    [ set-alien-signed-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_signed_4" "boxer" set
    "unbox_signed_4" "unboxer" set
] "int" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_unsigned_4" "boxer" set
    "unbox_unsigned_4" "unboxer" set
] "uint" define-primitive-type

[
    [ alien-signed-2 ] "getter" set
    [ set-alien-signed-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_signed_2" "boxer" set
    "unbox_signed_2" "unboxer" set
] "short" define-primitive-type

[
    [ alien-unsigned-2 ] "getter" set
    [ set-alien-unsigned-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_unsigned_2" "boxer" set
    "unbox_unsigned_2" "unboxer" set
] "ushort" define-primitive-type

[
    [ alien-signed-1 ] "getter" set
    [ set-alien-signed-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_signed_1" "boxer" set
    "unbox_signed_1" "unboxer" set
] "char" define-primitive-type

[
    [ alien-unsigned-1 ] "getter" set
    [ set-alien-unsigned-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_unsigned_1" "boxer" set
    "unbox_unsigned_1" "unboxer" set
] "uchar" define-primitive-type

[
    [ alien-unsigned-cell <alien> alien>string ] "getter" set
    [
        >r >r string>alien alien-address r> r>
        set-alien-unsigned-cell
    ] "setter" set
    cell "width" set
    cell "align" set
    "box_c_string" "boxer" set
    "unbox_c_string" "unboxer" set
] "char*" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_utf16_string" "boxer" set
    "unbox_utf16_string" "unboxer" set
] "ushort*" define-primitive-type

[
    [ alien-unsigned-4 0 = not ] "getter" set
    [ 1 0 ? set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_boolean" "boxer" set
    "unbox_boolean" "unboxer" set
] "bool" define-primitive-type

[
    [ alien-float ] "getter" set
    [ set-alien-float ] "setter" set
    cell "width" set
    cell "align" set
    "box_float" "boxer" set
    "unbox_float" "unboxer" set
    T{ float-regs f 4 } "reg-class" set
] "float" define-primitive-type

[
    [ alien-double ] "getter" set
    [ set-alien-double ] "setter" set
    cell 2 * "width" set
    cell 2 * "align" set
    "box_double" "boxer" set
    "unbox_double" "unboxer" set
    T{ float-regs f 8 } "reg-class" set
] "double" define-primitive-type
