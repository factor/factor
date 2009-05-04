! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations definitions generic help.topics threads
stack-checker summary io.pathnames io.styles kernel namespaces parser
prettyprint quotations tools.crossref tools.annotations editors
tools.profiler tools.test tools.time tools.walker vocabs vocabs.loader
words sequences classes compiler.errors compiler.units
accessors vocabs.parser macros.expander ui ui.tools.browser
ui.tools.listener ui.tools.listener.completion ui.tools.profiler
ui.tools.inspector ui.tools.traceback ui.commands ui.gadgets.editors
ui.gestures ui.operations ui.tools.deploy models help.tips
source-files.errors ;
IN: ui.tools.operations

! Objects
[ drop t ] \ inspector H{
    { +primary+ t }
} define-operation

: com-prettyprint ( obj -- ) . ;

[ drop t ] \ com-prettyprint H{
    { +listener+ t }
} define-operation

: com-push ( obj -- obj ) ;

[ drop t ] \ com-push H{
    { +listener+ t }
} define-operation

: com-unparse ( obj -- ) unparse listener-input ;

[ drop t ] \ com-unparse H{ } define-operation

! Models
[ model? ] \ inspect-model H{
    { +primary+ t }
} define-operation

! Input
: com-input ( obj -- ) string>> listener-input ;

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

! Thread
: com-thread-traceback-window ( thread -- )
    continuation>> dup occupied>>
    [ value>> traceback-window ]
    [ drop beep ]
    if ;

[ thread? ] \ com-thread-traceback-window H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

! Pathnames
: edit-file ( pathname -- ) edit ;

[ pathname? ] \ edit-file H{
    { +keyboard+ T{ key-down f { C+ } "e" } }
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
} define-operation

[ definition? ] \ edit H{
    { +keyboard+ T{ key-down f { C+ } "e" } }
    { +listener+ t }
} define-operation

! Source file error
[ source-file-error? ] \ edit-error H{
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
} define-operation

: com-reload ( error -- )
    file>> run-file ;

[ compiler-error? ] \ com-reload H{
    { +listener+ t }
} define-operation

! Definitions
: com-forget ( defspec -- )
    [ forget ] with-compilation-unit ;

[ definition? ] \ com-forget H{ } define-operation

[ topic? ] \ com-browse H{
    { +keyboard+ T{ key-down f { C+ } "h" } }
    { +primary+ t }
} define-operation

[ word? ] \ usage. H{
    { +keyboard+ T{ key-down f { C+ } "u" } }
    { +listener+ t }
} define-operation

[ word? ] \ fix H{
    { +keyboard+ T{ key-down f { C+ } "f" } }
    { +listener+ t }
} define-operation

[ word? ] \ watch H{ } define-operation

[ word? ] \ breakpoint H{ } define-operation

GENERIC: com-stack-effect ( obj -- )

M: quotation com-stack-effect infer. ;

M: word com-stack-effect 1quotation com-stack-effect ;

: com-enter-in ( vocab -- ) vocab-name set-in ;

[ vocab? ] \ com-enter-in H{
    { +listener+ t }
} define-operation

: com-use-vocab ( vocab -- ) vocab-name use+ ;

[ vocab-spec? ] \ com-use-vocab H{
    { +secondary+ t }
    { +listener+ t }
} define-operation

[ vocab-spec? ] \ run H{
    { +listener+ t }
} define-operation

[ vocab? ] \ test H{
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

[ quotation? ] \ com-profile H{
    { +keyboard+ T{ key-down f { C+ } "o" } }
    { +listener+ t }
} define-operation

: com-expand-macros ( quot -- ) expand-macros . ;

[ quotation? ] \ com-expand-macros H{
    { +keyboard+ T{ key-down f { C+ } "m" } }
    { +listener+ t }
} define-operation

! Operations -> commands
interactor
"quotation"
"These commands operate on the entire contents of the input area."
[ ]
[ quot-action ]
define-operation-map