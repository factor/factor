! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.strings continuations
fry io.encodings.utf16n kernel literals math namespaces
sequences ui.backend.windows ui.gadgets.worlds ui.gestures
windows.messages windows.shell32 windows.types windows.user32 ;
IN: windows.dropfiles

: filecount-from-hdrop ( hdrop -- n )
    0xFFFFFFFF f 0 DragQueryFile ;

: filenames-from-hdrop ( hdrop -- filenames )
    dup filecount-from-hdrop <iota>
    [
        2dup f 0 DragQueryFile 1 + ! get size of filename buffer
        dup WCHAR <c-array>
        [ swap DragQueryFile drop ] keep
        utf16n alien>string
    ] with map ;

! : point-from-hdrop ( hdrop -- loc )
!    POINT <struct> [ DragQueryPoint drop ] keep [ x>> ] [ y>> ] bi 2array ;

: handle-wm-dropfiles ( hdrop -- )
    <alien> [ filenames-from-hdrop dropped-files set-global ] [ DragFinish ] bi
    key-modifiers <file-drop> hand-gadget get-global propagate-gesture ;

! The ChangeWindowMessageFilter has a global per-process effect, and so is the
! list of wm-handlers. Therefore, there is no benefit in using the stricter
! ChangeWindowMessageFilterEx approach. Plus, the latter is not in Vista.
: (init-message-filter) ( -- )
    ${ WM_DROPFILES WM_COPYDATA WM_COPYGLOBALDATA }
    [ MSGFLT_ADD ChangeWindowMessageFilter win32-error=0/f ] each ;

: do-once ( guard-variable quot -- )
    dupd '[ t _ set-global @ ] [ get-global ] dip unless ; inline

! Ignore the errors: on WinXP the function is missing, and is not needed.
: init-message-filter ( -- )
    \ init-message-filter [
        [ (init-message-filter) ] [ drop ] recover
    ] do-once ;

: install-wm-handler ( -- )
    [ drop 2nip handle-wm-dropfiles 0 ] WM_DROPFILES add-wm-handler ;

: hwnd-accept-files ( hwnd -- )
    TRUE DragAcceptFiles init-message-filter install-wm-handler ;

: hwnd-reject-files ( hwnd -- )
    f DragAcceptFiles ;

: world-accept-files ( world -- )
    handle>> hWnd>> hwnd-accept-files ;

: world-reject-files ( world -- )
    handle>> hWnd>> hwnd-accept-files ;

: accept-files ( -- )
    world get world-accept-files ;

: reject-files ( -- )
    world get world-reject-files ;
