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
    [ curry call-listener ] [ call ] if ;

: modify-operation ( quot operation -- operation )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-operations ( operations quot -- operations )
    swap [ modify-operation ] map-with ;

: modify-listener-operation ( quot operation -- operation )
    clone t over set-operation-listener?
    modify-operation ;

: modify-listener-operations ( operations quot -- operations )
    swap [ modify-listener-operation ] map-with ;

! Objects
[ drop t ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +mouse+ T{ button-up f { S+ } 1 } }
    { +name+ "Push" }
    { +quot+ [ ] }
    { +listener+ t }
} define-operation

! Commands
[ [ command? ] is? ] H{
    { +mouse+ T{ button-up f { S+ } 3 } }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

! Input
[ input? ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Input" }
    { +quot+ [ listener-gadget call-tool ] }
} define-operation

! Words
[ word? ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browser call-tool ] }
} define-operation

[ word? ] H{
    { +mouse+ T{ button-up f f 2 } }
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ word? ] H{
    { +mouse+ T{ button-up f f 3 } }
    { +name+ "Documentation" }
    { +keyboard+ T{ key-down f { A+ } "h" } }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ word? ] H{
    { +mouse+ T{ button-up f { S+ } 3 } }
    { +name+ "Usage" }
    { +keyboard+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +mouse+ T{ button-up f { S+ } 2 } }
    { +name+ "Reload" }
    { +keyboard+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +name+ "Watch" }
    { +quot+ [ watch ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +name+ "Word dataflow" }
    { +keyboard+ T{ key-down f { A+ } "d" } }
    { +quot+ [ word-def show-dataflow ] }
} define-operation

! Vocabularies
[ vocab-link? ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Browse" }
    { +quot+ [ browser call-tool ] }
} define-operation

! Link
[ link? ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Follow" }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ link? ] H{
    { +mouse+ T{ button-up f f 2 } }
    { +name+ "Edit" }
    { +quot+ [ edit ] }
} define-operation

[ link? ] H{
    { +mouse+ T{ button-up f { S+ } 2 } }
    { +name+ "Reload" }
    { +quot+ [ reload ] }
} define-operation

[ word-link? ] H{
    { +mouse+ T{ button-up f f 3 } }
    { +name+ "Definition" }
    { +quot+ [ link-name browser call-tool ] }
} define-operation

! Strings
[ string? ] H{
    { +name+ "Apropos (all)" }
    { +keyboard+ T{ key-down f { A+ } "a" } }
    { +quot+ [ apropos ] }
    { +listener+ t }
} define-operation

: usable-words ( -- seq )
    [
        use get [ hash-values [ dup set ] each ] each
    ] make-hash hash-values natural-sort ;

[ string? ] H{
    { +name+ "Apropos (used)" }
    { +keyboard+ T{ key-down f f "TAB" } }
    { +quot+ [ usable-words (apropos) ] }
    { +listener+ t }
} define-operation

! Quotations
[ quotation? ] H{
    { +name+ "Infer" }
    { +keyboard+ T{ key-down f { C+ A+ } "i" } }
    { +quot+ [ infer . ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Quotation dataflow" }
    { +keyboard+ T{ key-down f { C+ A+ } "d" } }
    { +quot+ [ show-dataflow ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Walk" }
    { +keyboard+ T{ key-down f { C+ A+ } "w" } }
    { +quot+ [ walk ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Time" }
    { +keyboard+ T{ key-down f { C+ A+ } "t" } }
    { +quot+ [ time ] }
    { +listener+ t }
} define-operation

! Dataflow nodes

[ [ node? ] is? ] H{
    { +mouse+ T{ button-up f f 1 } }
    { +name+ "Show dataflow" }
    { +quot+ [ dataflow-gadget call-tool ] }
} define-operation

[ [ node? ] is? ] H{
    { +mouse+ T{ button-up f { S+ } 3 } }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

! Define commands in terms of operations

! Tile commands
tile "Word commands"
\ word class-operations [ tile-definition ] modify-operations
[ command-name "Browse" = not ] subset
define-commands

! Interactor commands

! Listener commands
: selected-word ( editor -- string )
    dup gadget-selection?
    [ dup T{ word-elt } select-elt ] unless
    gadget-selection ;

: word-action ( target -- quot )
    selected-word search ;

: quot-action ( interactor -- quot )
    field-commit parse ;

interactor "Word commands"
\ word class-operations
[ word-action ] modify-listener-operations
define-commands

interactor "Word search commands"
string class-operations
[ selected-word ] modify-listener-operations
define-commands

interactor "Quotation commands"
quotation class-operations
[ quot-action ] modify-listener-operations
define-commands

help-gadget "Link commands"
link class-operations [ help-action ] modify-operations
[ command-name "Follow" = not ] subset
define-commands
