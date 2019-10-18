! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-panes
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-scrolling gadgets-paragraphs
gadgets-theme gadgets-presentations gadgets-slots generic
assocs io kernel namespaces sequences styles strings
quotations ;

: do-pane-stream ( pane-stream quot -- )
    >r pane-stream-pane r> keep scroll-pane ; inline

M: pane-stream stream-nl
    [ pane-nl ] do-pane-stream ;

M: pane-stream stream-write1
    [ pane-current stream-write1 ] do-pane-stream ;

M: pane-stream stream-write
    [ swap string-lines pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ rot string-lines pane-format ] do-pane-stream ;

M: pane-stream stream-close drop ;

M: pane-stream stream-flush drop ;

M: pane-stream with-stream-style (with-stream-style) ;

! Character styles

: apply-style ( style gadget key quot -- style gadget )
    >r pick at r> when* ; inline

: apply-foreground-style ( style gadget -- style gadget )
    foreground [ over set-label-color ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ dupd solid-interior ] apply-style ;

: specified-font ( style -- font )
    [ font swap at [ "monospace" ] unless* ] keep
    [ font-style swap at [ plain ] unless* ] keep
    font-size swap at [ 12 ] unless* 3array ;

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

: apply-border-color-style ( style gadget -- style gadget )
    border-color [ dupd solid-boundary ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [ dupd solid-interior ] apply-style ;

: apply-path-style ( style gadget -- style gadget )
    presented-path [ <editable-slot> ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ <border> ] apply-style ;

: apply-printer-style ( style gadget -- style gadget )
    presented-printer [
        over set-editable-slot-printer
    ] apply-style ;

: style-pane ( style pane -- pane )
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    apply-path-style
    apply-printer-style
    nip ;

: smash-pane ( pane -- gadget ) pane-output smash-line ;

: make-pane ( quot style -- gadget )
    #! Create a pane, call the quotation to fill it out.
    <pane> [
        apply-wrap-style nip swap with-pane
    ] 2keep smash-pane style-pane ; inline

: apply-table-gap-style ( style grid -- style grid )
    table-gap [ over set-grid-gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> over set-gadget-boundary ]
    apply-style ;

: styled-grid ( style grid -- grid )
    <grid>
    f over set-grid-fill?
    apply-table-gap-style
    apply-table-border-style
    nip ;

M: pane-stream stream-write-table
    >r swap styled-grid r> print-gadget ;

M: pane-stream make-table-cell
    drop make-pane ;

M: pane-stream with-nested-stream
    >r make-pane r> write-gadget ;

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
    [ H{ } over gadget-bl ] [ over gadget-write ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    >r 1string r> stream-write ;

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
    presented pick at [
        gadget-format
    ] [
        rot " " split
        [ 2dup gadget-bl ]
        [ pick pick gadget-format ] interleave
        2drop
    ] if ;
