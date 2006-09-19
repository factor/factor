! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: definitions gadgets gadgets-browser gadgets-dataflow
gadgets-help gadgets-listener gadgets-text gadgets-workspace
hashtables help inference kernel namespaces parser prettyprint
scratchpad sequences strings styles syntax test tools words
generic models ;

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
    { +group+ "Word commands" }
    { +name+ "Browse" }
    { +gesture+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browser call-tool ] }
} define-operation

[ word? ] H{
    { +button+ 2 }
    { +group+ "Word commands" }
    { +name+ "Edit" }
    { +gesture+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ word? ] H{
    { +button+ 3 }
    { +group+ "Word commands" }
    { +name+ "Documentation" }
    { +gesture+ T{ key-down f { A+ } "h" } }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ word? ] H{
    { +group+ "Word commands" }
    { +name+ "Usage" }
    { +gesture+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +group+ "Word commands" }
    { +name+ "Reload" }
    { +gesture+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +group+ "Word commands" }
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
    { +group+ "Word commands" }
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
    { +group+ "Word commands" }
    { +name+ "Apropos (used)" }
    { +gesture+ T{ key-down f f "TAB" } }
    { +quot+ [ usable-words (apropos) ] }
    { +listener+ t }
} define-operation

! Quotations
[ quotation? ] H{
    { +group+ "Quotation commands" }
    { +name+ "Infer" }
    { +gesture+ T{ key-down f { C+ A+ } "i" } }
    { +quot+ [ infer . ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +group+ "Quotation commands" }
    { +name+ "Dataflow" }
    { +gesture+ T{ key-down f { C+ A+ } "d" } }
    { +quot+ [ show-dataflow ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +group+ "Quotation commands" }
    { +name+ "Walk" }
    { +gesture+ T{ key-down f { C+ A+ } "w" } }
    { +quot+ [ walk ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +group+ "Quotation commands" }
    { +name+ "Time" }
    { +gesture+ T{ key-down f { C+ A+ } "t" } }
    { +quot+ [ time ] }
    { +listener+ t }
} define-operation

! Dataflow nodes
[ word? ] H{
    { +group+ "Word commands" }
    { +name+ "Word dataflow" }
    { +gesture+ T{ key-down f { A+ } "d" } }
    { +quot+ [ word-def show-dataflow ] }
} define-operation

[ [ node? ] is? ] H{
    { +button+ 1 }
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

! Listener commands
: selected-word ( editor -- string )
    dup gadget-selection?
    [ dup T{ word-elt } select-elt ] unless
    gadget-selection ;

: listener-selected-word ( listener -- string )
    listener-gadget-input selected-word ;

: word-action ( target -- quot )
    listener-selected-word search ;

: quot-action ( quot -- quot )
    listener-gadget-input field-commit parse ;

listener-gadget [
    {
        "Listener commands"
        { "Send EOF" T{ key-down f { C+ } "d" } [ listener-eof ] }
        { "History" T{ key-down f { C+ } "h" } [ listener-history ] }
        { "Clear output" T{ key-down f f "CLEAR" } [ clear-listener-output ] }
        { "Clear stack" T{ key-down f { C+ } "CLEAR" } [ clear-listener-stack ] }
    } <commands> %

    [ word-action ] \ word class-operations modify-listener-operations %
    [ listener-selected-word ] string class-operations modify-listener-operations %
    [ quot-action ] quotation class-operations modify-listener-operations %
] { } make define-commands*

help-gadget [
    {
        "Help commands"
        { "Back" T{ key-down f { C+ } "b" } [ help-gadget-history go-back ] }
        { "Forward" T{ key-down f { C+ } "f" } [ help-gadget-history go-forward ] }
        { "Home" T{ key-down f { C+ } "h" } [ go-home ] }
    }
    
    [ help-gadget-history model-value ] link class-operations modify-listener-operations
    [ command-name "Follow" = not ] subset %
] { } make define-commands*
