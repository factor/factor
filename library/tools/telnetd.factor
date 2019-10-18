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

IN: telnetd
USE: combinators
USE: errors
USE: listener
USE: kernel
USE: logging
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: threads

: telnet-client ( socket -- )
    dup [
        "client" set
        log-client
        listener-loop
    ] with-stream ;

: telnet-connection ( socket -- )
    #! We don't do multitasking in JFactor.
    java? [
        telnet-client
    ] [
        [ telnet-client ] in-thread drop
    ] ifte ;

: quit-flag ( -- ? )
    global [ "telnetd-quit-flag" get ] bind ;

: clear-quit-flag ( --  )
    global [ f "telnetd-quit-flag" set ] bind ;

: telnetd-loop ( server -- server )
    quit-flag [
        dup >r accept telnet-connection r>
        telnetd-loop
    ] unless ;

: telnetd ( port -- )
    [
        <server> [
            telnetd-loop
        ] [
            clear-quit-flag swap fclose rethrow
        ] catch
    ] with-logging ;
