! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces
ui.gadgets ui.gadgets.worlds ui.gestures
windows.dropfiles windows.user32 ;
IN: ui.windows.drop-target

TUPLE: drop-target < world
    on-file-drop ; ! ( seq -- )

TUPLE: world-attributes < ui.gadgets.worlds:world-attributes
    { on-file-drop initial: [ drop ] } ;

: make-topmost ( world topmost? -- )
    [ handle>> hWnd>> ] [ HWND_TOPMOST HWND_NOTOPMOST ? ] bi* 0 0 0 0
    SWP_NOSIZE SWP_NOMOVE bitor SWP_NOACTIVATE bitor SetWindowPos drop ;

M: drop-target graft*
    [ call-next-method ] [ world-accept-files ] [ t make-topmost ] tri ;

: handle-drop ( drop-target -- )
    on-file-drop>> [ dropped-files get-global swap call( files -- ) ] when* ;

drop-target H{
    { T{ file-drop } [ handle-drop ] }
} set-gestures

: <drop-target> ( world-attributes -- world )
    clone drop-target >>world-class [ <world> ] keep on-file-drop>>
    >>on-file-drop ;
