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
USE: kernel
USE: lists
USE: logic
USE: stack
USE: strings
USE: namespaces

: <file> ( path -- file )
    dup "java.io.File" is not [
        [ "java.lang.String" ] "java.io.File" jnew
    ] when ;

: delete ( file -- ? )
    #! Delete a file.
    <file> [ ] "java.io.File" "delete" jinvoke ;

: exists? ( file -- boolean )
    <file> [ ] "java.io.File" "exists" jinvoke ;

: directory? ( file -- boolean )
    <file> [ ] "java.io.File" "isDirectory" jinvoke ;

: directory ( file -- listing )
    <file> [ ] "java.io.File" "list" jinvoke array>list str-sort ;

: rename ( from to -- ? )
    ! Rename file 'from' to 'to'. These can be paths or
    ! java.io.File instances.
    <file> swap <file>
    [ "java.io.File" ] "java.io.File" "renameTo"
    jinvoke ;

: file-length ( file -- size )
    <file> [ ] "java.io.File" "length" jinvoke ;

: cwd ( -- dir )
    global [ "cwd" get ] bind ;

: cd ( dir --)
    global [ "cwd" set ] bind ;

global [ "user.dir" system-property "cwd" set ] bind
