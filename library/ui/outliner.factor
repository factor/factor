! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-outliner
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-layouts gadgets-panes gadgets-theme
generic io kernel lists sequences styles ;

! Outliner gadget.
TUPLE: outliner quot ;

: outliner-expanded? ( outliner -- ? )
    #! If the outliner is expanded, it has a center gadget.
    @center frame-child >boolean ;

DEFER: <expand-button>

: set-outliner-expanded? ( expanded? outliner -- )
    #! Call the expander quotation if expanding.
    over not <expand-button> over @top-left frame-add
    swap [ dup outliner-quot make-pane ] [ f ] if
    swap @center frame-add ;

: find-outliner ( gadget -- outliner )
    [ outliner? ] find-parent ;

: <expand-arrow> ( ? -- gadget )
    arrow-right arrow-down ? gray swap
    <polygon-gadget> <default-border> ;

: <expand-button> ( ? -- gadget )
    #! If true, the button expands, otherwise it collapses.
    dup [ swap find-outliner set-outliner-expanded? ] curry
    >r <expand-arrow> r>
    <highlight-button> ;

C: outliner ( gadget quot -- gadget )
    #! The quotation generates child gadgets.
    dup delegate>frame
    [ set-outliner-quot ] keep
    [ >r 1array make-shelf r> @top frame-add ] keep
    f over set-outliner-expanded? ;
