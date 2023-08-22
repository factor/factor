! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: kernel present system webbrowser windows.shell32 windows.user32 ;
IN: webbrowser.windows

M: windows open-item
    [ f "open" ] dip present f f
    SW_SHOWNORMAL ShellExecute drop ;
