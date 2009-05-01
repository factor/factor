! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.streams.c init fry
namespaces make assocs kernel parser lexer strings.parser vocabs
sequences words memory kernel.private
continuations io vocabs.loader system strings sets
vectors quotations byte-arrays sorting compiler.units
definitions generic generic.standard tools.deploy.config ;
QUALIFIED: bootstrap.stage2
QUALIFIED: classes
QUALIFIED: command-line
QUALIFIED: compiler.errors
QUALIFIED: continuations
QUALIFIED: definitions
QUALIFIED: init
QUALIFIED: layouts
QUALIFIED: source-files
QUALIFIED: source-files.errors
QUALIFIED: vocabs
IN: tools.deploy.shaker

! This file is some hairy shit.

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
    { "cpu.x86" "command-line" "libc" "system" "environment" }
    [ init-hooks get delete-at ] each
    deploy-threads? get [
        "threads" init-hooks get delete-at
    ] unless
    native-io? [
        "io.thread" init-hooks get delete-at
    ] unless
    strip-io? [
        "io.files" init-hooks get delete-at
        "io.backend" init-hooks get delete-at
    ] when
    strip-dictionary? [
        "compiler.units" init-hooks get delete-at
        "tools.vocabs" init-hooks get delete-at
    ] when ;

: strip-debugger ( -- )
    strip-debugger? "debugger" vocab and [
        "Stripping debugger" show
        "vocab:tools/deploy/shaker/strip-debugger.factor"
        run-file
    ] when ;

: strip-libc ( -- )
    "libc" vocab [
        "Stripping manual memory management debug code" show
        "vocab:tools/deploy/shaker/strip-libc.factor"
        run-file
    ] when ;

: strip-call ( -- )
    "Stripping stack effect checking from call( and execute(" show
    "vocab:tools/deploy/shaker/strip-call.factor" run-file ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "vocab:tools/deploy/shaker/strip-cocoa.factor"
        run-file
    ] when ;

: strip-word-names ( words -- )
    "Stripping word names" show
    [ f >>name f >>vocabulary drop ] each ;

: strip-word-defs ( words -- )
    "Stripping symbolic word definitions" show
    [ "no-def-strip" word-prop not ] filter
    [ [ ] >>def drop ] each ;

: sift-assoc ( assoc -- assoc' ) [ nip ] assoc-filter ;

: strip-word-props ( stripped-props words -- )
    "Stripping word properties" show
    [
        swap '[
            [
                [ drop _ member? not ] assoc-filter sift-assoc
                >alist f like
            ] change-props drop
        ] each
    ] [
        H{ } clone '[
            [ [ _ [ ] cache ] map ] change-props drop
        ] each
    ] bi ;

: stripped-word-props ( -- seq )
    [
        strip-dictionary? [
            {
                "alias"
                "boa-check"
                "coercer"
                "combination"
                "compiled-generic-uses"
                "compiled-uses"
                "constraints"
                "custom-inlining"
                "decision-tree"
                "declared-effect"
                "default"
                "default-method"
                "default-output-classes"
                "derived-from"
                "ebnf-parser"
                "engines"
                "forgotten"
                "identities"
                "inline"
                "inlined-block"
                "input-classes"
                "instances"
                "interval"
                "intrinsic"
                "lambda"
                "loc"
                "local-reader"
                "local-reader?"
                "local-writer"
                "local-writer?"
                "local?"
                "macro"
                "members"
                "memo-quot"
                "methods"
                "mixin"
                "method-class"
                "method-generic"
                "modular-arithmetic"
                "no-compile"
                "owner-generic"
                "outputs"
                "participants"
                "predicate"
                "predicate-definition"
                "predicating"
                "primitive"
                "reader"
                "reading"
                "recursive"
                "register"
                "register-size"
                "shuffle"
                "slots"
                "special"
                "specializer"
                ! UI needs this
                ! "superclass"
                "transform-n"
                "transform-quot"
                "type"
                "writer"
                "writing"
            } %
        ] when
        
        strip-prettyprint? [
            {
                "delimiter"
                "flushable"
                "foldable"
                "inline"
                "lambda"
                "macro"
                "memo-quot"
                "parsing"
                "word-style"
            } %
        ] when
    ] { } make ;

: strip-words ( props -- )
    [ word? ] instances
    deploy-word-props? get [ 2dup strip-word-props ] unless
    deploy-word-defs? get [ dup strip-word-defs ] unless
    strip-word-names? [ dup strip-word-names ] when
    2drop ;

: strip-default-methods ( -- )
    strip-debugger? [
        "Stripping default methods" show
        [
            [ generic? ] instances
            [ "No method" throw ] (( -- * )) define-temp
            dup t "default" set-word-prop
            '[
                [ _ "default-method" set-word-prop ] [ make-generic ] bi
            ] each
        ] with-compilation-unit
    ] when ;

: strip-vocab-globals ( except names -- words )
    [ child-vocabs [ words ] map concat ] map concat
    swap [ first2 lookup ] map sift diff ;

: stripped-globals ( -- seq )
    [
        "inspector-hook" "inspector" lookup ,

        {
            continuations:error
            continuations:error-continuation
            continuations:error-thread
            continuations:restarts
            init:init-hooks
            source-files:source-files
            input-stream
            output-stream
            error-stream
        } %

        "io-thread" "io.thread" lookup ,

        "mallocs" "libc.private" lookup ,

        deploy-threads? [
            "initial-thread" "threads" lookup ,
        ] unless

        strip-io? [ io-backend , ] when

        { } {
            "alarms"
            "tools"
            "io.launcher"
            "random"
            "stack-checker"
            "bootstrap"
            "listener"
        } strip-vocab-globals %

        strip-dictionary? [
            "libraries" "alien" lookup ,

            { { "yield-hook" "compiler.utilities" } }
            { "cpu" "compiler" } strip-vocab-globals %

            {
                gensym
                name>char-hook
                classes:next-method-quot-cache
                classes:class-and-cache
                classes:class-not-cache
                classes:class-or-cache
                classes:class<=-cache
                classes:classes-intersect-cache
                classes:implementors-map
                classes:update-map
                command-line:main-vocab-hook
                compiled-crossref
                compiled-generic-crossref
                compiler-impl
                compiler.errors:compiler-errors
                definition-observers
                interactive-vocabs
                layouts:num-tags
                layouts:num-types
                layouts:tag-mask
                layouts:tag-numbers
                layouts:type-numbers
                lexer-factory
                print-use-hook
                root-cache
                source-files.errors:error-types
                vocabs:dictionary
                vocabs:load-vocab-hook
                word
                parser-notes
            } %

            { } { "math.partial-dispatch" } strip-vocab-globals %

            { } { "peg" } strip-vocab-globals %
        ] when

        strip-prettyprint? [
            { } { "prettyprint.config" } strip-vocab-globals %
        ] when

        strip-debugger? [
            {
                compiler.errors:compiler-errors
                continuations:thread-error-hook
            } %
        ] when

        deploy-c-types? get [
            "c-types" "alien.c-types" lookup ,
        ] unless

        deploy-ui? get [
            "ui-error-hook" "ui.gadgets.worlds" lookup ,
        ] when

        "windows-messages" "windows.messages" lookup [ , ] when*
    ] { } make ;

: strip-globals ( stripped-globals -- )
    strip-globals? [
        "Stripping globals" show
        global swap
        '[ drop _ member? not ] assoc-filter
        [ drop string? not ] assoc-filter ! strip CLI args
        sift-assoc
        21 setenv
    ] [ drop ] if ;

: strip-c-io ( -- )
    deploy-io get 2 = os windows? or [
        [
            c-io-backend forget
            "io.streams.c" forget-vocab
        ] with-compilation-unit
    ] unless ;

: compress ( pred post-process string -- )
    "Compressing " prepend show
    [ instances dup H{ } clone [ [ ] cache ] curry map ] dip call
    become ; inline

: compress-byte-arrays ( -- )
    [ byte-array? ] [ ] "byte arrays" compress ;

: remain-compiled ( old new -- old new )
    #! Quotations which were formerly compiled must remain
    #! compiled.
    2dup [
        2dup [ compiled>> ] [ compiled>> not ] bi* and
        [ nip jit-compile ] [ 2drop ] if
    ] 2each ;

: compress-quotations ( -- )
    [ quotation? ] [ remain-compiled ] "quotations" compress
    [ quotation? ] instances [ f >>cached-effect f >>cache-counter drop ] each ;

: compress-strings ( -- )
    [ string? ] [ ] "strings" compress ;

: compress-wrappers ( -- )
    [ wrapper? ] [ ] "wrappers" compress ;

: finish-deploy ( final-image -- )
    "Finishing up" show
    V{ } set-namestack
    V{ } set-catchstack
    "Saving final image" show
    save-image-and-exit ;

SYMBOL: deploy-vocab

: [:c] ( -- word ) ":c" "debugger" lookup ;

: [print-error] ( -- word ) "print-error" "debugger" lookup ;

: deploy-boot-quot ( word -- )
    [
        [ boot ] %
        init-hooks get values concat %
        strip-debugger? [ , ] [
            ! Don't reference try directly
            [:c]
            [print-error]
            '[
                [ _ execute( obj -- ) ] [
                    _ execute( obj -- ) nl
                    _ execute( obj -- )
                ] recover
            ] %
        ] if
        strip-io? [ [ flush ] % ] unless
        [ 0 exit ] %
    ] [ ] make
    set-boot-quot ;

: init-stripper ( -- )
    t "quiet" set-global
    f output-stream set-global ;

: compute-next-methods ( -- )
    [ standard-generic? ] instances [
        "methods" word-prop [
            nip
            dup next-method-quot "next-method-quot" set-word-prop
        ] assoc-each
    ] each
    "vocab:tools/deploy/shaker/next-methods.factor" run-file ;

: strip ( -- )
    init-stripper
    strip-default-methods
    strip-libc
    strip-call
    strip-cocoa
    strip-debugger
    compute-next-methods
    strip-init-hooks
    strip-c-io
    f 5 setenv ! we can't use the Factor debugger or Factor I/O anymore
    deploy-vocab get vocab-main deploy-boot-quot
    stripped-word-props
    stripped-globals strip-globals
    compress-byte-arrays
    compress-quotations
    compress-strings
    compress-wrappers
    strip-words ;

: deploy-error-handler ( quot -- )
    [
        strip-debugger?
        [ error-continuation get call>> callstack>array die 1 exit ]
        ! Don't reference these words literally, if we're stripping the
        ! debugger out we don't want to load the prettyprinter at all
        [ [:c] execute( -- ) nl [print-error] execute( error -- ) flush ] if
        1 exit
    ] recover ; inline

: (deploy) ( final-image vocab config -- )
    #! Does the actual work of a deployment in the slave
    #! stage2 image
    [
        [
            strip-debugger? [
                "debugger" require
                "inspector" require
            ] unless
            deploy-vocab set
            deploy-vocab get require
            deploy-vocab get vocab-main [
                "Vocabulary has no MAIN: word." print flush 1 exit
            ] unless
            strip
            finish-deploy
        ] deploy-error-handler
    ] bind ;

: do-deploy ( -- )
    "output-image" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    "deploy-config" get parse-file first
    (deploy) ;

MAIN: do-deploy
