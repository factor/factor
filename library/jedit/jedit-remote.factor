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

IN: jedit
USE: combinators
USE: lists
USE: logic
USE: namespaces
USE: parser
USE: stack
USE: streams
USE: stdio
USE: strings
USE: unparser

: jedit-server-file ( -- path )
    "jedit-server-file" get
    [ "~" get "/.jedit/server" cat2 ] unless* ;

: jedit-server-info ( -- port auth )
    jedit-server-file <filecr> [
        read drop
        read parse-number
        read parse-number
    ] with-stream ;

: bool% ( ? -- str )
    "true" "false" ? % ;

: list>bsh-array% ( list -- code )
    "new String[] {" %
    [ unparse % "," % ] each
    "null}" % ;

: make-jedit-request ( files dir params -- code )
    [
        <%
        "EditServer.handleClient(" %
        "restore" get bool% "," %
        "newView" get bool% "," %
        "newPlainView" get bool% "," %
        unparse % "," %
        list>bsh-array% ");\n" % %>
    ] bind ;

: send-jedit-request ( request -- )
    jedit-server-info swap "localhost" swap <client> [
        big-endian-32 dup str-length big-endian-16 write flush
    ] with-stream ;

: remote-jedit-line/file ( line dir file -- )
    rot "+line:" swap unparse cat2 unit cons swap
    <namespace> [
        "restore" off
        "newView" off
        "newPlainView" off
    ] extend make-jedit-request send-jedit-request ;
