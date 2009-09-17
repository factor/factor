! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.inline.types
alien.marshall.private alien.strings byte-arrays classes
combinators combinators.short-circuit destructors fry
io.encodings.utf8 kernel libc sequences
specialized-arrays strings unix.utilities vocabs.parser
words libc.private locals generalizations math ;
FROM: alien.c-types => float short ;
SPECIALIZED-ARRAY: bool
SPECIALIZED-ARRAY: char
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: long
SPECIALIZED-ARRAY: longlong
SPECIALIZED-ARRAY: short
SPECIALIZED-ARRAY: uchar
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ulong
SPECIALIZED-ARRAY: ulonglong
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: void*
IN: alien.marshall

<< primitive-types [ [ "void*" = ] [ "bool" = ] bi or not ]
filter [ define-primitive-marshallers ] each >>

TUPLE: alien-wrapper { underlying alien } ;
TUPLE: struct-wrapper < alien-wrapper disposed ;
TUPLE: class-wrapper < alien-wrapper disposed ;

MIXIN: c++-root

GENERIC: unmarshall-cast ( alien-wrapper -- alien-wrapper' )

M: alien-wrapper unmarshall-cast ;
M: struct-wrapper unmarshall-cast ;

M: struct-wrapper dispose* underlying>> free ;

M: class-wrapper c++-type class name>> parse-c++-type ;

: marshall-pointer ( obj -- alien )
    {
        { [ dup alien? ] [ ] }
        { [ dup not ] [ ] }
        { [ dup byte-array? ] [ malloc-byte-array ] }
        { [ dup alien-wrapper? ] [ underlying>> ] }
    } cond ;

: marshall-primitive ( n -- n )
    [ bool>arg ] ptr-pass-through ;

ALIAS: marshall-void* marshall-pointer

: marshall-void** ( seq -- alien )
    [ marshall-void* ] void*-array{ } map-as malloc-underlying ;

: (marshall-char*-or-string) ( n/string -- alien )
    dup string?
    [ utf8 string>alien malloc-byte-array ]
    [ (marshall-char*) ] if ;

: marshall-char*-or-string ( n/string -- alien )
    [ (marshall-char*-or-string) ] ptr-pass-through ;

: (marshall-char**-or-strings) ( seq -- alien )
    [ marshall-char*-or-string ] void*-array{ } map-as
    malloc-underlying ;

: marshall-char**-or-strings ( seq -- alien )
    [ (marshall-char**-or-strings) ] ptr-pass-through ;

: marshall-bool ( ? -- n )
    >boolean [ 1 ] [ 0 ] if ;

: (marshall-bool*) ( ?/seq -- alien )
    [ marshall-bool <bool> malloc-byte-array ]
    [ >bool-array malloc-underlying ]
    marshall-x* ;

: marshall-bool* ( ?/seq -- alien )
    [ (marshall-bool*) ] ptr-pass-through ;

: (marshall-bool**) ( seq -- alien )
    [ marshall-bool* ] map >void*-array malloc-underlying ;

: marshall-bool** ( seq -- alien )
    [ (marshall-bool**) ] ptr-pass-through ;

: unmarshall-bool ( n -- ? )
    0 = not ;

: unmarshall-bool* ( alien -- ? )
    *bool unmarshall-bool ;

: unmarshall-bool*-free ( alien -- ? )
    [ *bool unmarshall-bool ] keep add-malloc free ;

: primitive-marshaller ( type -- quot/f )
    {
        { "bool"        [ [ ] ] }
        { "boolean"     [ [ marshall-bool ] ] }
        { "char"        [ [ marshall-primitive ] ] }
        { "uchar"       [ [ marshall-primitive ] ] }
        { "short"       [ [ marshall-primitive ] ] }
        { "ushort"      [ [ marshall-primitive ] ] }
        { "int"         [ [ marshall-primitive ] ] }
        { "uint"        [ [ marshall-primitive ] ] }
        { "long"        [ [ marshall-primitive ] ] }
        { "ulong"       [ [ marshall-primitive ] ] }
        { "long"        [ [ marshall-primitive ] ] }
        { "ulong"       [ [ marshall-primitive ] ] }
        { "float"       [ [ marshall-primitive ] ] }
        { "double"      [ [ marshall-primitive ] ] }
        { "bool*"       [ [ marshall-bool* ] ] }
        { "boolean*"    [ [ marshall-bool* ] ] }
        { "char*"       [ [ marshall-char*-or-string ] ] }
        { "uchar*"      [ [ marshall-uchar* ] ] }
        { "short*"      [ [ marshall-short* ] ] }
        { "ushort*"     [ [ marshall-ushort* ] ] }
        { "int*"        [ [ marshall-int* ] ] }
        { "uint*"       [ [ marshall-uint* ] ] }
        { "long*"       [ [ marshall-long* ] ] }
        { "ulong*"      [ [ marshall-ulong* ] ] }
        { "longlong*"   [ [ marshall-longlong* ] ] }
        { "ulonglong*"  [ [ marshall-ulonglong* ] ] }
        { "float*"      [ [ marshall-float* ] ] }
        { "double*"     [ [ marshall-double* ] ] }
        { "bool&"       [ [ marshall-bool* ] ] }
        { "boolean&"    [ [ marshall-bool* ] ] }
        { "char&"       [ [ marshall-char* ] ] }
        { "uchar&"      [ [ marshall-uchar* ] ] }
        { "short&"      [ [ marshall-short* ] ] }
        { "ushort&"     [ [ marshall-ushort* ] ] }
        { "int&"        [ [ marshall-int* ] ] }
        { "uint&"       [ [ marshall-uint* ] ] }
        { "long&"       [ [ marshall-long* ] ] }
        { "ulong&"      [ [ marshall-ulong* ] ] }
        { "longlong&"   [ [ marshall-longlong* ] ] }
        { "ulonglong&"  [ [ marshall-ulonglong* ] ] }
        { "float&"      [ [ marshall-float* ] ] }
        { "double&"     [ [ marshall-double* ] ] }
        { "void*"       [ [ marshall-void* ] ] }
        { "bool**"      [ [ marshall-bool** ] ] }
        { "boolean**"   [ [ marshall-bool** ] ] }
        { "char**"      [ [ marshall-char**-or-strings ] ] }
        { "uchar**"     [ [ marshall-uchar** ] ] }
        { "short**"     [ [ marshall-short** ] ] }
        { "ushort**"    [ [ marshall-ushort** ] ] }
        { "int**"       [ [ marshall-int** ] ] }
        { "uint**"      [ [ marshall-uint** ] ] }
        { "long**"      [ [ marshall-long** ] ] }
        { "ulong**"     [ [ marshall-ulong** ] ] }
        { "longlong**"  [ [ marshall-longlong** ] ] }
        { "ulonglong**" [ [ marshall-ulonglong** ] ] }
        { "float**"     [ [ marshall-float** ] ] }
        { "double**"    [ [ marshall-double** ] ] }
        { "void**"      [ [ marshall-void** ] ] }
        [ drop f ]
    } case ;

: marshall-non-pointer ( alien-wrapper/byte-array -- byte-array )
    {
        { [ dup byte-array? ] [ ] }
        { [ dup alien-wrapper? ]
          [ [ underlying>> ] [ class name>> heap-size ] bi
            memory>byte-array ] }
    } cond ;


: marshaller ( type -- quot )
    factorize-type dup primitive-marshaller [ nip ] [
        pointer?
        [ [ marshall-pointer ] ]
        [ [ marshall-non-pointer ] ] if
    ] if* ;


: unmarshall-char*-to-string ( alien -- string )
    utf8 alien>string ;

: unmarshall-char*-to-string-free ( alien -- string )
    [ unmarshall-char*-to-string ] keep add-malloc free ;

: primitive-unmarshaller ( type -- quot/f )
    {
        { "bool"       [ [ ] ] }
        { "boolean"    [ [ unmarshall-bool ] ] }
        { "char"       [ [ ] ] }
        { "uchar"      [ [ ] ] }
        { "short"      [ [ ] ] }
        { "ushort"     [ [ ] ] }
        { "int"        [ [ ] ] }
        { "uint"       [ [ ] ] }
        { "long"       [ [ ] ] }
        { "ulong"      [ [ ] ] }
        { "longlong"   [ [ ] ] }
        { "ulonglong"  [ [ ] ] }
        { "float"      [ [ ] ] }
        { "double"     [ [ ] ] }
        { "bool*"      [ [ unmarshall-bool*-free ] ] }
        { "boolean*"   [ [ unmarshall-bool*-free ] ] }
        { "char*"      [ [ ] ] }
        { "uchar*"     [ [ unmarshall-uchar*-free ] ] }
        { "short*"     [ [ unmarshall-short*-free ] ] }
        { "ushort*"    [ [ unmarshall-ushort*-free ] ] }
        { "int*"       [ [ unmarshall-int*-free ] ] }
        { "uint*"      [ [ unmarshall-uint*-free ] ] }
        { "long*"      [ [ unmarshall-long*-free ] ] }
        { "ulong*"     [ [ unmarshall-ulong*-free ] ] }
        { "longlong*"  [ [ unmarshall-long*-free ] ] }
        { "ulonglong*" [ [ unmarshall-ulong*-free ] ] }
        { "float*"     [ [ unmarshall-float*-free ] ] }
        { "double*"    [ [ unmarshall-double*-free ] ] }
        { "bool&"      [ [ unmarshall-bool*-free ] ] }
        { "boolean&"   [ [ unmarshall-bool*-free ] ] }
        { "char&"      [ [ ] ] }
        { "uchar&"     [ [ unmarshall-uchar*-free ] ] }
        { "short&"     [ [ unmarshall-short*-free ] ] }
        { "ushort&"    [ [ unmarshall-ushort*-free ] ] }
        { "int&"       [ [ unmarshall-int*-free ] ] }
        { "uint&"      [ [ unmarshall-uint*-free ] ] }
        { "long&"      [ [ unmarshall-long*-free ] ] }
        { "ulong&"     [ [ unmarshall-ulong*-free ] ] }
        { "longlong&"  [ [ unmarshall-longlong*-free ] ] }
        { "ulonglong&" [ [ unmarshall-ulonglong*-free ] ] }
        { "float&"     [ [ unmarshall-float*-free ] ] }
        { "double&"    [ [ unmarshall-double*-free ] ] }
        [ drop f ]
    } case ;

: struct-primitive-unmarshaller ( type -- quot/f )
    {
        { "bool"       [ [ unmarshall-bool ] ] }
        { "boolean"    [ [ unmarshall-bool ] ] }
        { "char"       [ [ ] ] }
        { "uchar"      [ [ ] ] }
        { "short"      [ [ ] ] }
        { "ushort"     [ [ ] ] }
        { "int"        [ [ ] ] }
        { "uint"       [ [ ] ] }
        { "long"       [ [ ] ] }
        { "ulong"      [ [ ] ] }
        { "longlong"   [ [ ] ] }
        { "ulonglong"  [ [ ] ] }
        { "float"      [ [ ] ] }
        { "double"     [ [ ] ] }
        { "bool*"      [ [ unmarshall-bool* ] ] }
        { "boolean*"   [ [ unmarshall-bool* ] ] }
        { "char*"      [ [ ] ] }
        { "uchar*"     [ [ unmarshall-uchar* ] ] }
        { "short*"     [ [ unmarshall-short* ] ] }
        { "ushort*"    [ [ unmarshall-ushort* ] ] }
        { "int*"       [ [ unmarshall-int* ] ] }
        { "uint*"      [ [ unmarshall-uint* ] ] }
        { "long*"      [ [ unmarshall-long* ] ] }
        { "ulong*"     [ [ unmarshall-ulong* ] ] }
        { "longlong*"  [ [ unmarshall-long* ] ] }
        { "ulonglong*" [ [ unmarshall-ulong* ] ] }
        { "float*"     [ [ unmarshall-float* ] ] }
        { "double*"    [ [ unmarshall-double* ] ] }
        { "bool&"      [ [ unmarshall-bool* ] ] }
        { "boolean&"   [ [ unmarshall-bool* ] ] }
        { "char&"      [ [ unmarshall-char* ] ] }
        { "uchar&"     [ [ unmarshall-uchar* ] ] }
        { "short&"     [ [ unmarshall-short* ] ] }
        { "ushort&"    [ [ unmarshall-ushort* ] ] }
        { "int&"       [ [ unmarshall-int* ] ] }
        { "uint&"      [ [ unmarshall-uint* ] ] }
        { "long&"      [ [ unmarshall-long* ] ] }
        { "ulong&"     [ [ unmarshall-ulong* ] ] }
        { "longlong&"  [ [ unmarshall-longlong* ] ] }
        { "ulonglong&" [ [ unmarshall-ulonglong* ] ] }
        { "float&"     [ [ unmarshall-float* ] ] }
        { "double&"    [ [ unmarshall-double* ] ] }
        [ drop f ]
    } case ;


: ?malloc-byte-array ( c-type -- alien )
    dup alien? [ malloc-byte-array ] unless ;

:: x-unmarshaller ( type type-quot superclass def clean -- quot/f )
    type type-quot call current-vocab lookup [
        dup superclasses superclass swap member?
        [ def call ] [ drop clean call f ] if
    ] [ clean call f ] if* ; inline

: struct-unmarshaller ( type -- quot/f )
    [ ] \ struct-wrapper
    [ '[ ?malloc-byte-array _ new swap >>underlying ] ]
    [ ]
    x-unmarshaller ;

: class-unmarshaller ( type -- quot/f )
    [ type-sans-pointer "#" append ] \ class-wrapper
    [ '[ _ new swap >>underlying ] ]
    [ ]
    x-unmarshaller ;

: non-primitive-unmarshaller ( type -- quot/f )
    {
        { [ dup pointer? ] [ class-unmarshaller ] }
        [ struct-unmarshaller ]
    } cond ;

: unmarshaller ( type -- quot )
    factorize-type {
        [ primitive-unmarshaller ]
        [ non-primitive-unmarshaller ]
        [ drop [ ] ]
    } 1|| ;

: struct-field-unmarshaller ( type -- quot )
    factorize-type {
        [ struct-primitive-unmarshaller ]
        [ non-primitive-unmarshaller ]
        [ drop [ ] ]
    } 1|| ;

: out-arg-unmarshaller ( type -- quot )
    dup pointer-to-non-const-primitive?
    [ factorize-type primitive-unmarshaller ]
    [ drop [ drop ] ] if ;
