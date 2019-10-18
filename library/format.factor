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

IN: format
USE: combinators
USE: kernel
USE: math
USE: namespaces
USE: strings
USE: stack

: decimal-split ( string -- string string )
    #! Split a string before and after the decimal point.
    dup "." index-of dup -1 = [ drop f ] [ str// ] ifte ;

: decimal-tail ( count str -- string )
    #! Given a decimal, trims all but a count of decimal places.
    [ str-length min ] keep str-head ;

: decimal-cat ( before after -- string )
    #! If after is of zero length, return before, otherwise
    #! return "before.after".
    dup str-length 0 = [
        drop
    ] [
        "." swap cat3
    ] ifte ;

: decimal-places ( num count -- string )
    #! Trims the number to a count of decimal places.
    >r decimal-split dup [
        r> swap decimal-tail decimal-cat
    ] [
        r> 2drop
    ] ifte ;

: digits ( string count -- string )
    #! Make sure string has at least count digits, padding it
    #! with zeroes on the left if needed.
    over str-length - dup 0 <= [
        drop
    ] [
        "0" fill swap cat2
    ] ifte ;

: pad-string ( len str -- str )
    str-length - " " fill ;
