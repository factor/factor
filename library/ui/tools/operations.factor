! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: definitions gadgets gadgets-browser gadgets-dataflow
gadgets-help gadgets-listener gadgets-search gadgets-text
gadgets-workspace hashtables help inference kernel namespaces
parser prettyprint scratchpad sequences strings styles syntax
test tools words generic models io modules ;

V{ } clone operations set-global

: define-operation ( class props -- )
    <operation> operations get push-new ;

M: operation invoke-command ( target operation -- )
    dup command-quot swap operation-listener?
    [ curry call-listener ] [ call ] if ;

: modify-listener-operation ( quot operation -- operation )
    clone t over set-operation-listener?
    modify-operation ;

: modify-listener-operations ( operations quot -- operations )
    swap [ modify-listener-operation ] map-with ;

! Objects
[ drop t ] H{
    { +primary+ t }
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +name+ "Prettyprint" }
    { +quot+ [ . ] }
    { +listener+ t }
} define-operation

[ drop t ] H{
    { +name+ "Push" }
    { +quot+ [ ] }
    { +listener+ t }
} define-operation

! Input
[ input? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Input" }
    { +quot+ [ listener-gadget call-tool ] }
} define-operation

! Pathnames
[ pathname? ] H{
    { +primary+ t }
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ pathname-string edit-file ] }
} define-operation

[ pathname? ] H{
    { +name+ "Run file" }
    { +quot+ [ pathname-string [ run-file ] curry call-listener ] }
} define-operation

! Words
[ word? ] H{
    { +default+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browser call-tool ] }
} define-operation

[ word? ] H{
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ word? ] H{
    { +name+ "Documentation" }
    { +keyboard+ T{ key-down f { A+ } "h" } }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ word? ] H{
    { +name+ "Edit documentation" }
    { +quot+ [ <link> edit ] }
} define-operation

[ word? ] H{
    { +name+ "Usage" }
    { +keyboard+ T{ key-down f { A+ } "u" } }
    { +quot+ [ usage. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
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
    { +name+ "Forget" }
    { +quot+ [ forget ] }
} define-operation

[ word? ] H{
    { +name+ "Word stack effect" }
    { +keyboard+ T{ key-down f { A+ } "i" } }
    { +quot+ [ word-def infer. ] }
    { +listener+ t }
} define-operation

[ word? ] H{
    { +name+ "Word dataflow" }
    { +keyboard+ T{ key-down f { A+ } "d" } }
    { +quot+ [ word-def show-dataflow ] }
} define-operation

! Vocabularies
[ vocab-link? ] H{
    { +default+ t }
    { +name+ "Browse" }
    { +quot+ [ browser call-tool ] }
} define-operation

[ vocab-link? ] H{
    { +name+ "Enter in" }
    { +quot+ [ vocab-link-name [ set-in ] curry call-listener ] }
} define-operation

[ vocab-link? ] H{
    { +name+ "Use" }
    { +quot+ [ vocab-link-name [ use+ ] curry call-listener ] }
} define-operation

[ vocab-link? ] H{
    { +name+ "Forget" }
    { +quot+ [ vocab-link-name forget-vocab ] }
} define-operation

! Modules
[ module? ] H{
    { +name+ "Run" }
    { +quot+ [ module-name run-module ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "Documentation" }
    { +quot+ [ module-help [ help-gadget call-tool ] when* ] }
} define-operation

[ module? ] H{
    { +name+ "Edit" }
    { +quot+ [ edit ] }
} define-operation

[ module? ] H{
    { +name+ "Reload" }
    { +quot+ [ reload-module ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "See" }
    { +quot+ [ see ] }
    { +listener+ t }
} define-operation

! Link
[ link? ] H{
    { +default+ t }
    { +name+ "Follow" }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ link? ] H{
    { +name+ "Edit" }
    { +quot+ [ edit ] }
} define-operation

[ link? ] H{
    { +name+ "Reload" }
    { +quot+ [ reload ] }
} define-operation

[ word-link? ] H{
    { +name+ "Definition" }
    { +quot+ [ link-name browser call-tool ] }
} define-operation

! Quotations
[ quotation? ] H{
    { +name+ "Quotation stack effect" }
    { +keyboard+ T{ key-down f { C+ A+ } "i" } }
    { +quot+ [ infer. ] }
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
    { +default+ t }
    { +name+ "Show dataflow" }
    { +quot+ [ dataflow-gadget call-tool ] }
} define-operation

[ [ node? ] is? ] H{
    { +name+ "Inspect" }
    { +quot+ [ inspect ] }
    { +listener+ t }
} define-operation

! Define commands in terms of operations

! Tile commands
tile "toolbar"
\ word class-operations [ tile-definition ] modify-operations
[ command-name "Browse" = not ] subset
{ "Close" f [ close-tile ] } add*
define-commands

! Interactor commands
: word-action ( target -- quot )
    selected-word search ;

: quot-action ( interactor -- quot )
    dup editor-text swap select-all parse ;

interactor "words"
\ word class-operations
[ word-action ] modify-listener-operations
define-commands

interactor "quotations"
quotation class-operations
[ quot-action ] modify-listener-operations
define-commands

help-gadget "toolbar" {
    { "Back" T{ key-down f { C+ } "b" } [ help-gadget-history go-back ] }
    { "Forward" T{ key-down f { C+ } "f" } [ help-gadget-history go-forward ] }
    { "Home" T{ key-down f { C+ } "h" } [ go-home ] }
}
link class-operations [ help-action ] modify-operations
[ command-name "Follow" = not ] subset
append
define-commands
