! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
DEFER: call-listener

IN: gadgets-presentations
USING: arrays definitions gadgets gadgets-borders
gadgets-buttons gadgets-grids gadgets-labels gadgets-outliner
gadgets-panes gadgets-paragraphs gadgets-theme
generic hashtables tools io kernel prettyprint sequences strings
styles words help math models namespaces ;

! Clickable objects
TUPLE: presentation object command ;

C: presentation ( button object command -- button )
    [ set-presentation-command ] keep
    [ set-presentation-object ] keep
    [ set-gadget-delegate ] keep ;

: <object-presentation> ( gadget object -- button )
    >r f <roll-button> r> f <presentation> ;

: <command-presentation> ( target command -- button )
    dup command-name f <bevel-button> -rot <presentation> ;

: <commands-menu> ( target commands -- gadget )
    [ hand-clicked get find-world hide-glass ] modify-operations
    [ <command-presentation> ] map-with
    make-pile 1 over set-pack-fill ;

: operations-menu ( presentation -- gadget )
    dup presentation-object
    dup object-operations <commands-menu>
    swap show-menu ;

: invoke-presentation ( presentation -- )
    dup presentation-object swap presentation-command
    [ dup default-operation ] unless*
    invoke-command ;

: show-mouse-help ( presentation -- )
    dup find-world [ world-status set-model* ] [ drop ] if* ;

: hide-mouse-help ( presentation -- )
    find-world [ world-status f swap set-model* ] when* ;

M: presentation ungraft* ( presentation -- )
    dup hide-mouse-help delegate ungraft* ;

presentation H{
    { T{ button-up } [ [ invoke-presentation ] if-clicked ] }
    { T{ button-down f f 3 } [ [ operations-menu ] if-clicked ] }
    { T{ mouse-leave } [ global [ dup short. flush ] bind  dup hide-mouse-help button-update ] }
    { T{ mouse-enter } [ global [ dup short. flush ] bind  dup show-mouse-help button-update ] }
} set-gestures

! Presentation help bar
: <presentation-help> ( model -- gadget )
    [ [ presentation-object summary ] [ "" ] if* ] <filter>
    <label-control> dup reverse-video-theme ;

: <listener-button> ( gadget quot -- button )
    [ call-listener ] curry <roll-button> ;

! Character styles

: apply-style ( style gadget key quot -- style gadget )
    >r pick hash r> when* ; inline

: apply-foreground-style ( style gadget -- style gadget )
    foreground [ over set-label-color ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ <solid> over set-gadget-interior ] apply-style ;

: specified-font ( style -- font )
    [ font swap hash [ "monospace" ] unless* ] keep
    [ font-style swap hash [ plain ] unless* ] keep
    font-size swap hash [ 12 ] unless* 3array ;

: apply-font-style ( style gadget -- style gadget )
    over specified-font over set-label-font ;

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <object-presentation> ] apply-style ;

: apply-quotation-style ( style gadget -- style gadget )
    quotation [ <listener-button> ] apply-style ;

: <styled-label> ( style text -- gadget )
    <label>
    apply-foreground-style
    apply-background-style
    apply-font-style
    apply-presentation-style
    apply-quotation-style
    nip ;

! Paragraph styles

: apply-wrap-style ( style pane -- style pane )
    wrap-margin [
        2dup <paragraph> swap set-pane-prototype
        <paragraph> over set-pane-current
    ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ <border> ] apply-style ;

: apply-border-color-style ( style gadget -- style gadget )
    border-color [
        <solid> over set-gadget-boundary
    ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [
        <solid> over set-gadget-interior
    ] apply-style ;

: apply-outliner-style ( style gadget -- style gadget )
    outline [ <outliner> ] apply-style ;

: <styled-paragraph> ( style pane -- gadget )
    apply-wrap-style
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    apply-quotation-style
    apply-outliner-style
    nip ;

: styled-pane ( quot style -- gadget )
    #! Create a pane, call the quotation to fill it out.
    >r <pane> dup r> swap <styled-paragraph>
    >r swap with-pane r> ; inline

: apply-table-gap-style ( style grid -- style grid )
    table-gap [ over set-grid-gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> over set-gadget-boundary ]
    apply-style ;

: styled-grid ( style grid -- grid )
    <grid>
    apply-table-gap-style
    apply-table-border-style
    nip ;

: <pane-grid> ( quot style grid -- gadget )
    [
        [ pick pick >r >r -rot styled-pane r> r> rot ] map
    ] map styled-grid nip ;

M: pane-stream with-stream-table
    >r rot <pane-grid> r> print-gadget ;

M: pane-stream with-nested-stream
    >r styled-pane r> write-gadget ;

! Stream utilities
M: pack stream-close drop ;

M: paragraph stream-close drop ;

: gadget-write ( string gadget -- )
    over empty? [
        2drop
    ] [
        >r <label> dup text-theme r> add-gadget
    ] if ;

M: pack stream-write gadget-write ;

: gadget-bl ( style stream -- )
    >r " " <styled-label> <word-break-gadget> r> add-gadget ;

M: paragraph stream-write
    swap " " split
    [ over gadget-write ] [ H{ } over gadget-bl ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    >r ch>string r> stream-write ;

M: pack stream-write1 gadget-write1 ;

M: paragraph stream-write1
    over CHAR: \s =
    [ H{ } swap gadget-bl drop ] [ gadget-write1 ] if ;

: gadget-format ( string style stream -- )
    pick empty?
    [ 3drop ] [ >r swap <styled-label> r> add-gadget ] if ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    presented pick hash [
        gadget-format
    ] [
        rot " " split
        [ pick pick gadget-format ]
        [ 2dup gadget-bl ] interleave
        2drop
    ] if ;
