! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-outliner
USING: arrays gadgets gadgets-buttons gadgets-labels
gadgets-layouts gadgets-panes generic io
kernel sequences ;

! Outliner widget.

TUPLE: outliner gadget quot pile expanded? ;

: add-outliner-node ( outliner -- )
    dup outliner-gadget
    swap outliner-pile add-gadget ;

: setup-outliner ( quot outliner -- )
    dup outliner-gadget >r
    outliner-pile dup clear-gadget
    r> over add-gadget
    over [ >r make-pane r> add-gadget ] [ 2drop ] if ;

: collapse-outliner ( outliner -- )
    f over set-outliner-expanded? f swap setup-outliner ;

: expand-outliner ( outliner -- )
    t over set-outliner-expanded?
    dup outliner-quot swap setup-outliner ;

: toggle-outliner ( outliner -- )
    dup outliner-expanded?
    [ collapse-outliner ] [ expand-outliner ] if ;

: find-outliner [ outliner? ] find-parent ;

: <expand-button> ( -- gadget )
    right <polygon-gadget>
    [ find-outliner toggle-outliner ] <highlight-button> ;

C: outliner ( gadget quot -- gadget )
    #! The quotation generates child gadgets.
    [ set-outliner-quot ] keep
    [ set-outliner-gadget ] keep
    <shelf> over set-delegate
    @{ 5 0 0 }@ over set-pack-gap
    <expand-button> over add-gadget
    <pile> over 2dup set-outliner-pile add-gadget
    dup collapse-outliner ;
