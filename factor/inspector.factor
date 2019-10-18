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

: max-str-length ( list -- len )
    ! Returns the length of the longest string in the given
    ! list.
    0 swap [ str-length max ] each ;

: pad-string ( len str -- str )
    str-length - spaces ;

: words. (--)
    ! Print all defined words.
    words [ . ] each ;

: vars. ( -- )
    ! Print a list of defined variables.
    uvars [ print ] each ;

: value/tty ( max [ name , value ] -- ... )
    uncons [ dup [ pad-string ] dip ": " ] dip unparse "\n" ;

: values/tty ( -- ... )
    ! Apply 'expand' or 'str-expand' to this word.
    uvars max-str-length
    uvalues [ over [ value/tty ] dip ] each drop ;

: value/html ( [ name , value ] -- ... )
    uncons [
        [ "<tr><th align=\"left\">" ] dip
        "</th><td><a href=\"inspect.lhtml?" over "\">"
    ] dip
    unparse chars>entities
    "</a></td></tr>" ;

: values/html ( -- ... )
    ! Apply 'expand' or 'str-expand' to this word.
    uvalues [ value/html ] each ;

: inspecting ( obj -- namespace )
    dup has-namespace? [ <objnamespace> ] unless ;

: describe* ( obj quot -- )
    ! Print an informational header about the object, and print
    ! all values in its object namespace.
    swap inspecting [ str-expand ] bind print ;

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
                [ values/tty ] describe*
            ] when*
        ]
    ] cond ;

: describe/html ( obj -- )
    [
        [ worddef? ] [ see/html ]
        [ string?  ] [
            "<pre>" print chars>entities print "</pre>" print
        ]
        [ drop t   ] [
            "<table><tr><th align=\"left\">OBJECT:</th><td>" print
            dup unparse chars>entities write
            "</td></tr>" print

            [
                "<tr><th align=\"left\">CLASS:</th><td>" write
                dup class-of print
                "</td></tr>" print
                "<tr><td colspan=\"2\"><hr></td></tr>" print
                [ values/html ] describe*
            ] when*

            "</table>" print
        ]
    ] cond ;

: object-path ( list -- object )
    ! An object path is a list of strings. Each string is a
    ! variable name in the object namespace at that level.
    ! Returns f if any of the objects are not set.
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
        drop $this [ $namespace ] unless*
    ] ifte ;

: inspect ( obj -- )
    ! Display the inspector for the object, and start a new
    ! REPL bound to the object's namespace.
    inspecting dup describe
    "--------" print
    ! Start a REPL, only if the object is not the dictionary.
    dup $dict = [
        "Cannot enter into dictionary. Use 'see' word." print
    ] [
        "exit    - exit one level of inspector." print
        "suspend - return to top level." print
        dup [
            "    " swap unparse " " cat3 interpreter-loop
        ] bind
    ] ifte ;
