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
USE: lists
USE: namespaces
USE: stack
USE: strings

: set-mime-types ( assoc -- )
    "mime-types" global set* ;

: mime-types ( -- assoc )
    "mime-types" global get* ;

: file-extension ( filename -- extension )
    "." split cdr dup [ last ] when ;

: mime-type ( filename -- mime-type )
    file-extension mime-types assoc [ "text/plain" ] unless* ;

[
    [ "html"   | "text/html"                ]
    [ "txt"    | "text/plain"               ]
                                           
    [ "gif"    | "image/gif"                ]
    [ "png"    | "image/png"                ]
    [ "jpg"    | "image/jpeg"               ]
    [ "jpeg"   | "image/jpeg"               ]
               
    [ "jar"    | "application/octet-stream" ]
    [ "zip"    | "application/octet-stream" ]
    [ "tgz"    | "application/octet-stream" ]
    [ "tar.gz" | "application/octet-stream" ]
    [ "gz"     | "application/octet-stream" ]
      
    [ "factor" | "application/x-factor"     ]
] set-mime-types
