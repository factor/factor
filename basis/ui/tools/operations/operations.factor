! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit compiler.errors
compiler.units continuations definitions destructors editors
help.topics io.pathnames io.styles kernel libc.private
macros.expander models namespaces parser prettyprint
prettyprint.config quotations see sequences source-files.errors
splitting stack-checker strings threads tools.annotations tools.crossref
tools.test tools.time tools.walker ui.clipboards ui.commands
ui.gestures ui.operations ui.operations.syntax ui.tools.browser ui.tools.deploy
ui.tools.inspector ui.tools.listener ui.tools.traceback vocabs
vocabs.loader vocabs.parser words ;
IN: ui.tools.operations

! Objects
OPERATION: inspector [ drop t ] H{
    { +primary+ t }
}

: com-prettyprint ( obj -- ) ... ;

OPERATION: com-prettyprint [ drop t ] H{
    { +listener+ t }
}

: com-push ( obj -- obj ) ;

OPERATION: com-push [ drop t ] H{
    { +listener+ t }
}

: com-unparse ( obj -- )
    [ unparse ] without-limits listener-input ;

OPERATION: com-unparse [ drop t ] H{ }

: com-copy-object ( obj -- )
    [ unparse ] without-limits clipboard get set-clipboard-contents ;

OPERATION: com-copy-object [ drop t ] H{ }

! Models
OPERATION: inspect-model [ { [ model? ] [ ref>> ] } 1&& ] H{
    { +primary+ t }
}

! Input
: com-input ( obj -- ) string>> listener-input ;

OPERATION: com-input [ input? ] H{
    { +primary+ t }
    { +secondary+ t }
}

! Restart
OPERATION: continue-restart [ restart? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
}

: restart-edit-target ( restart -- target/f )
    dup obj>> dup {
        [ pathname? ] [ { [ word? ] [ boolean? not ] } 1&& ] [ vocab-spec? ]
    } 1|| [
        nip
    ] [
        drop name>> "Load " ?head [
            " again" ?tail [ <pathname> ] [ drop f ] if
        ] [ drop f ] if
    ] if ;

: com-edit-restart ( restart -- )
    restart-edit-target [
        dup pathname? [ edit-file ] [
            dup word? [
                dup where [ edit ] [ vocabulary>> edit-vocab ] if
            ] [ edit ] if
        ] if
    ] when* ;

OPERATION: com-edit-restart [ { [ restart? ] [ restart-edit-target ] } 1&& ] H{
    { +listener+ t }
}

! Continuation
OPERATION: traceback-window [ continuation? ] H{
    { +primary+ t }
    { +secondary+ t }
}

! Thread
: com-thread-traceback-window ( thread -- )
    thread-continuation traceback-window ;

OPERATION: com-thread-traceback-window [ thread? ] H{
    { +primary+ t }
    { +secondary+ t }
}

OPERATION: edit-file [ pathname? ] H{
    { +keyboard+ T{ key-down f { C+ } "e" } }
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
}

OPERATION: edit [ definition-mixin? ] H{
    { +keyboard+ T{ key-down f { C+ } "e" } }
    { +listener+ t }
}

! Source file error
OPERATION: edit-error [ source-file-error? ] H{
    { +primary+ t }
    { +secondary+ t }
    { +listener+ t }
}

: com-reload ( error -- )
    path>> run-file ;

OPERATION: com-reload [ compiler-error? ] H{
    { +listener+ t }
}

! Definitions
: com-forget ( defspec -- )
    [ forget ] with-compilation-unit ;

OPERATION: com-forget [ definition-mixin? ] H{ }

OPERATION: com-browse [ topic? ] H{
    { +keyboard+ T{ key-down f { C+ } "h" } }
    { +primary+ t }
}

OPERATION: com-browse-new [ topic? ] H{ }

OPERATION: usage. [ word? ] H{
    { +keyboard+ T{ key-down f { C+ } "u" } }
    { +listener+ t }
}

OPERATION: fix [ word? ] H{
    { +keyboard+ T{ key-down f { C+ } "f" } }
    { +listener+ t }
}

OPERATION: watch [ [ annotated? not ] [ word? ] bi and ] H{ }

OPERATION: reset [
    { [ word? ]
      [ { [ annotated? ] [ subwords [ annotated? ] any? ] } 1|| ]
    } 1&&
] H{ }

OPERATION: breakpoint [ word? ] H{ }

OPERATION: see [ word? ] H{
    { +listener+ t }
}

GENERIC: com-stack-effect ( obj -- )

M: quotation com-stack-effect infer. ;

M: word com-stack-effect 1quotation com-stack-effect ;

: com-enter-in ( vocab -- ) vocab-name set-current-vocab ;

OPERATION: com-enter-in [ vocab? ] H{
    { +listener+ t }
}

: com-use-vocab ( vocab -- ) vocab-name use-vocab ;

OPERATION: com-use-vocab [ vocab-spec? ] H{
    { +secondary+ t }
    { +listener+ t }
}

OPERATION: run [ vocab-spec? ] H{
    { +listener+ t }
}

OPERATION: test [ vocab? ] H{
    { +listener+ t }
}

OPERATION: deploy-tool [ vocab-spec? ] H{ }

! Quotations
OPERATION: com-stack-effect [ quotation? ] H{
    { +keyboard+ T{ key-down f { C+ } "i" } }
    { +listener+ t }
}

OPERATION: walk [ quotation? ] H{
    { +keyboard+ T{ key-down f { C+ } "w" } }
    { +listener+ t }
}

OPERATION: time [ quotation? ] H{
    { +keyboard+ T{ key-down f { C+ } "t" } }
    { +listener+ t }
}

: com-expand-macros ( quot -- ) expand-macros . ;

OPERATION: com-expand-macros [ quotation? ] H{
    { +keyboard+ T{ key-down f { C+ } "m" } }
    { +listener+ t }
}

! Disposables
OPERATION: dispose [ disposable? ] H{ }

! Disposables with a continuation
PREDICATE: tracked-disposable < disposable
    continuation>> >boolean ;

PREDICATE: tracked-malloc-ptr < malloc-ptr
    continuation>> >boolean ;

: com-creation-traceback ( disposable -- )
    continuation>> traceback-window ;

OPERATION: com-creation-traceback [ { [ tracked-disposable? ] [ tracked-malloc-ptr? ] } 1|| ] H{
    { +primary+ t }
}

! Operations -> commands
interactor
"quotation"
"These commands operate on the entire contents of the input area."
[ ]
[ quot-action ]
define-operation-map
