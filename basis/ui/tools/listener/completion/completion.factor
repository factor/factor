! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors colors.constants
documents documents.elements fry kernel words sets splitting math
math.vectors models.delay models.arrow combinators.short-circuit
parser present sequences tools.completion help.vocabs generic fonts
definitions.icons ui.images ui.commands ui.operations ui.gadgets
ui.gadgets.editors ui.gadgets.glass ui.gadgets.scrollers
ui.gadgets.tables ui.gadgets.tracks ui.gadgets.labeled
ui.gadgets.worlds ui.gadgets.wrappers ui.gestures ui.pens.solid
ui.tools.listener.history combinators vocabs ui.tools.listener.popups ;
IN: ui.tools.listener.completion

! We don't directly depend on the listener tool but we use a few slots
SLOT: interactor
SLOT: history

: history-list ( interactor -- alist )
    history>> elements>>
    [ dup string>> H{ { CHAR: \n CHAR: \s } } substitute ] { } map>assoc
    <reversed> ;

: history-completions ( short interactor -- seq )
    history-list over empty? [ nip ] [ members completions ] if ;

TUPLE: word-completion manifest ;
C: <word-completion> word-completion

SINGLETONS: vocab-completion color-completion char-completion history-completion ;
UNION: definition-completion word-completion vocab-completion ;
UNION: listener-completion definition-completion
color-completion char-completion history-completion ;

GENERIC: completion-quot ( interactor completion-mode -- quot )

: (completion-quot) ( interactor completion-mode quot -- quot' )
    2nip '[ [ { } ] _ if-empty ] ; inline

M: word-completion completion-quot [ words-matching ] (completion-quot) ;
M: vocab-completion completion-quot [ vocabs-matching ] (completion-quot) ;
M: color-completion completion-quot [ colors-matching ] (completion-quot) ;
M: char-completion completion-quot [ chars-matching ] (completion-quot) ;
M: history-completion completion-quot drop '[ _ history-completions ] ;

GENERIC: completion-element ( completion-mode -- element )

M: object completion-element drop word-start-elt ;
M: history-completion completion-element drop one-line-elt ;

GENERIC: completion-banner ( completion-mode -- string )

M: word-completion completion-banner drop "Words" ;
M: vocab-completion completion-banner drop "Vocabularies" ;
M: color-completion completion-banner drop "Colors" ;
M: char-completion completion-banner drop "Unicode code point names" ;
M: history-completion completion-banner drop "Input history" ;

! Completion modes also implement the row renderer protocol
M: listener-completion row-columns drop present 1array ;

M: definition-completion prototype-row
    drop \ + definition-icon <image-name> "" 2array ;

M: definition-completion row-columns
    drop
    [ definition-icon <image-name> ]
    [ present ] bi
    2array ;

M: word-completion row-color
    [ vocabulary>> ] [ manifest>> ] bi* {
        { [ dup not ] [ COLOR: black ] }
        { [ 2dup search-vocab-names>> keys member? ] [ COLOR: black ] }
        { [ over ".private" tail? ] [ COLOR: dark-red ] }
        [ COLOR: dark-gray ]
    } cond 2nip ;

M: vocab-completion row-color
    drop vocab? COLOR: black COLOR: dark-gray ? ;

M: color-completion row-color
    drop named-color ;

: up-to-caret ( caret document -- string )
    [ { 0 0 } ] 2dip doc-range ;

: completion-mode ( interactor -- symbol )
    [ manifest>> ] [ editor-caret ] [ model>> ] tri up-to-caret " \r\n" split
    {
        { [ dup complete-vocab? ] [ 2drop vocab-completion ] }
        { [ dup complete-CHAR:? ] [ 2drop char-completion ] }
        { [ dup complete-COLOR:? ] [ 2drop color-completion ] }
        [ drop <word-completion> ]
    } cond ;

TUPLE: completion-popup < track interactor table completion-mode ;

: find-completion-popup ( gadget -- popup )
    [ completion-popup? ] find-parent ;

: <completion-model> ( editor element quot -- model )
    [ <element-model> 1/3 seconds <delay> ] dip
    '[ @ keys 1000 short head ] <arrow> ;

M: completion-popup focusable-child* table>> ;

: completion-loc/doc/elt ( popup -- loc doc elt )
    [ interactor>> [ editor-caret ] [ model>> ] bi ]
    [ completion-mode>> completion-element ]
    bi ;

GENERIC: completion-string ( object -- string )

M: object completion-string present ;

: method-completion-string ( word -- string )
    "method-generic" word-prop present ;

M: method completion-string method-completion-string ;

GENERIC# accept-completion-hook 1 ( item popup -- )

: insert-completion ( item popup -- )
    [ completion-string ] [ completion-loc/doc/elt ] bi* set-elt-string ;

: accept-completion ( item table -- )
    find-completion-popup
    [ insert-completion ]
    [ accept-completion-hook ]
    [ nip hide-glass ]
    2tri ;

: <completion-table> ( interactor completion-mode -- table )
    [ completion-element ] [ completion-quot ] [ nip ] 2tri
    [ <completion-model> ] dip <table>
        monospace-font >>font
        t >>selection-required?
        t >>single-click?
        30 >>min-cols
        10 >>min-rows
        10 >>max-rows
        dup '[ _ accept-completion ] >>action ;

: <completion-scroller> ( completion-popup -- scroller )
    table>> <scroller> COLOR: white <solid> >>interior ;

: <completion-popup> ( interactor completion-mode -- popup )
    [ vertical completion-popup new-track ] 2dip
    [ [ >>interactor ] [ >>completion-mode ] bi* ] [ <completion-table> >>table ] 2bi
    dup [ <completion-scroller> ] [ completion-mode>> completion-banner ] bi
    <labeled-gadget> 1 track-add ;

completion-popup H{
    { T{ key-down f f "TAB" } [ table>> row-action ] }
    { T{ key-down f f " " } [ table>> row-action ] }
} set-gestures

: show-completion-popup ( interactor mode -- )
    [ completion-element ] [ <completion-popup> ] 2bi
    show-listener-popup ;

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
        [ nip hide-glass ] [ invoke-command ] 2bi* f
    ] [ 2drop call-next-method ] if ;
