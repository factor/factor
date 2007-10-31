! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations definitions ui.tools.browser
ui.tools.interactor ui.tools.listener ui.tools.profiler
ui.tools.search ui.tools.traceback ui.tools.workspace generic
help.topics inference inspector io.files io.styles kernel
namespaces parser prettyprint quotations tools.annotations
editors tools.profiler tools.test tools.time tools.walker
ui.commands ui.gadgets.editors ui.gestures ui.operations vocabs
vocabs.loader words sequences tools.browser classes
ui.tools.deploy ;
IN: ui.tools.operations

V{ } clone operations set-global

! Objects
[ drop t ] \ inspect H{
    { +primary+ t }
    { +listener+ t }
} define-operation

: com-prettyprint . ;

[ drop t ] \ com-prettyprint H{
    { +listener+ t }
} define-operation

: com-push ;

[ drop t ] \ com-push H{
    { +listener+ t }
} define-operation

: com-unparse unparse listener-input ;

[ drop t ] \ com-unparse H{ } define-operation

! Input

: com-input input-string listener-input ;

[ input? ] \ com-input H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

! Restart
[ restart? ] \ restart H{
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
} define-operation

! Continuation
[ continuation? ] \ traceback-window H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

! Pathnames
: edit-file edit ;

[ pathname? ] \ edit-file H{
    { +keyboard+ T{ key-down f { C+ } "E" } }
    { +primary+ t }
    { +secondary+ t }
} define-operation

UNION: definition word method-spec link ;

UNION: editable-definition definition vocab vocab-link ;

[ editable-definition? ] \ edit H{
    { +keyboard+ T{ key-down f { C+ } "E" } }
} define-operation

UNION: reloadable-definition definition pathname ;

[ reloadable-definition? ] \ reload H{
    { +keyboard+ T{ key-down f { C+ } "R" } }
    { +listener+ t }
} define-operation

[ dup reloadable-definition? swap vocab-spec? or ] \ forget
H{ } define-operation

! Words
[ word? ] \ insert-word H{
    { +secondary+ t }
} define-operation

[
    class
    { link word vocab vocab-link vocab-tag vocab-author }
    memq?
] \ com-follow H{
    { +keyboard+ T{ key-down f { C+ } "H" } }
    { +primary+ t }
} define-operation

: com-usage ( word -- )
    get-workspace swap show-word-usage ;

[ word? ] \ com-usage H{
    { +keyboard+ T{ key-down f { C+ } "U" } }
} define-operation

[ word? ] \ fix H{
    { +keyboard+ T{ key-down f { C+ } "F" } }
    { +listener+ t }
} define-operation

[ word? ] \ watch H{ } define-operation

[ word? ] \ breakpoint H{ } define-operation

GENERIC: com-stack-effect ( obj -- )

M: quotation com-stack-effect infer. ;

M: word com-stack-effect word-def com-stack-effect ;

[ compound? ] \ com-stack-effect H{
    { +listener+ t }
} define-operation

! Vocabularies
: com-vocab-words get-workspace swap show-vocab-words ;

[ vocab? ] \ com-vocab-words H{
    { +secondary+ t }
    { +keyboard+ T{ key-down f { C+ } "B" } }
} define-operation

: com-enter-in vocab-name set-in ;

[ vocab? ] \ com-enter-in H{
    { +keyboard+ T{ key-down f { C+ } "I" } }
    { +listener+ t }
} define-operation

: com-use-vocab vocab-name use+ ;

[ vocab-spec? ] \ com-use-vocab H{
    { +secondary+ t }
    { +listener+ t }
} define-operation

[ vocab-spec? ] \ run H{
    { +keyboard+ T{ key-down f { C+ } "R" } }
    { +listener+ t }
} define-operation

[ vocab? ] \ test H{
    { +keyboard+ T{ key-down f { C+ } "T" } }
    { +listener+ t }
} define-operation

[ vocab-spec? ] \ deploy-tool H{ } define-operation

! Quotations
[ quotation? ] \ com-stack-effect H{
    { +keyboard+ T{ key-down f { C+ } "i" } }
    { +listener+ t }
} define-operation

[ quotation? ] \ walk H{
    { +keyboard+ T{ key-down f { C+ } "w" } }
    { +listener+ t }
} define-operation

[ quotation? ] \ time H{
    { +keyboard+ T{ key-down f { C+ } "t" } }
    { +listener+ t }
} define-operation

: com-show-profile profiler-gadget call-tool ;

: com-profile ( quot -- ) profile f com-show-profile ;

[ quotation? ] \ com-profile H{
    { +keyboard+ T{ key-down f { C+ } "r" } }
    { +listener+ t }
} define-operation

! Profiler presentations
[ usage-profile? ] \ com-show-profile H{
    { +primary+ t }
} define-operation

[ vocab-profile? ] \ com-show-profile H{
    { +primary+ t }
} define-operation

! Operations -> commands
source-editor
"word"
"These commands operate on the Factor word named by the token at the caret position."
\ selected-word
[ selected-word ]
[ search ] 
define-operation-map

interactor
"quotation"
"These commands operate on the entire contents of the input area."
[ ]
[ quot-action ]
[ parse ]
define-operation-map
