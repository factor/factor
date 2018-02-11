! Copyright (C) 2008, 2009 Joe Groff, Slava Pestov.
! Copyright (C) 2017-2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data
alien.strings classes.struct io.encodings.utf16n kernel make
math namespaces prettyprint sequences specialized-arrays
ui.backend.windows ui.gadgets.worlds ui.gestures
ui.tools.listener windows.com windows.com.wrapper
windows.dropfiles windows.kernel32 windows.ole32 windows.shell32
windows.types ;
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: WCHAR
IN: windows.dragdrop-listener

CONSTANT: E_OUTOFMEMORY -2147024882 ! 0x8007000e

: handle-data-object ( handler:  ( hdrop -- x ) data-object -- filenames )
    FORMATETC <struct>
        CF_HDROP         >>cfFormat
        f                >>ptd
        DVASPECT_CONTENT >>dwAspect
        -1               >>lindex
        TYMED_HGLOBAL    >>tymed
    STGMEDIUM <struct>
    [ IDataObject::GetData ] keep swap succeeded? [
        dup data>>
        [ rot execute( hdrop -- x ) ] with-global-lock
        swap ReleaseStgMedium
    ] [ 2drop f ] if ;

: filenames-from-data-object ( data-object -- filenames )
    \ filenames-from-hdrop swap handle-data-object ;

: filecount-from-data-object ( data-object -- n )
    \ filecount-from-hdrop swap handle-data-object ;

TUPLE: listener-dragdrop world last-drop-effect ;

: <listener-dragdrop> ( world -- object )
    DROPEFFECT_NONE listener-dragdrop boa ;

<<
SYMBOL: +listener-dragdrop-wrapper+
>>

<<
{
    { IDropTarget {
        [ ! HRESULT DragEnter ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            DROPEFFECT_COPY swap 0 set-alien-unsigned-4 3drop
            DROPEFFECT_COPY >>last-drop-effect drop
            S_OK
        ] [ ! HRESULT DragOver ( DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            [
                2drop
                [ world>> children>> first hand-gadget set-global ]
                [ last-drop-effect>> ] bi
            ] dip 0 set-alien-unsigned-4
            S_OK
        ] [ ! HRESULT DragLeave ( )
            drop S_OK
        ] [ ! HRESULT Drop ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            [
                2drop nip
                filenames-from-data-object dropped-files set-global
                key-modifiers <file-drop> hand-gadget get-global propagate-gesture
                DROPEFFECT_COPY
            ] dip 0 set-alien-unsigned-4
            S_OK
        ]
    } }
} <com-wrapper> +listener-dragdrop-wrapper+ set-global
>>

: dragdrop-listener-window ( -- )
    world get dup <listener-dragdrop>
    +listener-dragdrop-wrapper+ get-global com-wrap [
        [ handle>> hWnd>> ] dip
        2dup RegisterDragDrop dup E_OUTOFMEMORY =
        [ drop ole-initialize RegisterDragDrop ] [ 2nip ] if
        check-ole32-error
    ] with-com-interface ;
