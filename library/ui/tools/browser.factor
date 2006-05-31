! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: gadgets gadgets-buttons gadgets-labels gadgets-panes
gadgets-presentations gadgets-scrolling gadgets-tabs
gadgets-tiles gadgets-theme gadgets-tracks generic hashtables
help inspector kernel math prettyprint sequences words ;

TUPLE: browser-track showing builder closer ;

C: browser-track ( builder closer -- gadget )
    { 0 1 0 } <track> over set-delegate
    H{ } clone over set-browser-track-showing
    [ set-browser-track-closer ] keep
    [ set-browser-track-builder ] keep ;

: showing-asset? ( asset track -- ? )
    browser-track-showing hash-member? ;

: (show-asset) ( gadget asset track -- )
    [ browser-track-showing set-hash ] 3keep nip track-add ;

: show-asset ( asset track -- )
    2dup showing-asset? [
        2drop
    ] [
        [ browser-track-builder call ] 2keep (show-asset)
    ] if ;

: hide-asset ( asset track -- )
    [ dup browser-track-closer call ] 2keep
    [ browser-track-showing remove-hash* ] keep track-remove ;

TUPLE: browser vocab-track word-track ;

: find-browser [ browser? ] find-parent ;

: close-tile ( tile -- )
    dup gadget-parent [
        browser-track-showing hash>alist rassoc
    ] keep hide-asset ;

: <browser-tile> ( gadget title -- gadget )
    [ close-tile ] <tile> ;

: showing-word? ( word browser -- ? )
    browser-word-track showing-asset? ;

DEFER: show-vocab

: <word-pages> ( word -- tabs )
    {
        { "Definition" [ see ] }
        { "Documentation" [ word-help (help) ] }
        { "Calls in" [ usage. ] }
        { "Calls out" [ uses. ] }
        { "Links in" [ links-in. ] }
        { "Links out" [ links-out. ] }
        { "Properties" [ word-props describe ] }
    } <pages> ;

: <word-view> ( word -- gadget )
    [ <word-pages> ] keep word-name <browser-tile> ;

: show-word ( word browser -- )
    over word-vocabulary over show-vocab
    browser-word-track show-asset ;

: hide-word ( word browser -- )
    browser-word-track hide-asset ;

: toggle-word ( word browser -- )
    2dup showing-word? [ hide-word ] [ show-word ] if ;

: <word-button> ( word -- gadget )
    dup word-name <label> swap
    [ swap find-browser toggle-word ] curry
    <roll-button> ;

: <vocab-view> ( vocab -- gadget )
    [
        words natural-sort
        [ <word-button> ] map make-pile <scroller>
    ] keep <browser-tile> ;

: showing-vocab? ( vocab browser -- ? )
    browser-vocab-track showing-asset? ;

: show-vocab ( vocab browser -- )
    over [ browser-vocab-track show-asset ] [ 2drop ] if ;

: hide-vocab-words ( vocab browser -- )
    [
        browser-word-track browser-track-showing hash-keys
        [ word-vocabulary = ] subset-with
    ] keep swap [ swap hide-word ] each-with ;

: hide-vocab ( vocab browser -- )
    browser-vocab-track hide-asset ;

: toggle-vocab ( word browser -- )
    2dup showing-vocab? [ hide-vocab ] [ show-vocab ] if ;

: <vocab-button> ( vocab -- gadget )
    dup <label> swap
    [ swap find-browser toggle-vocab ] curry
    <roll-button> ;

: <vocabs> ( -- gadget )
    vocabs [ <vocab-button> ] map make-pile <scroller>
    "Vocabularies" f <tile> ;

: <vocab-track> ( -- track )
    [ <vocab-view> ] [ find-browser hide-vocab-words ]
    <browser-track> ;

: <word-track> ( -- track )
    [ <word-view> ] [ 2drop ] <browser-track> ;

C: browser ( -- browser )
    {
        { [ <vocabs> ] f 1/5 }
        { [ <vocab-track> ] set-browser-vocab-track 1/5 }
        { [ <word-track> ] set-browser-word-track 3/5 }
    } { 1 0 0 } make-track* ;

M: browser gadget-title drop "Browser" ;

: browser-window ( -- ) <browser> open-window ;

: browser-tool
    [ browser? ]
    [ <browser> ]
    [ show-word ] ;

M: word show-object ( word button -- )
    browser-tool call-tool ;
