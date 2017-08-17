USING: accessors alien.accessors alien.data alien.strings
classes.struct io.encodings.utf16n kernel make math namespaces
prettyprint sequences specialized-arrays
ui.gadgets.worlds ui.tools.listener windows.com
windows.com.wrapper windows.kernel32 windows.ole32
windows.shell32 windows.types ;
SPECIALIZED-ARRAY: WCHAR
IN: windows.dragdrop-listener

: filenames-from-hdrop ( hdrop -- filenames )
    dup 0xFFFFFFFF f 0 DragQueryFile ! get count of files
    [
        2dup f 0 DragQueryFile 1 + ! get size of filename buffer
        dup WCHAR <c-array>
        [ swap DragQueryFile drop ] keep
        utf16n alien>string
    ] with map ;

: filenames-from-data-object ( data-object -- filenames )
    FORMATETC <struct>
        CF_HDROP         >>cfFormat
        f                >>ptd
        DVASPECT_CONTENT >>dwAspect
        -1               >>lindex
        TYMED_HGLOBAL    >>tymed
    STGMEDIUM <struct>
    [ IDataObject::GetData ] keep swap succeeded? [
        dup data>>
        [ filenames-from-hdrop ] with-global-lock
        swap ReleaseStgMedium
    ] [ drop f ] if ;

TUPLE: listener-dragdrop hWnd last-drop-effect ;

: <listener-dragdrop> ( hWnd -- object )
    DROPEFFECT_NONE listener-dragdrop boa ;

SYMBOL: +listener-dragdrop-wrapper+
{
    { IDropTarget {
        [ ! HRESULT DragEnter ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            [
                2drop
                filenames-from-data-object
                length 1 = [ DROPEFFECT_COPY ] [ DROPEFFECT_NONE ] if
                dup
            ] dip 0 set-alien-unsigned-4
            >>last-drop-effect drop
            S_OK
        ] [ ! HRESULT DragOver ( DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            [ 2drop last-drop-effect>> ] dip 0 set-alien-unsigned-4
            S_OK
        ] [ ! HRESULT DragLeave ( )
            drop S_OK
        ] [ ! HRESULT Drop ( IDataObject* pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect )
            [
                2drop nip
                filenames-from-data-object
                dup length 1 = [
                    first unparse [ "USE: parser " % % " run-file" % ] "" make
                    eval-listener
                    DROPEFFECT_COPY
                ] [ drop DROPEFFECT_NONE ] if
            ] dip 0 set-alien-unsigned-4
            S_OK
        ]
    } }
} <com-wrapper> +listener-dragdrop-wrapper+ set-global

: dragdrop-listener-window ( -- )
    world get handle>> hWnd>> dup <listener-dragdrop>
    +listener-dragdrop-wrapper+ get-global com-wrap
    [ RegisterDragDrop check-ole32-error ] with-com-interface ;
