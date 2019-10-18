!:folding=indent:collapseFolds=1:

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

: <listener-stream> ( listener -- stream )
    #! Creates a stream for reading/writing to the given
    #! listener instance.
    <stream> [
        @listener
        ( -- string )
        [ <listener-stream>/freadln ] @freadln
        ( string -- )
        [ f <listener-stream>/fwrite-attr ] @fwrite
        ( string attrs -- )
        [ <listener-stream>/fwrite-attr ] @fwrite-attr
        ( string -- )
        [ <listener-stream>/fedit ] @fedit
        ( -- )
        [ ] @fflush
        ( -- )
        [ ] @fclose
        ( string -- )
        [ this fwrite "\n" this fwrite ] @fwriteln
    ] extend ;

: <listener-stream>/freadln ( -- line )
    [
        $listener
        [ "factor.Cons" ]
        "factor.listener.FactorListener"
        "readLine" jinvoke
        suspend
    ] callcc1 ;

: obj>listener-link ( obj -- link )
    #! Listener links are quotations.
    dup string? [
        ! Inspector link.
        unparse " describe-object-path" cat2
    ] when ;

: <listener-stream>/fwrite-attr ( string attrs -- )
    "link" swap assoc dup [
        obj>listener-link
        $listener
        [ "java.lang.String" "java.lang.String" ]
        "factor.listener.FactorListener"
        "insertLink" jinvoke
    ] [
        drop
        $listener
        [ "java.lang.String" ]
        "factor.listener.FactorListener"
        "insertText" jinvoke
    ] ifte ;

: <listener-stream>/fedit ( string -- )
    $listener
    [ "java.lang.String" ]
    "factor.listener.FactorListener"
    "editLine" jinvoke ;

: new-listener-hook ( listener -- )
    #! Called when user opens a new listener in the desktop.
    <namespace> [
        <listener-stream> @stdio
        initial-interpreter-loop
    ] bind ;

: new-listener ( -- )
    #! Opens a new listener.
    this [ ] "factor.listener.FactorDesktop" "newListener"
    jinvoke ;

: running-desktop? ( -- )
    this "factor.listener.FactorDesktop" is ;
