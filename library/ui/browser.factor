! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: gadgets gadgets-buttons gadgets-inspector gadgets-labels
gadgets-layouts gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-tracks generic
hashtables help inspector kernel math prettyprint sequences
words ;

TUPLE: browser
    vocabs
    vocab-track showing-vocabs
    word-track showing-words ;

: find-browser [ browser? ] find-parent ;

: <title-border> ( gadget title -- gadget )
    {
        { [ <label> dup highlight-theme ] f @top }
        { [ ] f @center }
    } make-frame ;

: showing-word? ( word browser -- ? )
    browser-showing-words hash-member? ;

: (show-word) ( gadget word browser -- )
    [ browser-showing-words set-hash ] 3keep nip
    browser-word-track track-add ;

DEFER: show-vocab

: show-word ( word browser -- )
    2dup showing-word? [
        2drop
    ] [
        over word-vocabulary over show-vocab
        >r [ f <inspector> ] keep r> (show-word)
    ] if ;

: hide-word ( word browser -- )
    [ browser-showing-words remove-hash* ] keep
    browser-word-track track-remove ;

: toggle-word ( word browser -- )
    2dup showing-word? [ hide-word ] [ show-word ] if ;

: <word-button> ( word -- gadget )
    dup word-name <label> swap
    [ swap find-browser toggle-word ] curry
    <roll-button> ;

: <vocab> ( vocab -- gadget )
    [
        words natural-sort
        [ <word-button> ] map make-pile <scroller>
    ] keep <title-border> ;

: showing-vocab? ( vocab browser -- ? )
    browser-showing-vocabs hash-member? ;

: (show-vocab) ( gadget vocab browser -- )
    [ browser-showing-vocabs set-hash ] 3keep nip
    browser-vocab-track track-add ;

: show-vocab ( vocab browser -- )
    2dup showing-vocab?
    [ 2drop ] [ >r [ <vocab> ] keep r> (show-vocab) ] if ;

: hide-vocab-words ( vocab browser -- )
    [
        browser-showing-words hash-keys
        [ word-vocabulary = ] subset-with
    ] keep swap [ swap hide-word ] each-with ;

: hide-vocab ( vocab browser -- )
    2dup hide-vocab-words
    [ browser-showing-vocabs remove-hash* ] keep
    browser-vocab-track track-remove ;

: toggle-vocab ( word browser -- )
    2dup showing-vocab? [ hide-vocab ] [ show-vocab ] if ;

: <vocab-button> ( vocab -- gadget )
    dup <label> swap
    [ swap find-browser toggle-vocab ] curry
    <roll-button> ;

: <vocabs> ( -- gadget )
    vocabs [ <vocab-button> ] map make-pile <scroller>
    "Vocabularies" <title-border> ;

: add-vocabs ( vocabs browser -- )
    [ set-browser-vocabs ] 2keep track-add ;

: add-vocab-track ( track browser -- )
    [ set-browser-vocab-track ] 2keep track-add ;

: add-word-track ( track browser -- )
    [ set-browser-word-track ] 2keep track-add ;

C: browser ( -- browser )
    H{ } clone over set-browser-showing-vocabs
    H{ } clone over set-browser-showing-words
    <y-track> over set-delegate
    <vocabs> over add-vocabs
    <x-track> over add-vocab-track
    <x-track> over add-word-track
    { 1/4 1/4 1/2 } over set-track-sizes ;

: browser-window ( word -- )
    <browser> [ "Browser" open-window ] keep show-word ;

M: word show-object ( word button -- )
    find-browser [ show-word ] [ browser-window ] if* ;
