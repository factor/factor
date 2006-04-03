USING: alien compiler kernel kernel-internals math namespaces ;

[
    [ alien-unsigned-cell <alien> ] "getter" set
    [
        >r >r alien-address r> r> set-alien-unsigned-cell
    ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_alien" "boxer-function" set
    "unbox_alien" "unboxer-function" set
] "void*" define-primitive-type

[
    [ alien-signed-8 ] "getter" set
    [ set-alien-signed-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_signed_8" "boxer-function" set
    "unbox_signed_8" "unboxer-function" set
] "longlong" define-primitive-type

[
    [ alien-unsigned-8 ] "getter" set
    [ set-alien-unsigned-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_unsigned_8" "boxer-function" set
    "unbox_unsigned_8" "unboxer-function" set
] "ulonglong" define-primitive-type

[
    [ alien-signed-cell ] "getter" set
    [ set-alien-signed-cell ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_signed_cell" "boxer-function" set
    "unbox_signed_cell" "unboxer-function" set
] "long" define-primitive-type

[
    [ alien-unsigned-cell ] "getter" set
    [ set-alien-unsigned-cell ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_unsigned_cell" "boxer-function" set
    "unbox_unsigned_cell" "unboxer-function" set
] "ulong" define-primitive-type

[
    [ alien-signed-4 ] "getter" set
    [ set-alien-signed-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_signed_4" "boxer-function" set
    "unbox_signed_4" "unboxer-function" set
] "int" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_unsigned_4" "boxer-function" set
    "unbox_unsigned_4" "unboxer-function" set
] "uint" define-primitive-type

[
    [ alien-signed-2 ] "getter" set
    [ set-alien-signed-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_signed_2" "boxer-function" set
    "unbox_signed_2" "unboxer-function" set
] "short" define-primitive-type

[
    [ alien-unsigned-2 ] "getter" set
    [ set-alien-unsigned-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_unsigned_2" "boxer-function" set
    "unbox_unsigned_2" "unboxer-function" set
] "ushort" define-primitive-type

[
    [ alien-signed-1 ] "getter" set
    [ set-alien-signed-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_signed_1" "boxer-function" set
    "unbox_signed_1" "unboxer-function" set
] "char" define-primitive-type

[
    [ alien-unsigned-1 ] "getter" set
    [ set-alien-unsigned-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_unsigned_1" "boxer-function" set
    "unbox_unsigned_1" "unboxer-function" set
] "uchar" define-primitive-type

[
    [ alien-unsigned-cell <alien> alien>string ] "getter" set
    [
        >r >r string>alien alien-address r> r>
        set-alien-unsigned-cell
    ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_c_string" "boxer-function" set
    "unbox_c_string" "unboxer-function" set
] "char*" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_utf16_string" "boxer-function" set
    "unbox_utf16_string" "unboxer-function" set
] "ushort*" define-primitive-type

[
    [ alien-unsigned-4 zero? not ] "getter" set
    [ 1 0 ? set-alien-unsigned-4 ] "setter" set
    bootstrap-cell "width" set
    bootstrap-cell "align" set
    "box_boolean" "boxer-function" set
    "unbox_boolean" "unboxer-function" set
] "bool" define-primitive-type

[
    [ alien-float ] "getter" set
    [ set-alien-float ] "setter" set
    4 "width" set
    4 "align" set
    "box_float" "boxer-function" set
    "unbox_float" "unboxer-function" set
    T{ float-regs f 4 } "reg-class" set
] "float" define-primitive-type

[
    [ alien-double ] "getter" set
    [ set-alien-double ] "setter" set
    8 "width" set
    8 "align" set
    "box_double" "boxer-function" set
    "unbox_double" "unboxer-function" set
    T{ float-regs f 8 } "reg-class" set
] "double" define-primitive-type
