! Copyright (C) 2010 Slava Pestov.
USING: accessors arrays colors euler.b-rep gml gml.printer
gml.runtime gml.viewer io.directories io.encodings.utf8 io.files
io.pathnames io.streams.string kernel models namespaces
sequences ui ui.gadgets ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.packs ui.gadgets.scrollers
ui.gadgets.tables unicode ;
FROM: gml => gml ;
IN: gml.ui

SINGLETON: stack-entry-renderer

M: stack-entry-renderer row-columns
    drop [ write-gml ] with-string-writer 1array ;

M: stack-entry-renderer row-value
    drop ;

: <stack-table> ( model -- table )
    stack-entry-renderer <table>
        10 >>min-rows
        10 >>max-rows
        40 >>min-cols
        40 >>max-cols ;

: <stack-display> ( model -- gadget )
    <stack-table> <scroller> "Operand stack"
    COLOR: dark-gray <colored-labeled-gadget> ;

TUPLE: gml-editor < frame editor gml stack-model b-rep b-rep-model ;

: update-models ( gml-editor -- )
    [ [ b-rep>> dup finish-b-rep ] [ b-rep-model>> ] bi set-model ]
    [ [ gml>> operand-stack>> ] [ stack-model>> ] bi set-model ]
    bi ;

: with-gml-editor ( gml-editor quot -- )
    '[
        [ [ gml>> gml set ] [ b-rep>> b-rep set ] bi @ ]
        [ update-models ]
        bi
    ] with-scope ; inline

: find-gml-editor ( gadget -- gml-editor )
    [ gml-editor? ] find-parent ;

: load-input ( file gml-editor -- )
    [ utf8 file-contents ] dip editor>> set-editor-string ;

: update-viewer ( gml-editor -- )
    dup [ editor>> editor-string run-gml-string ] with-gml-editor ;

: new-viewer ( gml-editor -- )
    [ update-viewer ]
    [ [ b-rep-model>> ] [ stack-model>> ] bi gml-viewer ]
    bi ;

: reset-viewer ( gml-editor -- )
    [
        b-rep get clear-b-rep
        gml get operand-stack>> delete-all
    ] with-gml-editor ;

: <new-button> ( -- button )
    "New viewer" [ find-gml-editor new-viewer ] <border-button> ;

: <update-button> ( -- button )
    "Update viewer" [ find-gml-editor update-viewer ] <border-button> ;

: <reset-button> ( -- button )
    "Reset viewer" [ find-gml-editor reset-viewer ] <border-button> ;

: <control-buttons> ( -- gadget )
    <shelf> { 5 5 } >>gap
    <new-button> add-gadget
    <update-button> add-gadget
    <reset-button> add-gadget ;

CONSTANT: example-dir "vocab:gml/examples/"

: gml-files ( -- seq )
    example-dir directory-files
    [ file-extension >lower "gml" = ] filter ;

: <example-button> ( file -- button )
    dup '[ example-dir _ append-path swap find-gml-editor load-input ]
    <border-button> ;

: <example-buttons> ( -- gadget )
    gml-files
    <pile> { 5 5 } >>gap
    "Examples:" <label> add-gadget
    [ <example-button> add-gadget ] reduce ;

: <editor-panel> ( editor -- gadget )
        30 >>min-rows
        30 >>max-rows
        40 >>min-cols
        40 >>max-cols
    <scroller> "Editor" COLOR: dark-gray <colored-labeled-gadget> ;

: <gml-editor> ( -- gadget )
    2 3 gml-editor new-frame
        <gml> >>gml
        <b-rep> >>b-rep
        dup b-rep>> <model> >>b-rep-model
        dup gml>> operand-stack>> <model> >>stack-model
        { 20 20 } >>gap
        { 0 0 } >>filled-cell
        <source-editor> >>editor
        dup editor>> <editor-panel> { 0 0 } grid-add
        dup stack-model>> <stack-display> { 0 1 } grid-add
        <control-buttons> { 0 2 } grid-add
        <example-buttons> { 1 0 } grid-add ;

M: gml-editor focusable-child* editor>> ;

: gml-editor-window ( -- )
    <gml-editor> "Generative Modeling Language" open-window ;

MAIN: gml-editor-window
