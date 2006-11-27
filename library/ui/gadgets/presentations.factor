! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
DEFER: call-listener

IN: gadgets-presentations
USING: arrays definitions gadgets gadgets-borders
gadgets-buttons gadgets-labels gadgets-outliner
gadgets-panes gadgets-paragraphs gadgets-theme
generic hashtables tools io kernel prettyprint sequences strings
styles words help math models namespaces ;

! Clickable objects
TUPLE: presentation object hook ;

: invoke-presentation ( presentation command -- )
    over dup presentation-hook call
    >r presentation-object r> invoke-command ;

: invoke-primary ( presentation -- )
    dup presentation-object primary-operation
    invoke-presentation ;

: invoke-secondary ( presentation -- )
    dup presentation-object secondary-operation
    invoke-presentation ;

: show-mouse-help ( presentation -- )
    dup find-world [ world-status set-model ] [ drop ] if* ;

: hide-mouse-help ( presentation -- )
    find-world [ world-status f swap set-model ] when* ;

M: presentation ungraft* ( presentation -- )
    dup hide-mouse-help delegate ungraft* ;

C: presentation ( gadget object -- button )
    [ drop ] over set-presentation-hook
    [ set-presentation-object ] keep
    swap [ invoke-primary ] <roll-button>
    over set-gadget-delegate ;

: (command-button) ( target command -- label quot )
    dup command-name -rot
    [ invoke-command drop ] curry curry ;

: <command-button> ( target command -- button )
    (command-button) <bevel-button> ;

: <menu-command> ( command -- command )
    [ hand-clicked get find-world hide-glass ]
    swap modify-command ;

: <menu-item> ( target command -- button )
    <menu-command> (command-button) <roll-button> ;

: <commands-menu> ( target commands -- gadget )
    [ <menu-item> ] map-with
    make-pile 1 over set-pack-fill
    <default-border>
    dup menu-theme ;

: hooked-operations ( hook obj -- seq )
    object-operations swap modify-commands ;

: operations-menu ( presentation -- )
    dup dup presentation-hook curry
    over presentation-object hooked-operations
    over presentation-object swap <commands-menu>
    swap show-menu ;

presentation H{
    { T{ button-down f f 3 } [ operations-menu ] }
    { T{ mouse-leave } [ dup hide-mouse-help button-update ] }
    { T{ motion } [ dup show-mouse-help button-update ] }
} set-gestures

! Presentation help bar
: <presentation-help> ( model -- gadget )
    [
        [ presentation-object summary ] [ "" ] if*
    ] <filter> <label-control> dup reverse-video-theme ;

: <listener-button> ( gadget quot -- button )
    [ call-listener drop ] curry <roll-button> ;

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
    presented [ <presentation> ] apply-style ;

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
