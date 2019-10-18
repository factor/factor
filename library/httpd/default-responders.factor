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

IN: httpd-responder
USE: httpd
USE: kernel
USE: namespaces
USE: strings

USE: test-responder
USE: inspect-responder
USE: quit-responder
USE: file-responder
USE: resource-responder

#! Remove all existing responders, and create a blank
#! responder table.
global [ <namespace> "httpd-responders" set ] bind

<responder> [
    "404" "responder" set
    [ drop no-such-responder ] "get" set
] extend add-responder

<responder> [
    "test" "responder" set
    [ test-responder ] "get" set
] extend add-responder

<responder> [
    "inspect" "responder" set
    [ inspect-responder ] "get" set
    "global" "default-argument" set
] extend add-responder

<responder> [
    "quit" "responder" set
    [ quit-responder ] "get" set
] extend add-responder

<responder> [
    "file" "responder" set
    [ file-responder ] "get" set
    [ file-responder ] "post" set
    [ file-responder ] "head" set
] extend add-responder

<responder> [
    "resource" "responder" set
    [ resource-responder ] "get" set
] extend add-responder

"file" set-default-responder
