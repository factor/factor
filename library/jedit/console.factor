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

IN: console
USE: combinators
USE: continuations
USE: init
USE: interpreter
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: presentation
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

: set-icon-style ( attribute-set icon -- )
    [
        "javax.swing.text.MutableAttributeSet"
        "javax.swing.Icon"
    ] "javax.swing.text.StyleConstants"
    "setIcon" jinvoke-static ;

: <icon> ( resource -- icon )
    resource
    [ "java.net.URL" ]
    "javax.swing.ImageIcon" jnew ;

: swing-attribute+ ( attribute-set value key -- )
    style-constant attribute+ ;

: >color ( triplet -- hex )
    uncons uncons uncons drop
    [ "int" "int" "int" ]
    "java.awt.Color"
    jnew ;

: actions-key ( -- attr )
    "console.ConsolePane" "Actions" jvar-static-get ; inline

: <eval-action> ( label cmd -- action )
    "console" get [
        "java.lang.String"
        "java.lang.String"
        "console.Console"
    ] "console.Console$EvalAction" jnew ;

: >action-array ( list -- array )
    [ "javax.swing.Action" ] coerce ;

: <actions-menu> ( actions -- array )
    [ uncons <eval-action> ] map >action-array ;

: underline-attribute ( attribute-set -- )
    t "Underline" swing-attribute+ ;

: actions-attribute ( attribute-set actions -- )
    <actions-menu> actions-key attribute+ ;

: icon-attribute ( string style value -- )
    dupd <icon> set-icon-style
    >r drop " " r> ;

: style>attribute-set ( string style -- string attribute-set )
    #! We need the string, since outputting an icon changes the
    #! string to " ".
    <attribute-set> swap [
        [ "actions"     dupd actions-attribute ]
        [ "bold"        drop dup t "Bold" swing-attribute+ ]
        [ "italics"     drop dup t "Italic" swing-attribute+ ]
        [ "underline"   drop dup t "Underline" swing-attribute+ ]
        [ "fg"          dupd >color "Foreground" swing-attribute+ ]
        [ "bg"          dupd >color "Background" swing-attribute+ ]
        [ "font"        dupd "FontFamily" swing-attribute+ ]
        [ "size"        dupd "FontSize" swing-attribute+ ]
        [ "icon"        icon-attribute ]
    ] assoc-apply ;

: console-readln* ( continuation -- )
    "console" get [ "factor.Cons" "console.Console" ]
	"factor.jedit.FactorShell" "readLine" jinvoke-static ;

: console-readln ( -- line )
    [ console-readln* toplevel ] callcc1 ;

: console-write-attr ( string style -- )
    style>attribute-set swap "console" get
    [ "javax.swing.text.AttributeSet" "java.lang.String" ]
    "console.Output" "writeAttrs" jinvoke ;

: <console-stream> ( console -- stream )
    #! Creates a stream for reading/writing to the given
    #! console instance.
    <stream> [
        "console" set
        ( -- string )
        [ console-readln ] "freadln" set
        ( string -- )
        [ default-style console-write-attr ] "fwrite" set
        ( string style -- )
        [ console-write-attr ] "fwrite-attr" set
        ( -- )
        [ ] "fflush" set
        ( -- )
        [ ] "fclose" set
        ( string -- )
        [ this fwrite "\n" this fwrite ] "fprint" set
    ] extend ;

: console-hook ( console -- )
    [
        dup "console" set
        <console-stream> "stdio" set
        init-interpreter
    ] with-scope ;
