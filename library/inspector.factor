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

IN: inspector
USE: combinators
USE: format
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: styles
USE: words
USE: prettyprint
USE: unparser
USE: vectors
USE: vocabularies

: relative>absolute-object-path ( string -- string )
    "object-path" get [ "'" rot cat3 ] when* ;

: vars. ( -- )
    #! Print a list of defined variables.
    vars [ print ] each ;

: var. ( [ name | value ] -- )
    uncons unparse swap relative>absolute-object-path
    default-style clone [ "link" set write-attr ] bind ;

: value. ( max [ name | value ] -- )
    dup [ car tuck pad-string write write ] dip
    ": " write
    var. terpri ;

: describe-banner ( obj -- )
    "OBJECT: " write dup .
    "CLASS : " write class-of print
    "-------" print ;

: describe-namespace ( namespace -- )
    [ vars max-str-length vars-values ] bind
    [ dupd value. ] each drop ;

: describe ( obj -- )
    [
        [ word? ]
        [ see ]
        
        [ string? ]
        [ print ]
        
        [ has-namespace? ]
        [ dup describe-banner describe-namespace ]
        
        [ drop t ]
        [ prettyprint ]
    ] cond ;

: describe-object-path ( string -- )
    <namespace> [
        dup "object-path" set
        global-object-path describe
    ] bind ;
