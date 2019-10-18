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
USE: math
USE: namespaces
USE: stack
USE: strings
USE: words

: view ( -- view )
    [ ] "org.gjt.sp.jedit.jEdit"
    "getActiveView" jinvoke-static ;

: edit-pane ( -- editPane )
    view
    [ ] "org.gjt.sp.jedit.View" "getEditPane" jinvoke ;

: text-area ( -- textArea )
    edit-pane
    [ ] "org.gjt.sp.jedit.EditPane" "getTextArea" jinvoke ;

: text-area-buffer ( textArea -- buffer )
    [ ] "org.gjt.sp.jedit.textarea.JEditTextArea"
    "getBuffer" jinvoke ;

: buffer ( -- buffer )
    edit-pane
    [ ] "org.gjt.sp.jedit.EditPane" "getBuffer" jinvoke ;

: open-file* ( view parent path newFile props -- buffer )
    [
        "org.gjt.sp.jedit.View"
        "java.lang.String"
        "java.lang.String"
        "boolean"
        "java.util.Hashtable"
    ] "org.gjt.sp.jedit.jEdit" "openFile" jinvoke-static ;

: open-file ( parent path -- buffer )
    view -rot f f open-file* ;

: wait-for-requests ( -- )
    [ ]
    "org.gjt.sp.jedit.io.VFSManager" "waitForRequests"
    jinvoke-static ;

: line-count ( textarea -- lines )
    [ ] "org.gjt.sp.jedit.textarea.JEditTextArea" "getLineCount"
    jinvoke ;

: line>start-offset ( line textarea -- )
    [ "int" ]
    "org.gjt.sp.jedit.textarea.JEditTextArea"
    "getLineStartOffset" jinvoke ;

: set-caret ( caret textarea -- )
    [ "int" ]
    "org.gjt.sp.jedit.textarea.JEditTextArea"
    "setCaretPosition" jinvoke ;

: goto-line* ( line textarea -- )
    tuck line>start-offset swap set-caret ;

: goto-line ( line textarea -- )
    tuck line-count min swap goto-line* ;

: local-jedit-line/file ( line dir file -- )
    open-file [
        wait-for-requests pred text-area goto-line
    ] [
        drop
    ] ifte ;
