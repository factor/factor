! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: glib.ffi gobject-introspection.tests.everything.ffi
io.streams.string see tools.test ;
IN: gobject-introspection.tests.godegen

! Constants

[ "IN: glib.ffi
CONSTANT: G_ASCII_DTOSTR_BUF_SIZE 39 inline
" ] [
    [ \ G_ASCII_DTOSTR_BUF_SIZE see ] with-string-writer
] unit-test

[ "IN: glib.ffi
CONSTANT: G_CSET_a_2_z \"abcdefghijklmnopqrstuvwxyz\" inline
" ] [
    [ \ G_CSET_a_2_z see ] with-string-writer
] unit-test

[ "IN: glib.ffi
CONSTANT: G_E 2.71828182846 inline
" ] [
    [ \ G_E see ] with-string-writer
] unit-test

! Enumerations

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
TYPEDEF: int TestEnum
" ] [
    [ \ TestEnum see ] with-string-writer
] unit-test

[ "IN: gobject-introspection.tests.everything.ffi
CONSTANT: TEST_VALUE1 0 inline
" ] [
    [ \ TEST_VALUE1 see ] with-string-writer
] unit-test

[ "IN: gobject-introspection.tests.everything.ffi
CONSTANT: TEST_VALUE3 42 inline
" ] [
    [ \ TEST_VALUE3 see ] with-string-writer
] unit-test

! Bitfields

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
TYPEDEF: int TestFlags
" ] [
    [ \ TestFlags see ] with-string-writer
] unit-test

[ "IN: gobject-introspection.tests.everything.ffi
CONSTANT: TEST_FLAG2 2 inline
" ] [
    [ \ TEST_FLAG2 see ] with-string-writer
] unit-test

! Functions

[ "USING: alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    gint test_int ( gint in ) ;
" ] [
    [ \ test_int see ] with-string-writer
] unit-test

! - throws

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    gboolean test_torture_signature_1
    ( int x, double* y, int* z, char* foo, int* q, guint m,
    GError** error ) ;
" ] [
    [ \ test_torture_signature_1 see ] with-string-writer
] unit-test

! Records

[ "USING: alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
C-TYPE: TestSimpleBoxedA
" ] [
    [ \ TestSimpleBoxedA see ] with-string-writer
] unit-test

[ "USING: classes.struct glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
STRUCT: TestBoxed
    { some_int8 gint8 initial: 0 }
    { nested_a TestSimpleBoxedA } { priv TestBoxedPrivate* } ;
" ] [
    [ \ TestBoxed see ] with-string-writer
] unit-test

! - constructors

[ "USING: alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    TestBoxed* test_boxed_new ( ) ;
" ] [
    [ \ test_boxed_new see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    TestBoxed* test_boxed_new_alternative_constructor1
    ( int i ) ;
" ] [
    [ \ test_boxed_new_alternative_constructor1 see ] with-string-writer
] unit-test

! - functions

! - methods

[ "USING: alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    TestBoxed* test_boxed_copy ( TestBoxed* self ) ;
" ] [
    [ \ test_boxed_copy see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    void test_struct_a_clone
    ( TestStructA* self, TestStructA* a_out ) ;
" ] [
    [ \ test_struct_a_clone see ] with-string-writer
] unit-test

! Classes

[ "USING: alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
C-TYPE: TestObj
" ] [
    [ \ TestObj see ] with-string-writer
] unit-test

! - get_type

[ "USING: alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    GType test_obj_get_type ( ) ;
" ] [
    [ \ test_obj_get_type see ] with-string-writer
] unit-test

! - constructors

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    TestObj* test_obj_new_from_file ( char* x, GError** error )
    ;
" ] [
    [ \ test_obj_new_from_file see ] with-string-writer
] unit-test

[ "USING: alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    TestObj* test_obj_new_callback
    ( TestCallbackUserData callback, gpointer user_data,
    GDestroyNotify notify ) ;
" ] [
    [ \ test_obj_new_callback see ] with-string-writer
] unit-test

! - functions

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    double test_obj_static_method ( int x ) ;
" ] [
    [ \ test_obj_static_method see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    void test_obj_static_method_callback
    ( TestCallback callback ) ;
" ] [
    [ \ test_obj_static_method_callback see ] with-string-writer
] unit-test

! - methods

[ "USING: alien.c-types alien.syntax gobject.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    void test_obj_set_bare ( TestObj* self, GObject* bare ) ;
" ] [
    [ \ test_obj_set_bare see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    int test_obj_instance_method ( TestObj* self ) ;
" ] [
    [ \ test_obj_instance_method see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything FUNCTION:
    gboolean test_obj_torture_signature_1
    ( TestObj* self, int x, double* y, int* z, char* foo, int*
    q, guint m, GError** error ) ;
" ] [
    [ \ test_obj_torture_signature_1 see ] with-string-writer
] unit-test

! - signals

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything CALLBACK:
    void TestObj:test ( TestObj* sender, gpointer user_data ) ;
" ] [
    [ \ TestObj:test see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything CALLBACK:
    void TestObj:test-with-static-scope-arg
    ( TestObj* sender, TestSimpleBoxedA* object, gpointer
    user_data ) ;
" ] [
    [ \ TestObj:test-with-static-scope-arg see ] with-string-writer
] unit-test

! Callbacks

[ "USING: alien.c-types alien.syntax ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything CALLBACK:
    int TestCallback ( ) ;
" ] [
    [ \ TestCallback see ] with-string-writer
] unit-test

[ "USING: alien.c-types alien.syntax glib.ffi ;
IN: gobject-introspection.tests.everything.ffi
LIBRARY: gobject-introspection.tests.everything CALLBACK:
    int TestCallbackUserData ( gpointer user_data ) ;
" ] [
    [ \ TestCallbackUserData see ] with-string-writer
] unit-test

