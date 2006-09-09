! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays compiler gadgets gadgets-listener gadgets-buttons
gadgets-walker gadgets-help gadgets-walker sequences
gadgets-browser gadgets-books gadgets-frames gadgets-controls
gadgets-grids gadgets-presentations kernel models namespaces
styles words help parser tools memory generic threads
gadgets-text definitions inference test prettyprint math strings
hashtables tools modules interpreter ;
IN: gadgets-workspace

GENERIC: call-tool* ( arg tool -- )

TUPLE: tool gadget ;

C: tool ( gadget -- tool )
    {
        { [ dup <toolbar> ] f f @top }
        { [ ] set-tool-gadget f @center }
    } make-frame* ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

TUPLE: workspace ;

: workspace-tabs
    {
        { "Listener" <listener-gadget> }
        { "Definitions" <browser> } 
        { "Documentation" <help-gadget> }
        { "Walker" <walker-gadget> }
    } ;

C: workspace ( -- workspace )
    workspace-tabs [ second execute <tool> ] map <book>
    over set-gadget-delegate dup dup set-control-self ;

M: workspace pref-dim* delegate pref-dim* { 550 650 } vmax ;

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
    [ book-pages [ tool-gadget class eq? ] find-with swap ] keep
    control-model set-model* ;

: find-workspace ( -- workspace )
    [ workspace? ] find-window
    [ world-gadget ] [ workspace-window find-workspace ] if* ;

: call-tool ( arg class -- )
    find-workspace show-tool call-tool* ;

: commands-window ( workspace -- )
    dup find-world world-focus [ ] [ gadget-child ] ?if
    [ commands. ] "Commands" pane-window ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: tool-window ( class -- ) workspace-window show-tool drop ;

workspace {
    {
        "Tools"
        { "Keyboard help" T{ key-down f f "F1" } [ commands-window ] }
        { "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
        { "Definitions" T{ key-down f f "F3" } [ browser select-tool ] }
        { "Documentation" T{ key-down f f "F4" } [ help-gadget select-tool ] }
        { "Walker" T{ key-down f f "F5" } [ walker-gadget select-tool ] }
    }

    {
        "Tools in new window"
        { "New listener" T{ key-down f { S+ } "F2" } [ listener-gadget tool-window drop ] }
        { "New definitions" T{ key-down f { S+ } "F3" } [ browser tool-window drop ] }
        { "New documentation" T{ key-down f { S+ } "F4" } [ help-gadget tool-window drop ] }
    }
    
    {
        "Workflow"
        { "Recompile changed words" T{ key-down f f "F6" } [ drop [ recompile ] listener-gadget call-tool ] }
        { "Reload changed sources" T{ key-down f f "F7" } [ drop [ reload-modules ] listener-gadget call-tool ] }
    }
} define-commands

! Walker tool
IN: gadgets-walker

M: walker-gadget call-tool* ( continuation walker -- )
    dup reset-walker [
        V{ } clone meta-history set
        restore-normally
    ] with-walker ;

: walker-inspect ( walker -- )
    walker-gadget-ns [ meta-interp get ] bind
    [ inspect ] curry listener-gadget call-tool ;

: walker-step-all ( walker -- )
    dup [ step-all ] walker-command reset-walker
    find-workspace listener-gadget select-tool ;

walker-gadget {
    {
        "Walker"
        { "Step" T{ key-down f f "s" } [ walker-step ] }
        { "Step in" T{ key-down f f "i" } [ walker-step-in ] }
        { "Step out" T{ key-down f f "o" } [ walker-step-out ] }
        { "Step back" T{ key-down f f "b" } [ walker-step-back ] }
        { "Continue" T{ key-down f f "c" } [ walker-step-all ] }
        { "Inspect" T{ key-down f f "n" } [ walker-inspect ] }
    }
} define-commands

[ walker-gadget call-tool stop ] break-hook set-global

IN: tools

: walk ( quot -- ) [ break ] swap append call ;

IN: gadgets-workspace

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

M: operation invoke-command ( target operation -- )
    dup command-quot swap operation-listener?
    [ curry listener-gadget call-tool ] [ call ] if ;

: modify-operation ( quot operation -- operation )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-operations ( quot operations -- operations )
    [ modify-operation ] map-with ;

: modify-listener-operation ( quot operation -- operation )
    clone t over set-operation-listener?
    modify-operation ;

: modify-listener-operations ( quot operations -- operations )
    [ modify-listener-operation ] map-with ;

! Objects
[ drop t ] H{
    { +button+ 1 }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

! Input
[ input? ] H{
    { +button+ 1 }
    { +name+ "Input" }
    { +quot+ [ listener-gadget call-tool ] }
} define-operation

! Words
[ word? ] H{
    { +button+ 1 }
    { +group+ "Words" }
    { +name+ "Browse" }
    { +gesture+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browser call-tool ] }
} define-operation

[ word? ] H{
    { +button+ 2 }
    { +group+ "Words" }
    { +name+ "Edit" }
    { +gesture+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ word? ] H{
    { +button+ 3 }
    { +group+ "Words" }
    { +name+ "Documentation" }
    { +gesture+ T{ key-down f { A+ } "h" } }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ word? ] H{
    { +group+ "Words" }
    { +name+ "Usage" }
    { +gesture+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +group+ "Words" }
    { +name+ "Reload" }
    { +gesture+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +group+ "Words" }
    { +name+ "Watch" }
    { +quot+ [ watch ] }
    { +listener+ t }
} define-operation

! Vocabularies
[ vocab-link? ] H{
    { +button+ 1 }
    { +name+ "Browse" }
    { +quot+ [ browser call-tool ] }
} define-operation

! Link
[ link? ] H{
    { +button+ 1 }
    { +name+ "Follow" }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ link? ] H{
    { +button+ 2 }
    { +name+ "Edit" }
    { +quot+ [ edit ] }
} define-operation

[ word-link? ] H{
    { +button+ 3 }
    { +name+ "Definition" }
    { +quot+ [ link-name browser call-tool ] }
} define-operation

! Strings
[ string? ] H{
    { +group+ "Words" }
    { +name+ "Apropos (all)" }
    { +gesture+ T{ key-down f { A+ } "a" } }
    { +quot+ [ apropos ] }
    { +listener+ t }
} define-operation

: usable-words ( -- seq )
    [
        use get [ hash-values [ dup set ] each ] each
    ] make-hash hash-values natural-sort ;

[ string? ] H{
    { +group+ "Words" }
    { +name+ "Apropos (used)" }
    { +gesture+ T{ key-down f f "TAB" } }
    { +quot+ [ usable-words (apropos) ] }
    { +listener+ t }
} define-operation

! Quotations
[ quotation? ] H{
    { +group+ "Quotations" }
    { +name+ "Infer" }
    { +gesture+ T{ key-down f { C+ A+ } "i" } }
    { +quot+ [ infer . ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +group+ "Quotations" }
    { +name+ "Walk" }
    { +gesture+ T{ key-down f { C+ A+ } "w" } }
    { +quot+ [ walk ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +group+ "Quotations" }
    { +name+ "Time" }
    { +gesture+ T{ key-down f { C+ A+ } "t" } }
    { +quot+ [ time ] }
    { +listener+ t }
} define-operation

! Define commands in terms of operations

! Tile commands
tile
[ tile-definition ] \ word class-operations modify-operations
[ command-name "Browse" = not ] subset
T{ command f f "Close" f [ close-tile ] } add*
define-commands*

! Interactor commands
: selected-word ( editor -- string )
    dup gadget-selection?
    [ dup T{ word-elt } select-elt ] unless
    gadget-selection ;

: word-action ( target -- quot )
    selected-word search ;

: quot-action ( quot -- quot )
    field-commit parse ;

interactor [
    {
        "Listener"
        { "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] }
        { "Send EOF" T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
    } <commands> %

    [ word-action ] \ word class-operations modify-listener-operations %
    [ selected-word ] string class-operations modify-listener-operations %
    [ quot-action ] quotation class-operations modify-listener-operations %

    {
        "Listener"
        { "History" T{ key-down f { C+ } "h" } [ [ interactor-history. ] swap interactor-call ] }
        { "Clear output" T{ key-down f f "CLEAR" } [ [ clear-output ] swap interactor-call ] }
        { "Clear stack" T{ key-down f { C+ } "CLEAR" } [ [ clear ] swap interactor-call ] }
    } <commands> %
] { } make define-commands*
