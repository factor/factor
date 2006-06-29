! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-frames gadgets-labels gadgets-panes
gadgets-presentations gadgets-scrolling gadgets-search
gadgets-books gadgets-theme gadgets-tiles gadgets-tracks generic
hashtables help inspector kernel math models namespaces
prettyprint sequences words ;

TUPLE: asset-track showing builder closer ;

C: asset-track ( builder closer -- gadget )
    { 0 1 } <track> over set-delegate
    H{ } clone over set-asset-track-showing
    [ set-asset-track-closer ] keep
    [ set-asset-track-builder ] keep ;

: showing-asset? ( asset track -- ? )
    asset-track-showing hash-member? ;

: (show-asset) ( gadget asset track -- )
    [ asset-track-showing set-hash ] 3keep nip track-add ;

: show-asset ( asset track -- )
    2dup showing-asset? [
        2drop
    ] [
        [ asset-track-builder call ] 2keep (show-asset)
    ] if ;

: hide-asset ( asset track -- )
    [ dup asset-track-closer call ] 2keep
    [ asset-track-showing remove-hash* ] keep track-remove ;

TUPLE: browser track page ;

TUPLE: browser-tracks vocabs words ;

: browser-vocab-track browser-track browser-tracks-vocabs ;

: browser-word-track browser-track browser-tracks-words ;

: find-browser [ browser? ] find-parent ;

: close-tile ( tile -- )
    dup gadget-parent [
        asset-track-showing hash>alist rassoc
    ] keep hide-asset ;

: <browser-tile> ( gadget title -- gadget )
    [ close-tile ] <tile> ;

: showing-word? ( word browser -- ? )
    browser-word-track showing-asset? ;

DEFER: show-vocab

: browser-tabs
    {
        { "Documentation" [ help ] }
        { "Definition"    [ see ] } 
        { "Calls in"      [ usage. ] }
        { "Properties"    [ word-props describe ] }
    } ;

: <word-book> ( model word -- book )
    browser-tabs [ second ] map make-book ;

: <word-view> ( word browser -- gadget )
    browser-page swap [ <word-book> ] keep
    word-name <browser-tile> ;

: show-word ( word browser -- )
    over word-vocabulary over show-vocab
    browser-word-track show-asset ;

: hide-word ( word browser -- )
    browser-word-track hide-asset ;

: toggle-word ( word browser -- )
    2dup showing-word? [ hide-word ] [ show-word ] if ;

: <word-button> ( word -- gadget )
    dup word-name swap
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
        browser-word-track asset-track-showing hash-keys
        [ word-vocabulary = ] subset-with
    ] keep swap [ swap hide-word ] each-with ;

: hide-vocab ( vocab browser -- )
    browser-vocab-track hide-asset ;

: toggle-vocab ( word browser -- )
    2dup showing-vocab? [ hide-vocab ] [ show-vocab ] if ;

: <vocab-button> ( vocab -- gadget )
    dup [ swap find-browser toggle-vocab ] curry
    <roll-button> ;

: <vocabs> ( -- gadget )
    vocabs [ <vocab-button> ] map make-pile <scroller>
    "Vocabularies" f <tile> ;

: <vocab-track> ( -- track )
    [ <vocab-view> ] [ find-browser hide-vocab-words ]
    <asset-track> ;

: <word-track> ( browser -- track )
    [ <word-view> ] curry [ 2drop ] <asset-track> ;

C: browser-tracks ( browser -- browser-track )
    {
        { [ <vocabs> ] f f 1/5 }
        { [ <vocab-track> ] set-browser-tracks-vocabs f 1/5 }
        { [ <word-track> ] set-browser-tracks-words f 3/5 }
    } { 1 0 } make-track* ;

: <browser-tabs> ( browser -- tabs )
    browser-page
    browser-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

: make-toolbar ( quot -- gadget )
    { } make make-shelf dup highlight-theme ; inline

: <browser-toolbar> ( browser -- toolbar )
    [
        <browser-tabs> ,
        <spacing> ,
        "Apropos" [ drop apropos-window ] <bevel-button> ,
    ] make-toolbar ;

C: browser ( -- browser )
    0 <model> over set-browser-page
    dup dup {
        { [ <browser-toolbar> ] f f @top }
        { [ <browser-tracks> ] set-browser-track f @center }
    } make-frame* ;

M: browser gadget-title drop "Browser" ;

: browser-window ( -- ) <browser> open-window ;

: browser-tool
    [ browser? ]
    [ <browser> ]
    [ show-word ] ;

M: word show ( word -- ) browser-tool call-tool ;
