! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.syntax arrays classes.struct destructors 
gobject-introspection.tests.g-i-marshalling-tests.ffi
glib.ffi gobject.ffi io.encodings.utf8 kernel literals
sequences specialized-arrays tools.test ;
IN: gobject-introspection.tests.marshalling

SPECIALIZED-ARRAYS: gint gshort void*
GIMarshallingTestsSimpleStruct ;

CONSTANT: G_I_MARSHALLING_TESTS_CONSTANT_NUMBER 42

CONSTANT: G_I_MARSHALLING_TESTS_CONSTANT_UTF8 "const ♥ utf8"

! gboolean

[ t ] [ g_i_marshalling_tests_boolean_return_true ] unit-test
[ f ] [ g_i_marshalling_tests_boolean_return_false ] unit-test

: boolean-out-true ( -- out )
    { gboolean } [ g_i_marshalling_tests_boolean_out_true ]
    with-out-parameters ;
[ t ] [ boolean-out-true ] unit-test

: boolean-out-false ( -- out )
    { gboolean } [ g_i_marshalling_tests_boolean_out_false ]
    with-out-parameters ;
[ f ] [ boolean-out-false ] unit-test

! gint8

[ $ G_MAXINT8 ] [ g_i_marshalling_tests_int8_return_max ] unit-test
[ $ G_MININT8 ] [ g_i_marshalling_tests_int8_return_min ] unit-test

: int8-out-max ( -- out )
    { gint8 } [ g_i_marshalling_tests_int8_out_max ]
    with-out-parameters ;
[ $ G_MAXINT8 ] [ int8-out-max ] unit-test

: int8-out-min ( -- out )
    { gint8 } [ g_i_marshalling_tests_int8_out_min ]
    with-out-parameters ;
[ $ G_MININT8 ] [ int8-out-min ] unit-test

: int8-inout-max-min ( -- out )
    { { gint8 initial: $ G_MAXINT8 } }
    [ g_i_marshalling_tests_int8_inout_max_min ]
    with-out-parameters ;
[ $ G_MININT8 ] [ int8-inout-max-min ] unit-test

! guint8

[ $ G_MAXUINT8 ] [ g_i_marshalling_tests_uint8_return ] unit-test

: uint8-out ( -- out )
    { guint8 } [ g_i_marshalling_tests_uint8_out ]
    with-out-parameters ;
[ $ G_MAXUINT8 ] [ uint8-out ] unit-test

: uint8-inout ( -- out )
    { { guint8 initial: $ G_MAXUINT8 } }
    [ g_i_marshalling_tests_uint8_inout ]
    with-out-parameters ;
[ 0 ] [ uint8-inout ] unit-test

! gint16

[ $ G_MAXINT16 ] [ g_i_marshalling_tests_int16_return_max ] unit-test
[ $ G_MININT16 ] [ g_i_marshalling_tests_int16_return_min ] unit-test

: int16-out-max ( -- out )
    { gint16 } [ g_i_marshalling_tests_int16_out_max ]
    with-out-parameters ;
[ $ G_MAXINT16 ] [ int16-out-max ] unit-test

: int16-out-min ( -- out )
    { gint16 } [ g_i_marshalling_tests_int16_out_min ]
    with-out-parameters ;
[ $ G_MININT16 ] [ int16-out-min ] unit-test

: int16-inout-max-min ( -- out )
    { { gint16 initial: $ G_MAXINT16 } }
    [ g_i_marshalling_tests_int16_inout_max_min ]
    with-out-parameters ;
[ $ G_MININT16 ] [ int16-inout-max-min ] unit-test

! guint16

[ $ G_MAXUINT16 ] [ g_i_marshalling_tests_uint16_return ] unit-test

: uint16-out ( -- out )
    { guint16 } [ g_i_marshalling_tests_uint16_out ]
    with-out-parameters ;
[ $ G_MAXUINT16 ] [ uint16-out ] unit-test

: uint16-inout ( -- out )
    { { guint16 initial: $ G_MAXUINT16 } }
    [ g_i_marshalling_tests_uint16_inout ]
    with-out-parameters ;
[ 0 ] [ uint16-inout ] unit-test

! gint32

[ $ G_MAXINT32 ] [ g_i_marshalling_tests_int32_return_max ] unit-test
[ $ G_MININT32 ] [ g_i_marshalling_tests_int32_return_min ] unit-test

: int32-out-max ( -- out )
    { gint32 } [ g_i_marshalling_tests_int32_out_max ]
    with-out-parameters ;
[ $ G_MAXINT32 ] [ int32-out-max ] unit-test

: int32-out-min ( -- out )
    { gint32 } [ g_i_marshalling_tests_int32_out_min ]
    with-out-parameters ;
[ $ G_MININT32 ] [ int32-out-min ] unit-test

: int32-inout-max-min ( -- out )
    { { gint32 initial: $ G_MAXINT32 } }
    [ g_i_marshalling_tests_int32_inout_max_min ]
    with-out-parameters ;
[ $ G_MININT32 ] [ int32-inout-max-min ] unit-test

! guint32

[ $ G_MAXUINT32 ] [ g_i_marshalling_tests_uint32_return ] unit-test

: uint32-out ( -- out )
    { guint32 } [ g_i_marshalling_tests_uint32_out ]
    with-out-parameters ;
[ $ G_MAXUINT32 ] [ uint32-out ] unit-test

: uint32-inout ( -- out )
    { { guint32 initial: $ G_MAXUINT32 } }
    [ g_i_marshalling_tests_uint32_inout ]
    with-out-parameters ;
[ 0 ] [ uint32-inout ] unit-test

! gint64

[ $ G_MAXINT64 ] [ g_i_marshalling_tests_int64_return_max ] unit-test
[ $ G_MININT64 ] [ g_i_marshalling_tests_int64_return_min ] unit-test

: int64-out-max ( -- out )
    { gint64 } [ g_i_marshalling_tests_int64_out_max ]
    with-out-parameters ;
[ $ G_MAXINT64 ] [ int64-out-max ] unit-test

: int64-out-min ( -- out )
    { gint64 } [ g_i_marshalling_tests_int64_out_min ]
    with-out-parameters ;
[ $ G_MININT64 ] [ int64-out-min ] unit-test

: int64-inout-max-min ( -- out )
    { { gint64 initial: $ G_MAXINT64 } }
    [ g_i_marshalling_tests_int64_inout_max_min ]
    with-out-parameters ;
[ $ G_MININT64 ] [ int64-inout-max-min ] unit-test

! guint64

[ $ G_MAXUINT64 ] [ g_i_marshalling_tests_uint64_return ] unit-test

: uint64-out ( -- out )
    { guint64 } [ g_i_marshalling_tests_uint64_out ]
    with-out-parameters ;
[ $ G_MAXUINT64 ] [ uint64-out ] unit-test

: uint64-inout ( -- out )
    { { guint64 initial: $ G_MAXUINT64 } }
    [ g_i_marshalling_tests_uint64_inout ]
    with-out-parameters ;
[ 0 ] [ uint64-inout ] unit-test

! gssize
! gsize
! gfloat
! gdouble
! time_t

! gtype

[ $ G_TYPE_NONE ]
[ g_i_marshalling_tests_gtype_return ] unit-test

: gtype-out ( -- out )
    { GType } [ g_i_marshalling_tests_gtype_out ]
    with-out-parameters ;
[ $ G_TYPE_NONE ] [ gtype-out ] unit-test

: gtype-inout ( -- out )
    { { GType initial: $ G_TYPE_NONE } }
    [ g_i_marshalling_tests_gtype_inout ]
    with-out-parameters ;
[ $ G_TYPE_INT ] [ gtype-inout ] unit-test

! strings

[ $ G_I_MARSHALLING_TESTS_CONSTANT_UTF8 ]
[ g_i_marshalling_tests_utf8_none_return utf8 alien>string ] unit-test

[ $ G_I_MARSHALLING_TESTS_CONSTANT_UTF8 ] [
    [
        g_i_marshalling_tests_utf8_full_return &g_free
        utf8 alien>string
    ] with-destructors
] unit-test

: utf8-none-out ( -- out )
    { pointer: gchar }
    [ g_i_marshalling_tests_utf8_none_out ]
    with-out-parameters ;
[ $ G_I_MARSHALLING_TESTS_CONSTANT_UTF8 ]
[ utf8-none-out utf8 alien>string ] unit-test

: utf8-full-out ( -- out )
    { pointer: gchar }
    [ g_i_marshalling_tests_utf8_full_out ]
    with-out-parameters ;
[ $ G_I_MARSHALLING_TESTS_CONSTANT_UTF8 ] [
    [ utf8-full-out &g_free utf8 alien>string ] with-destructors
] unit-test

: utf8-dangling-out ( -- out )
    { { pointer: gchar initial: f } }
    [ g_i_marshalling_tests_utf8_dangling_out ]
    with-out-parameters ;
[ f ]
[ utf8-dangling-out ] unit-test

! arrays

[ int-array{ -1 0 1 2 } ]
[
    g_i_marshalling_tests_array_fixed_int_return
    4 <direct-int-array> >int-array
] unit-test

[ short-array{ -1 0 1 2 } ]
[
    g_i_marshalling_tests_array_fixed_short_return
    4 <direct-short-array> >short-array
] unit-test

: array-fixed-out ( -- out )
    { pointer: gint }
    [ g_i_marshalling_tests_array_fixed_out ]
    with-out-parameters ;
[ int-array{ -1 0 1 2 } ]
[
    array-fixed-out
    4 <direct-int-array> >int-array
] unit-test

: array-fixed-out-struct ( -- out )
    { pointer: gint }
    [ g_i_marshalling_tests_array_fixed_out_struct ]
    with-out-parameters ;
[ { { 7 6 } { 6 7 } } ]
[
    array-fixed-out-struct
    2 <direct-GIMarshallingTestsSimpleStruct-array>
    [ [ long_>> ] [ int8>> ] bi 2array ] { } map-as
] unit-test

: array-return ( -- array length )
    { gint }
    [ g_i_marshalling_tests_array_return ]
    with-out-parameters ;
[ int-array{ -1 0 1 2 } ]
[ array-return <direct-int-array> >int-array ] unit-test

: array-out ( -- array length )
    { pointer: gint gint }
    [ g_i_marshalling_tests_array_out ]
    with-out-parameters ;
[ int-array{ -1 0 1 2 } ]
[ array-out <direct-int-array> >int-array ] unit-test

[ { "0" "1" "2" f } ]
[
    g_i_marshalling_tests_array_zero_terminated_return
    4 <direct-void*-array> [ utf8 alien>string ] { } map-as
] unit-test

: array-zero-terminated-out ( -- out )
    { pointer: pointer: gchar }
    [ g_i_marshalling_tests_array_zero_terminated_out ]
    with-out-parameters ;
[ { "0" "1" "2" f } ]
[
    array-zero-terminated-out
    4 <direct-void*-array> [ utf8 alien>string ] { } map-as
] unit-test
