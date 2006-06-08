! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-outliner
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-panes gadgets-theme generic io kernel
math opengl sequences styles ;

! Vertical line.
TUPLE: guide color ;

M: guide draw-interior ( gadget interior -- )
    guide-color gl-color
    rect-dim dup { 0.5 0 0 } v* swap { 0.5 1 0 } v* gl-line ;

: <guide-gadget> ( -- gadget )
    <gadget>
    T{ guide f { 0.5 0.5 0.5 1.0 } } over set-gadget-interior ;

! Outliner gadget.
TUPLE: outliner quot ;

: outliner-expanded? ( outliner -- ? )
    #! If the outliner is expanded, it has a center gadget.
    @center grid-child >boolean ;

: find-outliner ( gadget -- outliner )
    [ outliner? ] find-parent ;

: <expand-arrow> ( ? -- gadget )
    arrow-right arrow-down ? { 0.5 0.5 0.5 1.0 } swap
    <polygon-gadget> <default-border> ;

DEFER: set-outliner-expanded?

: <expand-button> ( ? -- gadget )
    #! If true, the button expands, otherwise it collapses.
    dup [ swap find-outliner set-outliner-expanded? ] curry
    >r <expand-arrow> r> <highlight-button> ;

: setup-expand ( expanded? outliner -- )
    >r not <expand-button> r> @top-left grid-add ;

: setup-center ( expanded? outliner -- )
    [ swap [ outliner-quot make-pane ] [ drop f ] if ] keep
    @center grid-add ;

: setup-guide ( expanded? outliner -- )
    >r [ <guide-gadget> ] [ f ] if r> @left grid-add ;

: set-outliner-expanded? ( expanded? outliner -- )
    #! Call the expander quotation if expanding.
    2dup setup-expand 2dup setup-center setup-guide ;

C: outliner ( gadget quot -- gadget )
    #! The quotation generates child gadgets.
    dup delegate>frame
    [ set-outliner-quot ] keep
    [ >r 1array make-shelf r> @top grid-add ] keep
    f over set-outliner-expanded? ;
