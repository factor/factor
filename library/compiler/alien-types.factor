! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: alien
USE: compiler
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: strings
USE: words

! Some code for interfacing with C structures.

: BEGIN-ENUM:
    #! C-style enumerations. Their use is not encouraged unless
    #! it is for C library interfaces. Used like this:
    #!
    #! BEGIN-ENUM 0
    #!     ENUM: x
    #!     ENUM: y
    #!     ENUM: z
    #! END-ENUM
    #!
    #! This is the same as : x 0 ; : y 1 ; : z 2 ;.
    scan str>number ; parsing

: ENUM:
    dup CREATE swap unit define-compound succ ; parsing

: END-ENUM
    drop ; parsing

: <c-type> ( -- type )
    <namespace> [
        [ "No setter" throw ] "setter" set
        [ "No getter" throw ] "getter" set
        "no boxer" "boxer" set
        "no unboxer" "unboxer" set
        0 "width" set
    ] extend ;

: c-types ( -- ns )
    global [ "c-types" get ] bind ;

: c-type ( name -- type )
    global [
        dup "c-types" get hash dup [
            nip
        ] [
            drop "No such C type: " swap cat2 throw
        ] ifte
    ] bind ;

: define-c-type ( quot name -- )
    c-types [ >r <c-type> swap extend r> set ] bind ;

: define-getter ( offset type name -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    "in" get create >r
    [ "getter" get ] bind cons r> swap define-compound ;

: define-setter ( offset type name -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    "set-" swap cat2 "in" get create >r
    [ "setter" get ] bind cons r> swap define-compound ;

: define-field ( offset type name -- offset )
    >r c-type dup >r [ "width" get ] bind align r> r>
    "struct-name" get swap "-" swap cat3
    ( offset type name -- )
    3dup define-getter 3dup define-setter
    drop [ "width" get ] bind + ;

: define-member ( max type -- max )
    c-type [ "width" get ] bind max ;

: define-constructor ( width -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    [ <local-alien> ] cons
    [ "<" , "struct-name" get , ">" , ] make-string
    "in" get create swap
    define-compound ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    [ "width" set ] "struct-name" get define-c-type
    "void*" c-type "struct-name" get "*" cat2 c-types set-hash ;

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    dup define-constructor define-struct-type ; parsing

: BEGIN-UNION: ( -- max )
    scan "struct-name" set  0 ; parsing

: MEMBER: ( max -- max )
    scan define-member ; parsing

: END-UNION ( max -- )
    dup define-constructor define-struct-type ; parsing

: NULL ( -- null )
    #! C null value.
    0 <alien> ;

global [ <namespace> "c-types" set ] bind

[
    [ alien-cell <alien> ] "getter" set
    [ set-alien-cell ] "setter" set
    cell "width" set
    "box_alien" "boxer" set
    "unbox_alien" "unboxer" set
] "void*" define-c-type

[
    [ alien-4 ] "getter" set
    [ set-alien-4 ] "setter" set
    4 "width" set
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "int" define-c-type

[
    [ alien-4 ] "getter" set
    [ set-alien-4 ] "setter" set
    4 "width" set
    "box_cell" "boxer" set
    "unbox_cell" "unboxer" set
] "uint" define-c-type

[
    [ alien-2 ] "getter" set
    [ set-alien-2 ] "setter" set
    2 "width" set
    "box_signed_2" "boxer" set
    "unbox_signed_2" "unboxer" set
] "short" define-c-type

[
    [ alien-2 ] "getter" set
    [ set-alien-2 ] "setter" set
    2 "width" set
    "box_cell" "boxer" set
    "unbox_cell" "unboxer" set
] "ushort" define-c-type

[
    [ alien-1 ] "getter" set
    [ set-alien-1 ] "setter" set
    1 "width" set
    "box_signed_1" "boxer" set
    "unbox_signed_1" "unboxer" set
] "char" define-c-type

[
    [ alien-1 ] "getter" set
    [ set-alien-1 ] "setter" set
    1 "width" set
    "box_cell" "boxer" set
    "unbox_cell" "unboxer" set
] "uchar" define-c-type

[
    [ alien-4 ] "getter" set
    [ set-alien-4 ] "setter" set
    cell "width" set
    "box_c_string" "boxer" set
    "unbox_c_string" "unboxer" set
] "char*" define-c-type

[
    [ alien-4 0 = not ] "getter" set
    [ 1 0 ? set-alien-4 ] "setter" set
    cell "width" set
    "box_boolean" "boxer" set
    "unbox_boolean" "unboxer" set
] "bool" define-c-type
