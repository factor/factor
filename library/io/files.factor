! :folding=indent:collapseFolds=1:

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

IN: files
USE: combinators
USE: hashtables
USE: lists
USE: logic
USE: namespaces
USE: presentation
USE: stack
USE: stdio
USE: strings

: exists? ( file -- ? )
    stat >boolean ;

: directory? ( file -- ? )
    stat dup [ car ] when ;

: directory ( dir -- list )
    #! List a directory.
    (directory) str-sort ;

: file-length ( file -- length )
    stat dup [ cdr cdr car ] when ;

: file-actions ( -- list )
    [
        [ "Push"             | ""           ]
        [ "Run file"         | "run-file"   ]
        [ "List directory"   | "directory." ]
        [ "Change directory" | "cd"         ]
    ] ;

: set-mime-types ( assoc -- )
    "mime-types" global set-hash ;

: mime-types ( -- assoc )
    "mime-types" global hash ;

: file-extension ( filename -- extension )
    "." split cdr dup [ last ] when ;

: mime-type ( filename -- mime-type )
    file-extension mime-types assoc [ "text/plain" ] unless* ;

: dir-icon
    "/library/icons/Folder.png" ;

: file-icon
    "/library/icons/File.png" ;

: file-icon. ( path -- )
    directory? dir-icon file-icon ? write-icon ;

: file-link. ( dir name -- )
    tuck "/" swap cat3 dup "file-link" swons swap
    file-actions <actions> "actions" swons
    t "underline" swons
    3list write-attr ;

: file. ( dir name -- )
    #! If "doc-root" set, create links relative to it.
    2dup "/" swap cat3 file-icon. " " write file-link. terpri ;

: directory. ( dir -- )
    #! If "doc-root" set, create links relative to it.
    dup directory [
        dup [ "." ".." ] contains? [
            drop
        ] [
            dupd file.
        ] ifte
    ] each drop ;

: pwd cwd print ;
: dir. cwd directory. ;

[
    [ "html"   | "text/html"                        ]
    [ "txt"    | "text/plain"                       ]
                                                    
    [ "gif"    | "image/gif"                        ]
    [ "png"    | "image/png"                        ]
    [ "jpg"    | "image/jpeg"                       ]
    [ "jpeg"   | "image/jpeg"                       ]
                                                    
    [ "jar"    | "application/octet-stream"         ]
    [ "zip"    | "application/octet-stream"         ]
    [ "tgz"    | "application/octet-stream"         ]
    [ "tar.gz" | "application/octet-stream"         ]
    [ "gz"     | "application/octet-stream"         ]
                                                    
    [ "factor" | "application/x-factor"             ]
    [ "factsp" | "application/x-factor-server-page" ]
] set-mime-types
