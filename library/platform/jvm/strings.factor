!:folding=indent:collapseFolds=0:

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

IN: strings
USE: kernel
USE: logic
USE: stack

: char? ( obj -- boolean )
    "java.lang.Character" is ;

: >char ( obj -- char )
    "char" coerce ; inline

: string? ( obj -- ? )
    dup char? swap "java.lang.String" is or ;

: str-length ( str -- length )
    [ ] "java.lang.String" "length" jinvoke ;

: substring ( start end str -- str )
    [ "int" "int" ] "java.lang.String" "substring"
    jinvoke ;

: >str ( obj -- string )
    ! Returns the Java string representation of this object.
    [ ] "java.lang.Object" "toString" jinvoke ;

: >bytes ( string -- array )
    ! Converts a string to an array of ASCII bytes. An exception
    ! is thrown if the string contains non-ASCII characters.
    "ASCII" swap
    [ "java.lang.String" ] "java.lang.String" "getBytes"
    jinvoke ;

: str-nth ( index str -- char )
    [ "int" ] "java.lang.String" "charAt" jinvoke ;

: >lower ( str -- str )
    [ ] "java.lang.String" "toLowerCase" jinvoke ;

: >upper ( str -- str )
    [ ] "java.lang.String" "toUpperCase" jinvoke ;

: index-of* ( index string substring -- index )
    dup char? [
        -rot
        ! Why is the first parameter an int and not a char?
        [ "int" "int" ]
        "java.lang.String" "indexOf"
        jinvoke
    ] [
        -rot
        [ "java.lang.String" "int" ]
        "java.lang.String" "indexOf"
        jinvoke
    ] ifte ;

: str-compare ( str1 str2 -- n )
    swap [ "java.lang.String" ] "java.lang.String" "compareTo"
    jinvoke ;
