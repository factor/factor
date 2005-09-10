! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler compiler-backend errors generic
hashtables kernel kernel-internals lists math namespaces parser
sequences sequences-internals strings words ;

: <c-type> ( -- type )
    {{
        [[ "setter" [ "No setter" throw ] ]]
        [[ "getter" [ "No getter" throw ] ]]
        [[ "boxer" "no boxer" ]]
        [[ "unboxer" "no unboxer" ]]
        [[ "reg-class" << int-regs f >> ]]
        [[ "width" 0 ]]
    }} clone ;

SYMBOL: c-types

: c-type ( name -- type )
    dup c-types get hash [ ] [
        "No such C type: " swap append throw f
    ] ?ifte ;

: c-size ( name -- size )
    c-type [ "width" get ] bind ;

: define-c-type ( quot name -- )
    >r <c-type> [ swap bind ] keep r> c-types get set-hash ;
    inline

: <c-object> ( size -- c-ptr ) cell / ceiling <byte-array> ;

: <c-array> ( n size -- c-ptr ) * <c-object> ;

: define-pointer ( type -- )
    "void*" c-type swap "*" append c-types get set-hash ;

: define-deref ( name vocab -- )
    >r dup "*" swap append r> create
    "getter" rot c-type hash 0 swons define-compound ;

: c-constructor ( name vocab -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    dupd constructor-word
    swap c-size [ <c-object> ] cons
    define-compound ;

: array-constructor ( name vocab -- )
    #! Make a word <foo-array> ( n -- byte-array ).
    >r dup "-array" append r> constructor-word
    swap c-size [ <c-array> ] cons
    define-compound ;

: define-nth ( name vocab -- )
    #! Make a word foo-nth ( n alien -- dsplaced-alien ).
    >r dup "-nth" append r> create
    swap dup c-size [ rot * ] cons "getter" rot c-type hash
    append define-compound ;

: define-set-nth ( name vocab -- )
    #! Make a word foo-nth ( n alien -- dsplaced-alien ).
    >r "set-" over "-nth" append3 r> create
    swap dup c-size [ rot * ] cons "setter" rot c-type hash
    append define-compound ;

: define-out ( name vocab -- )
    #! Out parameter constructor for integral types.
    dupd constructor-word
    swap c-type [
        [
            "width" get , \ <c-object> , \ tuck , 0 ,
            "setter" get %
        ] [ ] make
    ] bind define-compound ;

: init-c-type ( name vocab -- )
    over define-pointer
    2dup c-constructor
    2dup array-constructor
    define-nth ;

: define-primitive-type ( quot name -- )
    [ define-c-type ] keep "alien"
    2dup init-c-type
    2dup define-deref
    2dup define-set-nth
    define-out ;

: (typedef) c-types get [ >r get r> set ] bind ;

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;

global [ c-types nest drop ] bind
