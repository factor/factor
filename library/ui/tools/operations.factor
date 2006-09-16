! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: definitions gadgets gadgets-browser gadgets-dataflow
gadgets-help gadgets-listener gadgets-text gadgets-workspace
hashtables help inference kernel namespaces parser prettyprint
scratchpad sequences strings styles syntax test tools words
generic ;

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
    { +name+ "Dataflow" }
    { +gesture+ T{ key-down f { C+ A+ } "d" } }
    { +quot+ [ show-dataflow ] }
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

! Dataflow nodes
[ word? ] H{
    { +group+ "Words" }
    { +name+ "Word dataflow" }
    { +gesture+ T{ key-down f { A+ } "d" } }
    { +quot+ [ word-def show-dataflow ] }
} define-operation

[ [ node? ] is? ] H{
    { +button+ 1 }
    { +group+ "Nodes" }
    { +name+ "Quotation dataflow" }
    { +quot+ [ dataflow-gadget call-tool ] }
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
