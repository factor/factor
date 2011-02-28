! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences ui.backend.gtk.input-methods
ui.gadgets.editors ;
IN: ui.backend.gtk.input-methods.editors

M: editor support-input-methods? drop t ;

M: editor cursor-surrounding
    dup editor-caret first2 [ swap editor-line ] dip ;

M: editor delete-cursor-surrounding
    3drop ;

M: editor cursor-loc&dim
    [ caret-loc ] [ caret-dim ] bi ;
