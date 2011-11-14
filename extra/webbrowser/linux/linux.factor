! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io.launcher kernel sequences system webbrowser ;

IN: webbrowser.linux

M: linux open-file ( path -- )
    { "gnome-open" } swap suffix try-process ;
