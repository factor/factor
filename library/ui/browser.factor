! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: gadgets gadgets-buttons gadgets-inspector gadgets-labels
gadgets-layouts gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-tracks generic
hashtables help inspector kernel math prettyprint sequences
words ;

TUPLE: browser-track showing builder closer ;

C: browser-track ( builder closer -- gadget )
    <x-track> over set-delegate
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

TUPLE: browser vocabs vocab-track word-track ;

: find-browser [ browser? ] find-parent ;

TUPLE: tile ;

: find-tile [ tile? ] find-parent ;

: close-tile ( tile -- )
    dup gadget-parent [
        browser-track-showing hash>alist rassoc
    ] keep hide-asset ;

: <close-button> ( -- gadget )
    { 0.0 0.0 0.0 1.0 } close-box <polygon-gadget>
    [ find-tile close-tile ] <bevel-button> ;

: <closable-title> ( title -- gadget )
    {
        { [ <label> ] f @center }
        { [ <close-button> ] f @right }
    } make-frame ;

: <title> ( title closable? -- gadget )
    [ <closable-title> ] [ <label> ] if dup highlight-theme ;

C: tile ( gadget title closable? -- gadget )
    {
        { [ <title> ] f @top }
        { [ ] f @center }
    } make-frame* ;

: showing-word? ( word browser -- ? )
    browser-word-track showing-asset? ;

DEFER: show-vocab

: <word-view> ( word -- gadget )
    [ f <inspector> ] keep word-name t <tile> ;

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
    ] keep t <tile> ;

: showing-vocab? ( vocab browser -- ? )
    browser-vocab-track showing-asset? ;

: show-vocab ( vocab browser -- )
    browser-vocab-track show-asset ;

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

: add-vocabs ( vocabs browser -- )
    [ set-browser-vocabs ] 2keep track-add ;

: add-vocab-track ( track browser -- )
    [ set-browser-vocab-track ] 2keep track-add ;

: add-word-track ( track browser -- )
    [ set-browser-word-track ] 2keep track-add ;

: <vocab-track> ( -- track )
    [ <vocab-view> ] [ find-browser hide-vocab-words ]
    <browser-track> ;

: <word-track> ( -- track )
    [ <word-view> ] [ 2drop ] <browser-track> ;

C: browser ( -- browser )
    <y-track> over set-delegate
    <vocabs> over add-vocabs
    <vocab-track> over add-vocab-track
    <word-track> over add-word-track
    { 1/4 1/4 1/2 } over set-track-sizes ;

: browser-window ( word -- )
    <browser> [ "Browser" open-window ] keep
    over [ show-word ] [ 2drop ] if ;

M: word show-object ( word button -- )
    find-browser [ show-word ] [ browser-window ] if* ;
