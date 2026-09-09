USING: alien.c-types gobject-introspection.standard-types kernel tools.test ;
QUALIFIED: alien.varargs
IN: gobject-introspection.standard-types.tests

{ t } [
    va_list lookup-c-type alien.varargs:va_list lookup-c-type eq?
] unit-test
