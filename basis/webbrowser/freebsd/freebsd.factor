! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays io.launcher kernel present system webbrowser ;

IN: webbrowser.freebsd

M: freebsd open-item
    present "open" swap 2array run-detached drop ;
