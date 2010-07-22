! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types assocs
combinators.short-circuit gobject-introspection.common
gobject-introspection.repository kernel namespaces
specialized-arrays ;
IN: gobject-introspection.types

TUPLE: gwrapper { underlying alien } ;
TUPLE: grecord < gwrapper ;
TUPLE: gobject < gwrapper ;

SPECIALIZED-ARRAYS:
    void* bool int uint char uchar short ushort long ulong
    longlong ulonglong float double ;

CONSTANT: simple-types H{
    { "any" {
        void* *void* >void*-array <direct-void*-array>
    } }
    { "boolean" {
        bool *bool >bool-array <direct-bool-array>
    } }
    { "int" {
        int *int >int-array <direct-int-array>
    } }
    { "uint" {
        uint *uint >uint-array <direct-uint-array>
    } }
    { "int8" {
        char *char >char-array <direct-char-array>
    } }
    { "uint8" {
        uchar *uchar >uchar-array <direct-uchar-array>
    } }
    { "int16" {
        short *short >short-array <direct-short-array>
    } }
    { "uint16" {
        ushort *ushort >ushort-array <direct-ushort-array>
    } }
    { "int32" {
        int *int >int-array <direct-int-array>
    } }
    { "uint32" {
        uint *uint >uint-array <direct-uint-array>
    } }
    { "int64" {
        longlong *longlong
        >longlong-array <direct-longlong-array>
    } }
    { "uint64" {
        ulonglong *ulonglong
        >ulonglong-array <direct-ulonglong-array>
    } }
    { "long" {
        long *long >long-array <direct-long-array>
    } }
    { "ulong" {
        ulong *ulong >ulong-array <direct-ulong-array>
    } }
    { "float" {
        float *float >float-array <direct-float-array>
    } }
    { "double" {
        double *double >double-array <direct-double-array>
    } }
     { "size_t" {
        ulong *ulong >ulong-array <direct-ulong-array>
    } }
    { "ssize_t" {
        long *long >long-array <direct-long-array>
    } }
    { "time_t" {
        long *long >long-array <direct-long-array>
    } }
     { "gtype" {
        ulong *ulong >ulong-array <direct-ulong-array>
    } }    
}

TUPLE: type-info c-type-word type-word ;

TUPLE: enum-info < type-info ;

TUPLE: bitfield-info < type-info ;

TUPLE: record-info < type-info ;

TUPLE: union-info < type-info ;

TUPLE: callback-info < type-info ;

TUPLE: class-info < type-info ;

TUPLE: interface-info < type-info ;

: aliased-type ( alias -- type )
    aliases get ?at [ aliased-type ] when ;

: get-type-info ( type -- info )
    aliased-type type-infos get at ;

PREDICATE: none-type < type
    [ namespace>> not ] [ name>> "none" = ] bi and ;

PREDICATE: simple-type < type
    aliased-type
    [ namespace>> not ] [ name>> simple-types key? ] bi and ;

PREDICATE: utf8-type < type
    aliased-type
    [ namespace>> not ] [ name>> "utf8" = ] bi and ;

PREDICATE: any-type < type
    aliased-type
    [ namespace>> not ] [ name>> "any" = ] bi and ;
   
PREDICATE: enum-type < type get-type-info enum-info? ;

PREDICATE: bitfield-type < type get-type-info bitfield-info? ;

PREDICATE: record-type < type get-type-info record-info? ;

PREDICATE: union-type < type get-type-info union-info? ;

PREDICATE: callback-type < type get-type-info callback-info? ;

PREDICATE: class-type < type get-type-info class-info? ;

PREDICATE: interface-type < type get-type-info interface-info? ;

: absolute-type ( type -- type' )
    dup {
        [ namespace>> ] [ simple-type? ]
        [ utf8-type? ] [ none-type? ]
    } 1|| [ current-lib get-global >>namespace ] unless ;

