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
USE: io-internals
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings

: <file> ( path -- file )
    #! Create an empty file object. Do not use this directly.
    <namespace> [
        "path" set
        f "exists" set
        f "directory" set
        0 "permissions" set
        0 "size" set
        0 "mod-time" set
    ] extend ;

: path>file ( path -- file )
    dup <file> [
        stat [
            "exists" on
            [
                "directory"
                "permissions"
                "size"
                "mod-time"
            ] [
                set
            ] 2each
        ] when*
    ] extend ;

: ?path>file ( path/file -- file )
    dup string? [ path>file ] when ;

: exists? ( file -- ? )
    ?path>file "exists" swap get* ;

: directory? ( file -- ? )
    ?path>file "directory" swap get* ;

: dirent>file ( parent name dir? -- file )
    -rot "/" swap cat3 <file> [ "directory" set ] extend ;

: directory ( file -- list )
    #! Push a list of file objects in the directory.
    dup read-dir [ dupd uncons dirent>file ] map nip ;
