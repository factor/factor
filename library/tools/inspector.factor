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
USE: kernel
USE: hashtables
USE: lists
USE: namespaces
USE: stdio
USE: strings
USE: presentation
USE: words
USE: prettyprint
USE: unparser
USE: vectors
USE: math

: relative>absolute-object-path ( string -- string )
    "object-path" get [ "'" rot cat3 ] when* ;

: vars. ( -- )
    #! Print a list of defined variables.
    namespace hash-keys [.] ;

: object-actions ( -- alist )
    [
        [ "Describe" | "describe-path"  ]
        [ "Push"     | "lookup"         ]
    ] ;

: link-style ( path -- style )
    relative>absolute-object-path
    dup "object-link" swons swap
    object-actions <actions> "actions" swons
    t "underline" swons
    3list
    default-style append ;

: pad-string ( len str -- str )
    str-length - " " fill ;

: var-name. ( max name -- )
    tuck unparse pad-string write dup link-style
    swap unparse swap write-attr ;

: value. ( max name value -- )
    >r var-name. ": " write r> . ;

: max-str-length ( list -- len )
    #! Returns the length of the longest string in the given
    #! list.
    0 swap [ str-length max ] each ;

: name-padding ( alist -- col )
    [ car unparse ] map max-str-length ;

: describe-assoc ( alist -- )
    dup name-padding swap
    [ dupd uncons value. ] each drop ;

: alist-sort ( list -- list )
    [ swap car unparse swap car unparse str-lexi> ] sort ;

: describe-hashtable ( hashtables -- )
    hash>alist alist-sort describe-assoc ;

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
        
        [ drop t ]
        [ prettyprint ]
    ] cond ;

: lookup ( str -- object )
    global [ "'" split object-path ] bind ;

: describe-path ( string -- )
    [ dup "object-path" set lookup describe ] with-scope ;
