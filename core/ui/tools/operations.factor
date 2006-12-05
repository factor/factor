! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: definitions gadgets gadgets-browser gadgets-dataflow
gadgets-help gadgets-listener gadgets-search gadgets-text
gadgets-workspace hashtables help inference kernel namespaces
parser prettyprint scratchpad sequences strings styles syntax
test tools words generic models io modules errors ;

V{ } clone operations set-global

C: operation ( predicate hash -- operation )
    swap [
        (command) over set-delegate
        +primary+ get over set-operation-primary?
        +secondary+ get over set-operation-secondary?
        +listener+ get over set-operation-listener?
    ] bind
    [ set-operation-predicate ] keep ;

M: operation invoke-command
    [ operation-hook call ] keep
    dup command-quot swap operation-listener?
    [ curry call-listener ] [ call ] if ;

: define-operation ( class props -- )
    <operation> operations get push ;

: modify-command ( quot command -- command )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-commands ( commands quot -- commands )
    swap [ modify-command ] map-with ;

: listener-operation ( hook quot operation -- operation )
    modify-command
    tuck set-operation-hook
    t over set-operation-listener? ;

: listener-operations ( operations hook quot -- operations )
    rot [ >r 2dup r> listener-operation ] map 2nip ;

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

! Restart
[ restart? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Restart" }
    { +quot+ [ restart ] }
    { +listener+ t }
} define-operation

! Pathnames
[ pathname? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Edit" }
    { +quot+ [ pathname-string edit-file ] }
} define-operation

[ pathname? ] H{
    { +name+ "Run file" }
    { +keyboard+ T{ key-down f { A+ } "r" } }
    { +quot+ [ pathname-string run-file ] }
    { +listener+ t }
} define-operation

! Words
[ word? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ browser call-tool ] }
} define-operation

: word-completion-string ( word listener -- string )
    >r dup word-name swap word-vocabulary dup vocab r>
    listener-gadget-input interactor-use memq?
    [ drop ] [ [ "USE: " % % " " % % ] "" make ] if ;

: insert-word ( word -- )
    get-listener [ word-completion-string ] keep
    listener-gadget-input user-input ;

[ word? ] H{
    { +secondary+ t }
    { +name+ "Insert" }
    { +quot+ [ insert-word ] }
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
} define-operation

[ word? ] H{
    { +name+ "Forget" }
    { +quot+ [ forget ] }
} define-operation

[ compound? ] H{
    { +name+ "Word stack effect" }
    { +quot+ [ word-def infer. ] }
    { +listener+ t }
} define-operation

[ compound? ] H{
    { +name+ "Word dataflow" }
    { +quot+ [ word-def show-dataflow ] }
    { +keyboard+ T{ key-down f { A+ } "d" } }
} define-operation

! Vocabularies
[ vocab-link? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ vocab-link-name get-workspace swap show-vocab-words ] }
} define-operation

[ vocab-link? ] H{
    { +name+ "Enter in" }
    { +keyboard+ T{ key-down f { A+ } "i" } }
    { +quot+ [ vocab-link-name set-in ] }
    { +listener+ t }
} define-operation

[ vocab-link? ] H{
    { +secondary+ t }
    { +name+ "Use" }
    { +quot+ [ vocab-link-name use+ ] }
    { +listener+ t }
} define-operation

[ vocab-link? ] H{
    { +name+ "Forget" }
    { +quot+ [ vocab-link-name forget-vocab ] }
} define-operation

! Modules
[ module? ] H{
    { +secondary+ t }
    { +name+ "Run" }
    { +quot+ [ module-name run-module ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "Load" }
    { +quot+ [ module-name require ] }
    { +listener+ t }
} define-operation

[ module? ] H{
    { +name+ "Documentation" }
    { +keyboard+ T{ key-down f { A+ } "h" } }
    { +quot+ [ module-help [ help-gadget call-tool ] when* ] }
} define-operation

[ module? ] H{
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ module? ] H{
    { +primary+ t }
    { +name+ "Browse" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ get-workspace swap show-module-files ] }
} define-operation

[ module? ] H{
    { +name+ "See" }
    { +quot+ [ browser call-tool ] }
} define-operation

[ module? ] H{
    { +name+ "Test" }
    { +quot+ [ module-name test-module ] }
    { +listener+ t }
} define-operation

! Module links
[ module-link? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Run" }
    { +quot+ [ module-name run-module ] }
    { +listener+ t }
} define-operation

[ module-link? ] H{
    { +name+ "Load" }
    { +quot+ [ module-name require ] }
    { +listener+ t }
} define-operation

! Link
[ link? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +name+ "Follow" }
    { +quot+ [ help-gadget call-tool ] }
} define-operation

[ link? ] H{
    { +name+ "Edit" }
    { +keyboard+ T{ key-down f { A+ } "e" } }
    { +quot+ [ edit ] }
} define-operation

[ link? ] H{
    { +name+ "Reload" }
    { +keyboard+ T{ key-down f { A+ } "r" } }
    { +quot+ [ reload ] }
} define-operation

[ word-link? ] H{
    { +name+ "Definition" }
    { +keyboard+ T{ key-down f { A+ } "b" } }
    { +quot+ [ link-name browser call-tool ] }
} define-operation

! Quotations
[ quotation? ] H{
    { +name+ "Quotation stack effect" }
    { +keyboard+ T{ key-down f { C+ } "i" } }
    { +quot+ [ infer. ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Quotation dataflow" }
    { +keyboard+ T{ key-down f { C+ } "d" } }
    { +quot+ [ show-dataflow ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Walk" }
    { +keyboard+ T{ key-down f { C+ } "w" } }
    { +quot+ [ walk ] }
    { +listener+ t }
} define-operation

[ quotation? ] H{
    { +name+ "Time" }
    { +keyboard+ T{ key-down f { C+ } "t" } }
    { +quot+ [ time ] }
    { +listener+ t }
} define-operation

! Dataflow nodes
[ [ node? ] is? ] H{
    { +primary+ t }
    { +name+ "Show dataflow" }
    { +quot+ [ dataflow-gadget call-tool ] }
} define-operation

! Define commands in terms of operations

! Interactor commands
: quot-action ( interactor -- quot )
    dup editor-text swap select-all ;

interactor "words"
{ word compound } [ class-operations ] map concat
[ selected-word ] [ search ] listener-operations
define-commands

interactor "quotations"
quotation class-operations
[ quot-action ] [ parse ] listener-operations
define-commands

help-gadget "toolbar" {
    { "Back" T{ key-down f { C+ } "b" } [ help-gadget-history go-back ] }
    { "Forward" T{ key-down f { C+ } "f" } [ help-gadget-history go-forward ] }
    { "Home" T{ key-down f { C+ } "h" } [ go-home ] }
}
link class-operations [ help-action ] modify-commands
[ command-name "Follow" = not ] subset
append
define-commands
