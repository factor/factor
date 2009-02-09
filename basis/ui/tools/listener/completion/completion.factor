! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors colors.constants documents
documents.elements fry kernel words sets splitting math math.vectors
models.delay models.filter combinators.short-circuit parser present
sequences tools.completion tools.vocabs.browser generic
generic.standard.engines.tuple fonts ui.commands ui.operations
ui.gadgets ui.gadgets.editors ui.gadgets.glass ui.gadgets.scrollers
ui.gadgets.tables ui.gadgets.tracks ui.gadgets.labelled
ui.gadgets.theme ui.gadgets.worlds ui.gadgets.wrappers ui.gestures
ui.render ui.tools.listener.history combinators vocabs
ui.tools.listener.popups ;
IN: ui.tools.listener.completion

! We don't directly depend on the listener tool but we use a few slots
SLOT: interactor
SLOT: history

: history-list ( interactor -- alist )
    history>> elements>>
    [ dup string>> { { CHAR: \n CHAR: \s } } substitute ] { } map>assoc
    <reversed> ;

TUPLE: word-completion vocabs ;
C: <word-completion> word-completion

SINGLETONS: vocab-completion char-completion history-completion ;

UNION: listener-completion word-completion vocab-completion char-completion history-completion ;

GENERIC: completion-quot ( interactor completion-mode -- quot )

M: word-completion completion-quot 2drop [ [ { } ] [ words-matching ] if-empty ] ;
M: vocab-completion completion-quot 2drop [ [ { } ] [ vocabs-matching ] if-empty ] ;
M: char-completion completion-quot 2drop [ [ { } ] [ chars-matching ] if-empty ] ;
M: history-completion completion-quot drop '[ drop _ history-list ] ;

GENERIC: completion-element ( completion-mode -- element )

M: object completion-element drop one-word-elt ;
M: history-completion completion-element drop one-line-elt ;

GENERIC: completion-banner ( completion-mode -- string )

M: word-completion completion-banner drop "Words:" ;
M: vocab-completion completion-banner drop "Vocabularies:" ;
M: char-completion completion-banner drop "Unicode code point names:" ;
M: history-completion completion-banner drop "Input history:" ;

GENERIC: completion-popup-width ( interactor completion-mode -- x )

M: object completion-popup-width 2drop 300 ;
M: history-completion completion-popup-width drop dim>> first ;

! Completion modes also implement the row renderer protocol
M: listener-completion row-columns drop present 1array ;

M: word-completion row-color
    [ vocabulary>> ] [ vocabs>> ] bi* {
        { [ 2dup [ vocab-words ] dip memq? ] [ COLOR: black ] }
        { [ over ".private" tail? ] [ COLOR: dark-red ] }
        [ COLOR: dark-gray ]
    } cond 2nip ;

M: vocab-completion row-color
    drop vocab? COLOR: black COLOR: dark-gray ? ;

: complete-IN:/USE:? ( tokens -- ? )
    2 short tail* { "IN:" "USE:" } intersects? ;

: chop-; ( seq -- seq' )
    { ";" } split1-last [ ] [ ] ?if ;

: complete-USING:? ( tokens -- ? )
    chop-; { "USING:" } intersects? ;

: complete-CHAR:? ( tokens -- ? )
    2 short tail* "CHAR:" swap member? ;

: up-to-caret ( caret document -- string )
    [ { 0 0 } ] 2dip doc-range ;

: completion-mode ( interactor -- symbol )
    [ vocabs>> ] [ editor-caret ] [ model>> ] tri up-to-caret " \r\n" split
    {
        { [ dup { [ complete-IN:/USE:? ] [ complete-USING:? ] } 1|| ] [ 2drop vocab-completion ] }
        { [ dup complete-CHAR:? ] [ 2drop char-completion ] }
        [ drop <word-completion> ]
    } cond ;

TUPLE: completion-popup < track interactor table completion-mode ;

: find-completion-popup ( gadget -- popup )
    [ completion-popup? ] find-parent ;

: <completion-model> ( editor element quot -- model )
    [ <element-model> 1/3 seconds <delay> ] dip
    '[ @ keys 1000 short head ] <filter> ;

M: completion-popup focusable-child* table>> ;

: completion-loc/doc/elt ( popup -- loc doc elt )
    [ interactor>> [ editor-caret ] [ model>> ] bi ]
    [ completion-mode>> completion-element ]
    bi ;

GENERIC: completion-string ( object -- string )

M: object completion-string present ;

: method-completion-string ( word -- string )
    "method-generic" word-prop present ;

M: method-body completion-string method-completion-string ;

M: engine-word completion-string method-completion-string ;

GENERIC# accept-completion-hook 1 ( item popup -- )

: insert-completion ( item popup -- )
    [ completion-string ] [ completion-loc/doc/elt ] bi* set-elt-string ;

: accept-completion ( item table -- )
    find-completion-popup
    [ insert-completion ]
    [ accept-completion-hook ]
    [ nip hide-popup ]
    2tri ;

: <completion-table> ( interactor completion-mode -- table )
    [ completion-element ] [ completion-quot ] [ nip ] 2tri
    [ <completion-model> <table> ] dip
        >>renderer
        monospace-font >>font
        t >>selection-required?
        dup '[ _ accept-completion ] >>action ;

: <completion-scroller> ( completion-popup -- scroller )
    [ table>> ] [ interactor>> ] [ completion-mode>> ] tri completion-popup-width
    [ <limited-scroller> ] [ 120 2array ] bi*
    [ >>min-dim ] [ >>max-dim ] bi ;

: <completion-popup> ( interactor completion-mode -- popup )
    [ vertical completion-popup new-track ] 2dip
    [ [ >>interactor ] [ >>completion-mode ] bi* ] [ <completion-table> >>table ] 2bi
    dup [ <completion-scroller> ] [ completion-mode>> completion-banner ] bi
    <labelled-gadget> 1 track-add
    COLOR: white <solid> >>interior ;

completion-popup H{
    { T{ key-down f f "TAB" } [ table>> row-action ] }
    { T{ key-down f f " " } [ table>> row-action ] }
} set-gestures

: show-completion-popup ( interactor mode -- )
    [ completion-element ] [ <completion-popup> ] 2bi
    show-popup ;

: code-completion-popup ( interactor -- )
    dup completion-mode show-completion-popup ;

: history-completion-popup ( interactor -- )
    history-completion show-completion-popup ;

: recall-previous ( interactor -- )
    history>> history-recall-previous ;

: recall-next ( interactor -- )
    history>> history-recall-next ;

: completion-gesture ( gesture completion -- value/f operation/f )
    table>> selected-row
    [ [ nip ] [ gesture>operation ] 2bi ] [ drop f ] if ;

M: completion-popup handle-gesture ( gesture completion -- ? )
    2dup completion-gesture dup [
        [ nip find-world hide-glass ] [ invoke-command ] 2bi* f
    ] [ 2drop call-next-method ] if ;