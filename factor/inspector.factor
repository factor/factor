!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

: inspecting ( obj -- namespace )
    dup has-namespace? [ <objnamespace> ] unless ;

: describe ( obj -- )
    [
        [ worddef? ] [ see ]
        [ stack?   ] [ stack>list print-numbered-list ]
        [ string?  ] [ print ]
        [ drop t   ] [
            "OBJECT: " write dup .
            [
                "CLASS : " write dup class-of print
                "--------" print
                inspecting vars-values.
            ] when*
        ]
    ] cond ;

: object-path ( list -- object )
    #! An object path is a list of strings. Each string is a
    #! variable name in the object namespace at that level.
    #! Returns f if any of the objects are not set.
    dup [
        unswons $ dup [
            ! Defined.
            inspecting [ object-path ] bind
        ] [
            ! Undefined. Just return f.
            2drop f
        ] ifte
    ] [
        ! Current object.
        drop this
    ] ifte ;

: global-object-path ( string -- object )
    #! An object path based from the global namespace.
    "'" split global [ object-path ] bind ;

: relative>absolute-object-path ( string -- string )
    $object-path [ "'" rot cat3 ] when* ;

: describe-object-path ( string -- )
    <namespace> [
        dup @object-path
        global-object-path describe
    ] bind ;

: inspect ( obj -- )
    #! Display the inspector for the object, and start a new
    #! REPL bound to the object's namespace.
    dup describe
    "--------" print
    ! Start a REPL.
    "exit    - exit one level of inspector." print
    "suspend - return to top level." print
    dup inspecting [
        "    " swap unparse " " cat3 interpreter-loop
    ] bind ;
