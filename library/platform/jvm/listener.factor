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

IN: listener
USE: combinators
USE: continuations
USE: interpreter
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: styles
USE: streams
USE: strings
USE: unparser

: <attribute-set> ( -- attribute-set )
    [ ] "javax.swing.text.SimpleAttributeSet" jnew ;

: attribute+ ( attribute-set value key -- )
    transp
    [ "java.lang.Object" "java.lang.Object" ]
    "javax.swing.text.SimpleAttributeSet"
    "addAttribute" jinvoke ;

: style-constant ( name -- key )
    #! javax.swing.text.StyleConstants contains static variables
    #! which key in an AttributeSet.
    "javax.swing.text.StyleConstants" swap jvar-static-get
    ; inline

: swing-attribute+ ( attribute-set value key -- )
    style-constant attribute+ ;

: >color ( triplet -- hex )
    uncons uncons uncons drop
    [ "int" "int" "int" ]
    "java.awt.Color"
    jnew ;

: link-key ( -- attr )
    "factor.listener.FactorListener" "Link" jvar-static-get
    ; inline

: obj>listener-link ( obj -- link )
    #! Listener links are quotations.
    dup string? [
        ! Inspector link.
        unparse " describe-object-path" cat2
    ] when ;

: link-attribute ( attribute-set target -- )
    [ dup t "Underline" swing-attribute+ ] dip
    obj>listener-link link-key attribute+ ;

: style>attribute-set ( -- attribute-set )
    <attribute-set>
    "link" get [ dupd link-attribute ] when*
    "bold" get [ dup t "Bold" swing-attribute+ ] when
    "italics" get [ dup t "Italic" swing-attribute+ ] when
    "underline" get [ dup t "Underline" swing-attribute+ ] when
    "fg" get [ dupd >color "Foreground" swing-attribute+ ] when*
    "bg" get [ dupd >color "Background" swing-attribute+ ] when*
    "font" get [ dupd "FontFamily" swing-attribute+ ] when*
    "size" get [ dupd "FontSize" swing-attribute+ ] when* ;

: reset-attrs ( -- )
    default-style [ style>attribute-set ] bind t
    "listener" get
    [ "javax.swing.text.AttributeSet" "boolean" ]
    "javax.swing.JTextPane"
    "setCharacterAttributes"
    jinvoke ;

: listener-readln* ( continuation -- )
    "listener" get
	[ "factor.Cons" ]
	"factor.listener.FactorListener"
	"readLine" jinvoke ;

: listener-readln ( -- line )
    reset-attrs [ listener-readln* suspend ] callcc1 ;

: listener-write-attr ( string -- )
    style>attribute-set "listener" get
    [ "java.lang.String" "javax.swing.text.AttributeSet" ]
    "factor.listener.FactorListener"
    "insertWithAttrs"
    jinvoke ;

: listener-write ( string -- )
    default-style [ listener-write-attr ] bind ;

!: listener-edit ( string -- )
!    "listener" get
!    [ "java.lang.String" ]
!    "factor.listener.FactorListener"
!    "editLine" jinvoke ;

: <listener-stream> ( listener -- stream )
    #! Creates a stream for reading/writing to the given
    #! listener instance.
    <stream> [
        "listener" set
        ( -- string )
        [ listener-readln ] "freadln" set
        ( string -- )
        [ listener-write ] "fwrite" set
        ( string -- )
        [ listener-write-attr ] "fwrite-attr" set
        ( string -- )
        ![ listener-edit ] "fedit" set
        ( -- )
        [ ] "fflush" set
        ( -- )
        [ ] "fclose" set
        ( string -- )
        [ this fwrite "\n" this fwrite ] "fprint" set
    ] extend ;

: close-listener ( listener -- )
    #! Closes the listener. If no more listeners remain, the
    #! desktop exits.
    "desktop" get
    [ "factor.listener.FactorListener" ]
    "factor.listener.FactorDesktop" "closeListener"
    jinvoke ;

: new-listener-hook ( listener -- )
    #! Called when user opens a new listener in the desktop.
    <namespace> [
        dup "listener" set
        <listener-stream> "stdio" set
        interpreter-loop
        "listener" get close-listener
    ] bind ;

: new-listener ( -- )
    #! Opens a new listener.
    "desktop" get
    [ ] "factor.listener.FactorDesktop" "newListener"
    jinvoke ;

: running-desktop? ( -- )
    this "factor.listener.FactorDesktop" is ;
