! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays gadgets gadgets-listener gadgets-buttons
gadgets-walker gadgets-help gadgets-walker sequences
gadgets-browser gadgets-books gadgets-frames gadgets-controls
gadgets-grids gadgets-presentations kernel models namespaces
styles words help parser inspector memory generic threads
gadgets-text definitions inference test prettyprint math strings
hashtables ;
IN: gadgets-workspace

GENERIC: call-tool* ( arg tool -- )

TUPLE: tool gadget ;

C: tool ( gadget -- tool )
    {
        { [ dup <toolbar> ] f f @top }
        { [ ] set-tool-gadget f @center }
    } make-frame* ;

M: tool gadget-title tool-gadget gadget-title ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

TUPLE: workspace ;

: workspace-tabs
    {
        { "Listener" listener-gadget [ <listener-gadget> ] }
        { "Walker" walker-gadget [ <walker-gadget> ] }
        { "Definitions" browser [ <browser> ] } 
        { "Documentation" help-gadget [ <help-gadget> ] }
    } ;

C: workspace ( -- workspace )
    workspace-tabs
    [ third [ <tool> ] append ] map <book>
    over set-gadget-delegate
    dup dup set-control-self ;

M: workspace pref-dim* delegate pref-dim* { 500 650 } vmax ;

: <workspace-tabs> ( book -- tabs )
    control-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

: init-status ( world -- )
    dup world-status <presentation-help> swap @bottom grid-add ;

: init-tabs ( world -- )
    [ world-gadget <workspace-tabs> ] keep @top grid-add ;

: workspace-window ( -- workspace )
    <workspace> dup <world>
    [ init-status ] keep
    [ init-tabs ] keep
    open-window ;

: show-tool ( class workspace -- tool )
    >r workspace-tabs [ second eq? ] find-with drop r>
    [ get-page ] 2keep control-model set-model ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: find-workspace ( -- workspace )
    [ workspace? ] find-window
    [ world-gadget ] [ workspace-window find-workspace ] if* ;

: call-tool ( arg class -- )
    find-workspace show-tool call-tool* ;

: commands-window ( workspace -- )
    dup find-world world-focus [ ] [ gadget-child ] ?if
    [ commands. ] "Commands" pane-window ;

workspace {
    { f "Keyboard help" T{ key-down f f "F1" } [ commands-window ] }
    { f "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
    { f "Walker" T{ key-down f f "F3" } [ walker-gadget select-tool ] }
    { f "Dictionary" T{ key-down f f "F4" } [ browser select-tool ] }
    { f "Documentation" T{ key-down f f "F5" } [ help-gadget select-tool ] }
    { f "New workspace" T{ key-down f { C+ } "n" } [ workspace-window drop ] }
} define-commands

! Walker tool
M: walker-gadget call-tool* ( arg tool -- )
    >r first2 r> (walk) ;

: walk ( quot -- )
    continuation dup continuation-data pop* 2array
    walker-gadget call-tool stop ;

! Listener tool
G: call-listener ( quot/string listener -- )
    1 standard-combination ;

M: quotation call-listener
    listener-gadget-input interactor-call ;

M: string call-listener
    listener-gadget-input set-editor-text ;

M: input call-listener
    >r input-string r> call-listener ;

M: listener-gadget call-tool* ( quot/string listener -- )
    call-listener ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry listener-gadget call-tool
    ] if ;

! Browser tool
M: browser call-tool*
    over vocab-link? [
        >r vocab-link-name r> show-vocab
    ] [
        show-word
    ] if ;

! Help tool
M: help-gadget call-tool* show-help ;

! Operations
V{ } clone operations set-global

: define-operation ( class props -- )
    <operation> operations get push-new ;

! Objects
object H{
    { +button+ 3 }
    { +name+ "Inspect" }
    { +tool+ listener-gadget }
    { +quot+ [ inspect ] }
} define-operation

! Input
input H{
    { +button+ 1 }
    { +name+ "Input" }
    { +tool+ listener-gadget }
} define-operation

! Words
\ word H{
    { +button+ 1 }
    { +name+ "Browse" }
    { +gesture+ T{ key-down f { A+ } "b" } }
    { +tool+ browser }
} define-operation

\ word H{
    { +button+ 2 }
    { +name+ "Edit" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

\ word H{
    { +name+ "Documentation" }
    { +gesture+ T{ key-down f { A+ } "h" } }
    { +tool+ help-gadget }
} define-operation

\ word H{
    { +name+ "Usage" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
} define-operation

\ word H{
    { +name+ "Reload" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
} define-operation

\ word H{
    { +name+ "Watch" }
    { +tool+ listener-gadget }
    { +quot+ [ reload ] }
} define-operation

! Vocabularies
vocab-link H{
    { +button+ 1 }
    { +name+ "Browse" }
    { +tool+ browser }
} define-operation

! Link
link H{
    { +button+ 1 }
    { +name+ "Follow" }
    { +tool+ help-gadget }
} define-operation

link H{
    { +button+ 2 }
    { +name+ "Edit" }
    { +tool+ listener-gadget }
    { +quot+ [ edit ] }
} define-operation

! Strings
string H{
    { +name+ "Apropos (all)" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { A+ } "a" } }
    { +quot+ [ apropos ] }
} define-operation

: usable-words ( -- seq )
    [
        use get [ hash-values [ dup set ] each ] each
    ] make-hash hash-values natural-sort ;

string H{
    { +name+ "Apropos (used)" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f f "TAB" } }
    { +quot+ [ usable-words (apropos) ] }
} define-operation

! Quotations
quotation H{
    { +name+ "Infer" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { C+ A+ } "i" } }
    { +quot+ [ infer ] }
} define-operation

quotation H{
    { +name+ "Walk" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { C+ A+ } "w" } }
    { +quot+ [ walk ] }
} define-operation

quotation H{
    { +name+ "Time" }
    { +tool+ listener-gadget }
    { +gesture+ T{ key-down f { C+ A+ } "t" } }
    { +quot+ [ time ] }
} define-operation

! Define commands in terms of operations

! Tile commands
tile
[ tile-definition ] \ word class-operations modify-operations
[ operation-tool browser eq? not ] subset
T{ command f f "Close" f [ close-tile ] } add*
define-commands*

! Interactor commands
: selected-word ( editor -- string )
    dup gadget-selection?
    [ dup T{ word-elt } select-elt ] unless ;

: token-action ( target quot -- target quot )
    >r selected-word r> ;

: word-action ( target quot -- target quot )
    \ search add* token-action ;

: quot-action ( target quot -- target quot )
    >r field-commit r> \ parse add* ;

interactor [
    {
        { f "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] }
        { f "Send EOF" T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
    } <commands> %

    [ word-action ] \ word class-operations modify-operations %
    [ token-action ] string class-operations modify-operations %
    [ quot-action ] quotation class-operations modify-operations %

    {
        { f "History" T{ key-down f { C+ } "h" } [ [ interactor-history. ] swap interactor-call ] }
        { f "Clear output" T{ key-down f f "CLEAR" } [ [ clear-output ] swap interactor-call ] }
        { f "Clear stack" T{ key-down f { C+ } "CLEAR" } [ [ clear ] interactor-call ] }
    } <commands> %
] { } make define-commands*
