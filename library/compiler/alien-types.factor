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
USE: combinators
USE: compiler
USE: errors
USE: lists
USE: math
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: words

! Some code for interfacing with C structures.

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
        dup "c-types" get get* dup [
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

: define-constructor ( len -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    [ <local-alien> ] cons
    <% "<" % "struct-name" get % ">" % %>
    "in" get create swap
    define-compound ;

: define-struct-type ( -- )
    #! The setter just throws an error for now.
    [
        [ alien-cell <alien> ] "getter" set
        "unbox_alien" "unboxer" set
        "box_alien" "boxer" set
        cell "width" set
    ] "struct-name" get "*" cat2 define-c-type ;

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    define-constructor define-struct-type ; parsing

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
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "uint" define-c-type

[
    [ alien-2 ] "getter" set
    [ set-alien-2 ] "setter" set
    2 "width" set
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "short" define-c-type

[
    [ alien-2 ] "getter" set
    [ set-alien-2 ] "setter" set
    2 "width" set
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "ushort" define-c-type

[
    [ alien-1 ] "getter" set
    [ set-alien-1 ] "setter" set
    1 "width" set
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "char" define-c-type

[
    [ alien-1 ] "getter" set
    [ set-alien-1 ] "setter" set
    1 "width" set
    "box_integer" "boxer" set
    "unbox_integer" "unboxer" set
] "uchar" define-c-type

[
    [ alien-4 ] "getter" set
    [ set-alien-4 ] "setter" set
    cell "width" set
    "box_c_string" "boxer" set
    "unbox_c_string" "unboxer" set
] "char*" define-c-type
