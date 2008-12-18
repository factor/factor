! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs help help.topics io.pathnames io.styles
kernel models models.delay models.filter namespaces prettyprint
quotations sequences sorting source-files definitions strings
tools.completion tools.crossref classes.tuple vocabs words
vocabs.loader tools.vocabs unicode.case calendar locals
ui.tools.interactor ui.tools.listener ui.tools.workspace
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.lists
ui.gadgets.scrollers ui.gadgets.tracks ui.gadgets.borders
ui.gestures ui.operations ui ;
IN: ui.tools.search

TUPLE: live-search < track field list ;

: search-value ( live-search -- value )
    list>> list-value ;

: search-gesture ( gesture live-search -- operation/f )
    search-value object-operations
    [ operation-gesture = ] with find nip ;

M: live-search handle-gesture ( gesture live-search -- ? )
    tuck search-gesture dup [
        over find-workspace hide-popup
        [ search-value ] dip invoke-command f
    ] [
        2drop t
    ] if ;

: find-live-search ( gadget -- search )
    [ live-search? ] find-parent ;

: find-search-list ( gadget -- list )
    find-live-search list>> ;

TUPLE: search-field < editor ;

: <search-field> ( -- gadget )
    search-field new-editor ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-previous ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
    { T{ key-down f f "PAGE_UP" } [ find-search-list list-page-up ] }
    { T{ key-down f f "PAGE_DOWN" } [ find-search-list list-page-down ] }
    { T{ key-down f f "RET" } [ find-search-list invoke-value-action ] }
} set-gestures

: <search-model> ( live-search producer -- filter )
    [
        field>> model>>
        ui-running? [ 1/5 seconds <delay> ] when
    ] dip [ "\n" join ] prepend <filter> ;

: init-search-model ( live-search seq limited? -- live-search )
    [ 2drop ]
    [ [ limited-completions ] [ completions ] ? curry <search-model> ] 3bi
    >>model ; inline

: <search-list> ( presenter live-search -- list )
    [ [ find-workspace hide-popup ] ] [ ] [ model>> ] tri* <list> ;

:: <live-search> ( string seq limited? presenter -- gadget )
    { 0 1 } live-search new-track
        <search-field> >>field
        seq limited? init-search-model
        presenter over <search-list> >>list
        dup field>> 1 <border> { 1 1 } >>fill f track-add
        dup list>> <scroller> 1 track-add
        string over field>> set-editor-string
        dup field>> end-of-document ;

M: live-search focusable-child* field>> ;

M: live-search pref-dim* drop { 400 200 } ;

: current-word ( workspace -- string )
    listener>> input>> selected-word ;

: definition-candidates ( words -- candidates )
    [ dup synopsis >lower ] { } map>assoc sort-values ;

: <definition-search> ( string words limited? -- gadget )
    [ definition-candidates ] dip [ synopsis ] <live-search> ;

: word-candidates ( words -- candidates )
    [ dup name>> >lower ] { } map>assoc ;

: <word-search> ( string words limited? -- gadget )
    [ word-candidates ] dip [ synopsis ] <live-search> ;

: com-words ( workspace -- )
    dup current-word all-words t <word-search>
    "Word search" show-titled-popup ;

: show-vocab-words ( workspace vocab -- )
    [ "" swap words natural-sort f <word-search> ]
    [ "Words in " swap vocab-name append ]
    bi show-titled-popup ;

: show-word-usage ( workspace word -- )
    [ "" swap smart-usage f <definition-search> ]
    [ "Words and methods using " swap name>> append ]
    bi show-titled-popup ;

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
    f [ string>> ] <live-search> ;

: all-source-files ( -- seq )
    source-files get keys natural-sort ;

: com-sources ( workspace -- )
    "" all-source-files <source-file-search>
    "Source file search" show-titled-popup ;

: show-vocab-files ( workspace vocab -- )
    [ "" swap vocab-files <source-file-search> ]
    [ "Source files in " swap vocab-name append ]
    bi show-titled-popup ;

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
    f [ string>> ] <live-search> ;

: listener-history ( listener -- seq )
    input>> history>> <reversed> ;

: com-history ( workspace -- )
    "" over listener>> listener-history <history-search>
    "History search" show-titled-popup ;

workspace "toolbar" f {
    { T{ key-down f { C+ } "p" } com-history }
    { T{ key-down f f "TAB" } com-words }
    { T{ key-down f { C+ } "u" } com-vocabs }
    { T{ key-down f { C+ } "e" } com-sources }
    { T{ key-down f { C+ } "h" } com-search }
} define-command-map
