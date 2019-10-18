! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs ui.tools.interactor ui.tools.listener
ui.tools.workspace help help.topics io.files io.styles kernel
models namespaces prettyprint quotations sequences sorting
source-files strings tools.completion tools.crossref tuples
ui.commands ui.gadgets ui.gadgets.controls ui.gadgets.editors
ui.gadgets.lists ui.gadgets.scrollers ui.gadgets.tracks
ui.gestures ui.operations vocabs words vocabs.loader
tools.browser ;
IN: ui.tools.search

TUPLE: live-search field list ;

: search-value ( live-search -- value )
    live-search-list list-value ;

: search-gesture ( gesture live-search -- operation/f )
    search-value object-operations
    [ operation-gesture = ] curry* find nip ;

M: live-search handle-gesture* ( gadget gesture delegate -- ? )
    drop over search-gesture dup [
        over find-workspace hide-popup
        >r search-value r> invoke-command f
    ] [
        2drop t
    ] if ;

: find-live-search [ [ live-search? ] is? ] find-parent ;

: find-search-list find-live-search live-search-list ;

TUPLE: search-field ;

: <search-field> ( -- gadget ) search-field construct-editor ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-previous ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
	{ T{ key-down f f "PAGE_UP" } [ find-search-list list-page-up ] }
	{ T{ key-down f f "PAGE_DOWN" } [ find-search-list list-page-down ] }
    { T{ key-down f f "RET" } [ find-search-list invoke-value-action ] }
} set-gestures

: <search-model> ( producer -- model )
    >r g live-search-field control-model 200 <delay>
    [ "\n" join ] r> append <filter> ;

: <search-list> ( seq limited? presenter -- gadget )
    >r
    [ limited-completions ] [ completions ] ? curry
    <search-model>
    >r [ find-workspace hide-popup ] r> r>
    swap <list> ;

: <live-search> ( string seq limited? presenter -- gadget )
    live-search construct-empty
    [
        <search-field> g-> set-live-search-field f track,
        <search-list> g-> set-live-search-list
        <scroller> 1 track,
    ] { 0 1 } build-track
    [ live-search-field set-editor-string ] keep
    [ live-search-field end-of-document ] keep ;

M: live-search focusable-child* live-search-field ;

M: live-search pref-dim* drop { 400 200 } ;

: current-word ( workspace -- string )
    workspace-listener listener-gadget-input selected-word ;

: definition-candidates ( words -- candidates )
    [ dup synopsis >lower ] { } map>assoc sort-values ;

: <definition-search> ( string words limited? -- gadget )
    >r definition-candidates r> [ synopsis ] <live-search> ;

: word-candidates ( words -- candidates )
    [ dup word-name >lower ] { } map>assoc ;

: <word-search> ( string words limited? -- gadget )
    >r word-candidates r> [ synopsis ] <live-search> ;

: com-words ( workspace -- )
    dup current-word all-words t <word-search>
    "Word search" show-titled-popup ;

: show-vocab-words ( workspace vocab -- )
    "" over words natural-sort f <word-search>
    "Words in " rot vocab-name append show-titled-popup ;

: show-word-usage ( workspace word -- )
    "" over smart-usage f <definition-search>
    "Words and methods using " rot word-name append
    show-titled-popup ;

: help-candidates ( seq -- candidates )
    [ dup >link swap article-title >lower ] { } map>assoc
    sort-values ;

: <help-search> ( string -- gadget )
    all-articles help-candidates
    f [ article-title ] <live-search> ;

: com-search ( workspace -- )
    "" <help-search> "Help search" show-titled-popup ;

: source-file-candidates ( seq -- candidates )
    [ dup <pathname> swap >lower ] { } map>assoc ;

: <source-file-search> ( string files -- gadget )
    source-file-candidates
    f [ pathname-string ] <live-search> ;

: all-source-files ( -- seq )
    source-files get keys natural-sort ;

: com-sources ( workspace -- )
    "" all-source-files <source-file-search>
    "Source file search" show-titled-popup ;

: show-vocab-files ( workspace vocab -- )
    "" over vocab-files <source-file-search>
    "Source files in " rot vocab-name append show-titled-popup ;

: vocab-candidates ( -- candidates )
    all-vocabs-seq [ dup vocab-name >lower ] { } map>assoc ;

: <vocab-search> ( string -- gadget )
    vocab-candidates f [ vocab-name ] <live-search> ;

: com-vocabs ( workspace -- )
    dup current-word <vocab-search>
    "Vocabulary search" show-titled-popup ;

: history-candidates ( seq -- candidates )
    [ dup <input> swap >lower ] { } map>assoc ;

: <history-search> ( string seq -- gadget )
    history-candidates
    f [ input-string ] <live-search> ;

: listener-history ( listener -- seq )
    listener-gadget-input interactor-history <reversed> ;

: com-history ( workspace -- )
    "" over workspace-listener listener-history <history-search>
    "History search" show-titled-popup ;

workspace "toolbar" f {
    { T{ key-down f { C+ } "p" } com-history }
    { T{ key-down f f "TAB" } com-words }
    { T{ key-down f { C+ } "u" } com-vocabs }
    { T{ key-down f { C+ } "e" } com-sources }
    { T{ key-down f { C+ } "h" } com-search }
} define-command-map
