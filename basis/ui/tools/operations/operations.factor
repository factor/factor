! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit compiler.errors
compiler.units continuations definitions destructors editors
help.topics io.pathnames io.styles kernel libc.private
macros.expander models namespaces parser prettyprint
prettyprint.config quotations see source-files.errors
stack-checker threads tools.annotations tools.crossref
tools.test tools.time tools.walker ui.clipboards ui.commands
ui.gestures ui.operations ui.tools.browser ui.tools.deploy
ui.tools.inspector ui.tools.listener ui.tools.traceback vocabs
vocabs.loader vocabs.parser words ;
IN: ui.tools.operations

! Objects
[ drop t ] \ inspector H{
    { +primary+ t }
} define-operation

: com-prettyprint ( obj -- ) ... ;

[ drop t ] \ com-prettyprint H{
    { +listener+ t }
} define-operation

: com-push ( obj -- obj ) ;

[ drop t ] \ com-push H{
    { +listener+ t }
} define-operation

: com-unparse ( obj -- )
    [ unparse ] without-limits listener-input ;

[ drop t ] \ com-unparse H{ } define-operation

: com-copy-object ( obj -- )
    [ unparse ] without-limits clipboard get set-clipboard-contents ;

[ drop t ] \ com-copy-object H{ } define-operation

! Models
[ { [ model? ] [ ref>> ] } 1&& ] \ inspect-model H{
    { +primary+ t }
} define-operation

! Input
: com-input ( obj -- ) string>> listener-input ;

[ input? ] \ com-input H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

! Restart
[ restart? ] \ continue-restart H{
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
    thread-continuation traceback-window ;

[ thread? ] \ com-thread-traceback-window H{
    { +primary+ t }
    { +secondary+ t }
} define-operation

[ pathname? ] \ edit-file H{
    { +keyboard+ T{ key-down f { C+ } "e" } }
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
} define-operation

[ definition-mixin? ] \ edit H{
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
    path>> run-file ;

[ compiler-error? ] \ com-reload H{
    { +listener+ t }
} define-operation

! Definitions
: com-forget ( defspec -- )
    [ forget ] with-compilation-unit ;

[ definition-mixin? ] \ com-forget H{ } define-operation

[ topic? ] \ com-browse H{
    { +keyboard+ T{ key-down f { C+ } "h" } }
    { +primary+ t }
} define-operation

[ topic? ] \ com-browse-new H{ } define-operation

[ word? ] \ usage. H{
    { +keyboard+ T{ key-down f { C+ } "u" } }
    { +listener+ t }
} define-operation

[ word? ] \ fix H{
    { +keyboard+ T{ key-down f { C+ } "f" } }
    { +listener+ t }
} define-operation

[ [ annotated? not ] [ word? ] bi and ] \ watch H{ } define-operation

[ annotated? ] \ reset H{ } define-operation

[ word? ] \ breakpoint H{ } define-operation

[ word? ] \ see H{
    { +listener+ t }
} define-operation

GENERIC: com-stack-effect ( obj -- )

M: quotation com-stack-effect infer. ;

M: word com-stack-effect 1quotation com-stack-effect ;

: com-enter-in ( vocab -- ) vocab-name set-current-vocab ;

[ vocab? ] \ com-enter-in H{
    { +listener+ t }
} define-operation

: com-use-vocab ( vocab -- ) vocab-name use-vocab ;

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

: com-expand-macros ( quot -- ) expand-macros . ;

[ quotation? ] \ com-expand-macros H{
    { +keyboard+ T{ key-down f { C+ } "m" } }
    { +listener+ t }
} define-operation

! Disposables
[ disposable? ] \ dispose H{ } define-operation

! Disposables with a continuation
PREDICATE: tracked-disposable < disposable
    continuation>> >boolean ;

PREDICATE: tracked-malloc-ptr < malloc-ptr
    continuation>> >boolean ;

: com-creation-traceback ( disposable -- )
    continuation>> traceback-window ;

[ tracked-disposable? ] \ com-creation-traceback H{
    { +primary+ t }
} define-operation

[ tracked-malloc-ptr? ] \ com-creation-traceback H{
    { +primary+ t }
} define-operation

! Operations -> commands
interactor
"quotation"
"These commands operate on the entire contents of the input area."
[ ]
[ quot-action ]
define-operation-map
