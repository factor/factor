! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-panes
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-scrolling gadgets-paragraphs
gadgets-theme gadgets-presentations gadgets-outliners
generic hashtables io kernel namespaces sequences styles
strings ;

TUPLE: pane output current prototype scrolls? ;

: add-output 2dup set-pane-output add-gadget ;

: add-current 2dup set-pane-current add-gadget ;

: prepare-line ( pane -- )
    dup pane-prototype clone swap add-current ;

: pane-clear ( pane -- )
    dup
    pane-output clear-incremental
    pane-current clear-gadget ;

C: pane ( -- pane )
    <pile> over set-delegate
    <shelf> over set-pane-prototype
    <pile> <incremental> over add-output
    dup prepare-line ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ scroll>bottom ] [ drop ] if ;

TUPLE: pane-stream pane ;

: prepare-print ( current -- gadget )
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        { [ t ] [ drop ] }
    } cond ;

: pane-terpri ( pane -- )
    dup pane-current dup unparent prepare-print
    over pane-output add-incremental
    prepare-line ;

: pane-write ( pane seq -- )
    [ over pane-current stream-write ]
    [ dup pane-terpri ] interleave drop ;

: pane-format ( style pane seq -- )
    [ pick pick pane-current stream-format ]
    [ dup pane-terpri ] interleave 2drop ;

: do-pane-stream ( pane-stream quot -- )
    >r pane-stream-pane r> over slip scroll-pane ; inline

M: pane-stream stream-terpri
    [ pane-terpri ] do-pane-stream ;

M: pane-stream stream-write1
    [ pane-current stream-write1 ] do-pane-stream ;

M: pane-stream stream-write
    [ swap string-lines pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ rot string-lines pane-format ] do-pane-stream ;

M: pane-stream stream-close drop ;

M: pane-stream stream-flush drop ;

M: pane-stream with-stream-style (with-stream-style) ;

GENERIC: write-gadget ( gadget stream -- )

M: pane-stream write-gadget
    pane-stream-pane pane-current add-gadget ;

M: duplex-stream write-gadget
    duplex-stream-out write-gadget ;

: print-gadget ( gadget pane -- )
    tuck write-gadget stream-terpri ;

: gadget. ( gadget -- )
    stdio get print-gadget ;

: ?terpri ( stream -- )
    dup pane-stream-pane pane-current gadget-children empty?
    [ dup stream-terpri ] unless drop ;

: with-pane ( pane quot -- )
    over scroll>top
    over pane-clear >r <pane-stream> r>
    over >r with-stream r> ?terpri ; inline

: make-pane ( quot -- pane )
    <pane> [ swap with-pane ] keep ; inline

: <scrolling-pane> ( -- pane )
    <pane> t over set-pane-scrolls? ;

: <pane-control> ( model quot -- pane )
    [ with-pane ] curry <pane> swap <control> ;

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

: <styled-label> ( style text -- gadget )
    <label>
    apply-foreground-style
    apply-background-style
    apply-font-style
    apply-presentation-style
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
    outline [ [ make-pane ] curry <outliner> ] apply-style ;

: <styled-paragraph> ( style pane -- gadget )
    apply-wrap-style
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
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
