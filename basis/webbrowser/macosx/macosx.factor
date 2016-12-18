! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays io.launcher kernel present system webbrowser ;

IN: webbrowser.macosx

M: macosx open-item ( item -- )
    present "open" swap 2array run-detached drop ;
