! :folding=indent:collapseFolds=1:

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
USE: hashtables
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

: relative>absolute-object-path ( string -- string )
    "object-path" get [ "'" rot cat3 ] when* ;

: vars. ( -- )
    #! Print a list of defined variables.
    vars [ print ] each ;

: var. ( [ name | value ] -- )
    uncons unparse swap relative>absolute-object-path
    default-style clone [ "link" set write-attr ] bind ;

: var-name. ( max name -- )
    default-style clone [
        tuck pad-string write
        dup relative>absolute-object-path "link" set
        write-attr
    ] bind ;

: value. ( max name value -- )
    >r var-name. ": " write r> . ;

: ?unparse ( obj -- str )
    dup string? [ unparse ] unless ;

: alist-keys>str ( alist -- alist )
    #! Unparse non-string keys.
    [ unswons ?unparse swons ] inject ;

: alist-sort ( list -- list )
    [ swap car swap car str-lexi> ] sort ;

: name-padding ( alist -- col )
    [ car ] inject max-str-length ;

: (describe-assoc) ( alist -- )
    dup name-padding swap
    [ dupd uncons value. ] each drop ;

: describe-assoc ( alist -- )
    alist-keys>str alist-sort (describe-assoc) ;
   
: describe-namespace ( namespace -- )
    [ vars-values ] bind describe-assoc ;

: describe-hashtable ( hashtables -- )
    hash>alist describe-assoc ;

: describe ( obj -- )
    [
        [ word? ]
        [ see ]
        
        [ string? ]
        [ print ]
        
        [ assoc? ]
        [ describe-assoc ]
        
        [ hashtable? ]
        [ describe-hashtable ]
        
        [ has-namespace? ]
        [ describe-namespace ]
        
        [ drop t ]
        [ prettyprint ]
    ] cond ;

: describe-object-path ( string -- )
    [
        dup "object-path" set
        "'" split global [ object-path ] bind describe
    ] with-scope ;
