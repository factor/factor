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

IN: file-responder
USE: combinators
USE: errors
USE: kernel
USE: files
USE: httpd
USE: httpd-responder
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: streams
USE: strings

: parse-object-name ( filename -- argument filename )
    dup [ "?" split1 swap ] [ "/" ] ifte
    "doc-root" get swap cat2 ;

: serve-script ( argument filename -- )
    [ swap "argument" set run-file ] with-scope ;

: file-header ( mime-type -- header )
    "200 Document follows" swap response ;

: copy-and-close ( from -- )
    [ dupd "stdio" get fcopy ] [ >r fclose r> rethrow ] catch ;

: serve-static ( argument filename mime-type -- )
    file-header print <filebr> "stdio" get fcopy drop ;

: serve-file ( argument filename -- )
    dup mime-type dup "application/x-factor-server-page" = [
        drop serve-script
    ] [
        serve-static
    ] ifte ;

: file-responder ( filename -- )
    "doc-root" get [
        parse-object-name dup exists? [
            serve-file
        ] [
            2drop "404 not found" httpd-error
        ] ifte
    ] [
        drop "404 doc-root not set" httpd-error
    ] ifte ;
