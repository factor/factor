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

IN: styles
USE: combinators
USE: kernel
USE: namespaces
USE: stack

! A style is an alist whose key/value pairs hold
! significance to the 'fwrite-attr' word when applied to a
! stream that supports attributed string output.

: default-style ( -- style )
    #! Push the default style object.
    "styles" get [ "default" get ] bind ;

: paragraph ( -- style )
    #! Push the paragraph break meta-style.
    "styles" get [ "paragraph" get ] bind ;

: <style> ( alist -- )
    #! Create a new style object, cloned from the default
    #! style.
    default-style clone tuck alist> ;

: get-style ( obj-path -- style )
    #! Push a style named by an object path, for example
    #! [ "prompt" ] or [ "vocabularies" "math" ].
    dup [
        "styles" get [ object-path ] bind
        [ default-style ] unless*
    ] [
        drop default-style
    ] ifte ;

: set-style ( style name -- )
    ! XXX: use object path...
    "styles" get [ set ] bind ;

: init-styles ( -- )
    <namespace> "styles" set

    [
        [ "font" | "Monospaced" ]
    ] "default" set-style

    [
        [ "bold" | t ]
    ] "prompt" set-style
    
    [
        [ "ansi-fg" | "0" ]
        [ "ansi-bg" | "2" ]
        [ "fg" | [ 255 0 0 ] ]
    ] "comments" set-style ;
