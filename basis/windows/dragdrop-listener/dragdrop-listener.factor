USING: alien.strings io.encodings.utf16n windows.com
windows.com.wrapper combinators windows.kernel32 windows.ole32
windows.shell32 kernel accessors windows.types
prettyprint namespaces ui.tools.listener ui.tools.workspace
alien.data alien sequences math classes.struct ;
SPECIALIZED-ARRAY: WCHAR
IN: windows.dragdrop-listener

: filenames-from-hdrop ( hdrop -- filenames )
    dup HEX: FFFFFFFF f 0 DragQueryFile ! get count of files
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
    DROPEFFECT_NONE listener-dragdrop construct-boa ;

SYMBOL: +listener-dragdrop-wrapper+
{
    { "IDropTarget" {
        [ ! DragEnter
            [
                2drop
                filenames-from-data-object
                length 1 = [ DROPEFFECT_COPY ] [ DROPEFFECT_NONE ] if
                dup 0
            ] dip set-ulong-nth
            >>last-drop-effect drop
            S_OK
        ] [ ! DragOver
            [ 2drop last-drop-effect>> 0 ] dip set-ulong-nth
            S_OK
        ] [ ! DragLeave
            drop S_OK
        ] [ ! Drop
            [
                2drop nip
                filenames-from-data-object
                dup length 1 = [
                    first unparse [ "USE: parser " % % " run-file" % ] "" make
                    eval-listener
                    DROPEFFECT_COPY
                ] [ 2drop DROPEFFECT_NONE ] if
                0
            ] dip set-ulong-nth
            S_OK
        ]
    } }
} <com-wrapper> +listener-dragdrop-wrapper+ set-global

: dragdrop-listener-window ( -- )
    get-workspace parent>> handle>> hWnd>>
    dup <listener-dragdrop>
    +listener-dragdrop-wrapper+ get-global com-wrap
    [ RegisterDragDrop ole32-error ] with-com-interface ;
