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

IN: irc
USE: arithmetic
USE: combinators
USE: errors
USE: inspector
USE: interpreter
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: streams
USE: strings
USE: words
USE: unparser

: irc-register ( -- )
    "USER " write
    "user" get write " " write
    "host" get write " " write
    "server" get write " " write
    "realname" get write " " print

    "NICK " write
    "nick" get print ;

: irc-join ( channel -- )
    "JOIN " write print ;

: irc-message ( message recepients -- )
    "PRIVMSG " write write " :" write print ;

: irc-action ( message recepients -- )
    "ACTION " write write " :" write print ;

: keep-datastack ( quot -- )
    datastack [ call ] dip set-datastack drop ;

: irc-stream-write ( string -- )
    dup "buf" get sbuf-append
    ends-with-newline? [
        "buf" get sbuf>str
        0 "buf" get set-sbuf-length
        "\n" split [ dup f-or-"" [ drop ] [ "recepient" get irc-message ] ifte ] each
    ] when ;

: <irc-stream> ( stream recepient -- stream )
    <stream> [
        "recepient" set
        "stdio" set
        100 <sbuf> "buf" set
        [
            irc-stream-write
        ] "fwrite" set
    ] extend ;

: irc-eval ( line -- )
    [
        [
            eval
        ] [
            default-error-handler
        ] catch
    ] keep-datastack drop ;

: with-irc-stream ( recepient quot -- )
    [
        [ "stdio" get swap <irc-stream> "stdio" set ] dip
        call
    ] with-scope ;

: irc-action-quot ( action -- quot )
    [
        [ "eval" swap [ irc-eval ] with-irc-stream ]
        [ "see" swap [ see terpri ] with-irc-stream ]
        [ "join" nip irc-join ]
        [ "quit" 2drop global [ "irc-quit-flag" on ] bind ]
    ] assoc [ [ 2drop ] ] unless* ;

: irc-action-handler ( recepient message -- )
    " " split1 swap irc-action-quot call ;

: irc-input ( line -- )
    #! Handle a line of IRC input.
    dup
    " PRIVMSG " split1 nip [
        ":" split1 dup [
            irc-action-handler
        ] [
            drop
        ] ifte
    ] when*

    global [ print ] bind ;

: irc-quit-flag ( -- ? )
    global [ "irc-quit-flag" get ] bind ;

: clear-irc-quit-flag ( -- ? )
    global [ "irc-quit-flag" off ] bind ;

: irc-loop ( -- )
    irc-quit-flag [
        read [ irc-input irc-loop ] when*
    ] unless clear-irc-quit-flag ;

: irc ( channels -- )
    irc-register
    "identify foobar" "NickServ" irc-message
    [ irc-join ] each
    irc-loop ;

: irc-test
    "factorbot" "user" set
    "emu" "host" set
    "irc.freenode.net" "server" set
    "Factor" "realname" set
    "factorbot" "nick" set
    "irc.freenode.net" 6667 <client> [
        [ "#concatenative" ] irc
    ] with-stream ;
