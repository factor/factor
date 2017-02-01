! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals ui.gadgets ui.gadgets.charts
ui.render ;
IN: ui.gadgets.charts.axes

TUPLE: axis < gadget vertical? ;

M: axis draw-gadget*
    dup parent>> dup chart? [| axis chart |
    ] [ 2drop ] if ;
