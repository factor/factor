! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: system kernel webbrowser windows.shell32 windows.user32 ;

IN: webbrowser.windows

M: windows open-file ( path -- )
    [ f "open" ] dip f f SW_SHOWNORMAL ShellExecute drop ;
