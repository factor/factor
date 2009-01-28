! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors documents
documents.elements fry kernel words sets splitting math math.vectors
models.delay models.filter combinators.short-circuit parser present
sequences tools.completion generic generic.standard.engines.tuple
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.glass
ui.gadgets.scrollers ui.gadgets.tables ui.gadgets.theme
ui.gadgets.worlds ui.gadgets.wrappers ui.gestures ui.render
ui.tools.listener.history ;
IN: ui.tools.listener.completion

: complete-IN:/USE:? ( tokens -- ? )
    2 short tail* { "IN:" "USE:" } intersects? ;

: chop-; ( seq -- seq' )
    { ";" } split1-last [ ] [ ] ?if ;

: complete-USING:? ( tokens -- ? )
    chop-; { "USING:" } intersects? ;

: up-to-caret ( caret document -- string )
    [ { 0 0 } ] 2dip doc-range ;

: vocab-completion? ( interactor -- ? )
    [ editor-caret ] [ model>> ] bi up-to-caret " \r\n" split
    { [ complete-IN:/USE:? ] [ complete-USING:? ] } 1|| ;

! We don't directly depend on the listener tool but we use a couple
! of slots
SLOT: completion-popup
SLOT: interactor
SLOT: history

TUPLE: completion-popup < wrapper table interactor element ;

: find-completion-popup ( gadget -- popup )
    [ completion-popup? ] find-parent ;

SINGLETON: completion-renderer
M: completion-renderer row-columns drop present 1array ;
M: completion-renderer row-value drop ;

: <completion-model> ( editor quot -- model )
    [ one-word-elt <element-model> 1/3 seconds <delay> ] dip
    '[ @ keys 1000 short head ] <filter> ;

M: completion-popup hide-glass-hook
    interactor>> f >>completion-popup request-focus ;

: hide-completion-popup ( popup -- )
    find-world hide-glass ;

: completion-loc/doc ( popup -- loc doc )
    interactor>> [ editor-caret ] [ model>> ] bi ;

GENERIC: completion-string ( object -- string )

M: object completion-string present ;

: method-completion-string ( word -- string )
    "method-generic" word-prop present ;

M: method-body completion-string method-completion-string ;

M: engine-word completion-string method-completion-string ;

GENERIC# accept-completion-hook 1 ( item popup -- )

: insert-completion ( item popup -- )
    [ completion-string ] [ completion-loc/doc ] bi*
    one-word-elt set-elt-string ;

: accept-completion ( item table -- )
    find-completion-popup
    [ insert-completion ]
    [ accept-completion-hook ]
    [ nip hide-completion-popup ]
    2tri ;

: <completion-table> ( interactor quot -- table )
    <completion-model> <table>
        monospace-font >>font
        t >>selection-required?
        completion-renderer >>renderer
        dup '[ _ accept-completion ] >>action ;

: <completion-scroller> ( object -- object )
    <limited-scroller>
        { 300 120 } >>min-dim
        { 300 120 } >>max-dim ;

: <completion-popup> ( interactor quot -- popup )
    [ completion-popup new-gadget ] 2dip
    [ drop >>interactor ] [ <completion-table> >>table ] 2bi
    dup table>> <completion-scroller> add-gadget
    white <solid> >>interior ;

completion-popup H{
    { T{ key-down f f "ESC" } [ hide-completion-popup ] }
    { T{ key-down f f "TAB" } [ table>> row-action ] }
    { T{ key-down f f " " } [ table>> row-action ] }
} set-gestures

CONSTANT: completion-popup-offset { -4 0 }

: (completion-popup-loc) ( interactor element -- loc )
    [ drop screen-loc ] [
        [ [ [ editor-caret ] [ model>> ] bi ] dip prev-elt ] [ drop ] 2bi
        loc>point
    ] 2bi v+ completion-popup-offset v+ ;

: completion-popup-loc-1 ( interactor element -- loc )
    [ (completion-popup-loc) ] [ drop caret-dim ] 2bi v+ ;

: completion-popup-loc-2 ( interactor element popup -- loc )
    [ (completion-popup-loc) ] dip pref-dim { 0 1 } v* v- ;

: completion-popup-fits? ( interactor element popup -- ? )
    [ [ completion-popup-loc-1 ] dip pref-dim v+ ]
    [ 2drop find-world dim>> ]
    3bi [ second ] bi@ <= ;

: completion-popup-loc ( interactor element popup -- loc )
    3dup completion-popup-fits?
    [ drop completion-popup-loc-1 ]
    [ completion-popup-loc-2 ]
    if ;

: show-completion-popup ( interactor quot element -- )
    [ nip ] [ drop <completion-popup> ] 3bi
    [ nip >>completion-popup drop ]
    [ [ 2drop find-world ] [ 2nip ] [ completion-popup-loc ] 3tri ] 3bi
    show-glass ;

: code-completion-popup ( interactor -- )
    dup vocab-completion?
    [ vocabs-matching ] [ words-matching ] ? '[ [ { } ] _ if-empty ]
    one-word-elt show-completion-popup ;

: history-matching ( interactor -- alist )
    history>> elements>>
    [ dup string>> { { CHAR: \n CHAR: \s } } substitute ] { } map>assoc
    <reversed> ;

: history-completion-popup ( interactor -- )
    dup '[ drop _ history-matching ] one-line-elt show-completion-popup ;

: recall-previous ( interactor -- )
    history>> history-recall-previous ;

: recall-next ( interactor -- )
    history>> history-recall-next ;

: selected-word ( editor -- word )
    dup completion-popup>> [
        [ table>> selected-row drop ] [ hide-completion-popup ] bi
    ] [
        selected-token dup search [ ] [ no-word ] ?if
    ] ?if ;