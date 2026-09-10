! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays documents kernel locals math sequences
ui.backend.gtk4.input-methods
ui.gadgets.editors ;
IN: ui.backend.gtk4.input-methods.editors

M: editor support-input-methods? drop t ;

M: editor cursor-surrounding
    dup editor-caret first2 [ swap editor-line ] dip ;

M:: editor delete-cursor-surrounding ( offset count editor -- )
    editor editor-caret first2 :> ( row col )
    editor model>> :> document
    row col offset + 2array document validate-loc
    row col offset + count + 2array document validate-loc
    document remove-doc-range ;

M: editor cursor-loc&dim
    [ caret-loc ] [ caret-dim ] bi ;
