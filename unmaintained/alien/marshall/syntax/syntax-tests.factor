! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.inline.syntax alien.marshall.syntax destructors
tools.test accessors kernel ;
IN: alien.marshall.syntax.tests

DELETE-C-LIBRARY: test
C-LIBRARY: test

C-INCLUDE: <stdlib.h>
C-INCLUDE: <string.h>
C-INCLUDE: <stdbool.h>

CM-FUNCTION: void outarg1 ( int* a )
    *a += 2;
;

CM-FUNCTION: unsigned-long* outarg2 ( unsigned-long a, unsigned-long* b )
    unsigned long* x = malloc(sizeof(unsigned long*));
    *b = 10 + *b;
    *x = a + *b;
    return x;
;

CM-STRUCTURE: wedge
    { "double" "degrees" } ;

CM-STRUCTURE: sundial
    { "double" "radius" }
    { "wedge" "wedge" } ;

CM-FUNCTION: double hours ( sundial* d )
    return d->wedge.degrees / 30;
;

CM-FUNCTION: void change_time ( double hours, sundial* d )
    d->wedge.degrees = hours * 30;
;

CM-FUNCTION: bool c_not ( bool p )
    return !p;
;

CM-FUNCTION: char* upcase ( const-char* s )
    int len = strlen(s);
    char* t = malloc(sizeof(char) * len);
    int i;
    for (i = 0; i < len; i++)
        t[i] = toupper(s[i]);
    t[i] = '\0';
    return t;
;

;C-LIBRARY

{ 1 1 } [ outarg1 ] must-infer-as
[ 3 ] [ 1 outarg1 ] unit-test
[ 3 ] [ t outarg1 ] unit-test
[ 2 ] [ f outarg1 ] unit-test

{ 2 2 } [ outarg2 ] must-infer-as
[ 18 15 ] [ 3 5 outarg2 ] unit-test

{ 1 1 } [ hours ] must-infer-as
[ 5.0 ] [ <sundial> <wedge> 150 >>degrees >>wedge hours ] unit-test

{ 2 0 } [ change_time ] must-infer-as
[ 150.0 ] [ 5 <sundial> <wedge> 11 >>degrees >>wedge [ change_time ] keep wedge>> degrees>> ] unit-test

{ 1 1 } [ c_not ] must-infer-as
[ f ] [ "x" c_not ] unit-test
[ f ] [ 0 c_not ] unit-test

{ 1 1 } [ upcase ] must-infer-as
[ "ABC" ] [ "abc" upcase ] unit-test
