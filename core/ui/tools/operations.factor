! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: operations
USING: arrays definitions gadgets gadgets-browser gadgets-help
gadgets-listener gadgets-search gadgets-text gadgets-interactor
gadgets-workspace hashtables help inference kernel namespaces
parser prettyprint scratchpad sequences strings styles syntax
test tools words generic models io modules errors quotations
inspector gadgets-traceback ;

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

: com-browse browser call-tool ;

[ dup word? swap method-spec? or ] \ com-browse H{
    { +primary+ t }
    { +keyboard+ T{ key-down f { C+ } "B" } }
} define-operation

: definition? dup word? over method-spec? or swap link? or ;

[ dup definition? swap module? or ] \ edit H{
    { +keyboard+ T{ key-down f { C+ } "E" } }
} define-operation

[ dup definition? swap pathname? or ] \ reload H{
    { +keyboard+ T{ key-down f { C+ } "R" } }
    { +listener+ t }
} define-operation

[ definition? ] \ forget H{ } define-operation

! Words
[ word? ] \ insert-word H{
    { +secondary+ t }
} define-operation

: com-word-help help-gadget call-tool ;

[ word? ] \ com-word-help H{
    { +keyboard+ T{ key-down f { C+ } "H" } }
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
: com-browse-vocabulary
    vocab-link-name get-workspace swap show-vocab-words ;

[ vocab-link? ] \ com-browse-vocabulary H{
    { +primary+ t }
    { +keyboard+ T{ key-down f { C+ } "B" } }
} define-operation

: com-enter-in vocab-link-name set-in ;

[ vocab-link? ] \ com-enter-in H{
    { +keyboard+ T{ key-down f { C+ } "I" } }
    { +listener+ t }
} define-operation

: com-use-vocabulary vocab-link-name use+ ;

[ vocab-link? ] \ com-use-vocabulary H{
    { +secondary+ t }
    { +listener+ t }
} define-operation

: com-forget-vocabulary vocab-link-name forget-vocab ;

[ vocab-link? ] \ com-forget-vocabulary H{ } define-operation

! Modules
: com-run-module module-name run-module ;

[ dup module? swap module-link? or ] \ com-run-module H{
    { +secondary+ t }
    { +listener+ t }
} define-operation

: com-load-module module-name require ;

[ dup module? swap module-link? or ] \ com-load-module H{
    { +listener+ t }
} define-operation

: com-module-help module-help [ help-gadget call-tool ] when* ;

[ module? ] \ com-module-help H{
    { +keyboard+ T{ key-down f { C+ } "H" } }
} define-operation

: browse-module ( module -- )
    module-name dup require
    get-workspace swap module show-module-files ;

[ dup module? swap module-link? or ] \ browse-module H{
    { +primary+ t }
    { +keyboard+ T{ key-down f { C+ } "B" } }
} define-operation

: com-test-module module-name test-module ;

[ module? ] \ com-test-module H{
    { +keyboard+ T{ key-down f { C+ } "T" } }
    { +listener+ t }
} define-operation

! Link
[ link? ] \ com-follow H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

: com-definition link-name com-browse ;

[ word-link? ] \ com-definition H{
    { +keyboard+ T{ key-down f { C+ } "B" } }
} define-operation

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
