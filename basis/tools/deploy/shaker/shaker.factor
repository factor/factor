! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors io.backend io.streams.c init fry
namespaces math make assocs kernel parser parser.notes lexer
strings.parser vocabs sequences sequences.deep sequences.private
words memory kernel.private continuations io vocabs.loader
system strings sets vectors quotations byte-arrays sorting
compiler.units definitions generic generic.standard
generic.single tools.deploy.config combinators classes
classes.builtin slots.private grouping command-line ;
QUALIFIED: bootstrap.stage2
QUALIFIED: classes.private
QUALIFIED: compiler.crossref
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

: add-command-line-hook ( -- )
    [ (command-line) command-line set-global ] "command-line"
    startup-hooks get set-at ;

: strip-startup-hooks ( -- )
    "Stripping startup hooks" show
    {
        "alien.strings"
        "cpu.x86"
        "environment"
        "libc"
    }
    [ startup-hooks get delete-at ] each
    deploy-threads? get [
        "threads" startup-hooks get delete-at
    ] unless
    native-io? [
        "io.thread" startup-hooks get delete-at
    ] unless
    strip-io? [
        "io.files" startup-hooks get delete-at
        "io.backend" startup-hooks get delete-at
        "io.thread" startup-hooks get delete-at
    ] when
    strip-dictionary? [
        {
            ! "compiler.units"
            "vocabs"
            "vocabs.cache"
            "source-files.errors"
        } [ startup-hooks get delete-at ] each
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

: strip-destructors ( -- )
    "Stripping destructor debug code" show
    "vocab:tools/deploy/shaker/strip-destructors.factor"
    run-file ;

: strip-call ( -- )
    "Stripping stack effect checking from call( and execute(" show
    "vocab:tools/deploy/shaker/strip-call.factor" run-file ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "vocab:tools/deploy/shaker/strip-cocoa.factor"
        run-file
    ] when ;

: strip-specialized-arrays ( -- )
    strip-dictionary? "specialized-arrays" vocab and [
        "Stripping specialized arrays" show
        "vocab:tools/deploy/shaker/strip-specialized-arrays.factor"
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
                "generic-call-sites"
                "effect-dependencies"
                "definition-dependencies"
                "conditional-dependencies"
                "dependency-checks"
                "constant"
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
                "low-order"
                "macro"
                "members"
                "memo-quot"
                "methods"
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
                "struct-slots"
                ! UI needs this
                ! "superclass"
                "transform-n"
                "transform-quot"
                "type"
                "typed-def"
                "typed-word"
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
        
        deploy-c-types? get [
            { "c-type" "struct-slots" "struct-align" } %
        ] unless
    ] { } make ;

: strip-words ( props -- )
    [ word? ] instances
    deploy-word-props? get [ 2dup strip-word-props ] unless
    deploy-word-defs? get [ dup strip-word-defs ] unless
    strip-word-names? [ dup strip-word-names strip-stack-traces ] when
    2drop ;

: compiler-classes ( -- seq )
    { "compiler" "stack-checker" }
    [ child-vocabs [ words ] map concat [ class? ] filter ]
    map concat unique ;

: prune-decision-tree ( tree classes -- )
    [ tuple class>type ] 2dip '[
        dup array? [
            [
                dup array? [
                    [
                        2 group
                        [ drop _ key? not ] assoc-filter
                        concat
                    ] map
                ] when
            ] map
        ] when
    ] change-nth ;

: strip-compiler-classes ( -- )
    strip-dictionary? [
        "Stripping compiler classes" show
        [ single-generic? ] instances
        compiler-classes '[ "decision-tree" word-prop _ prune-decision-tree ] each
    ] when ;

: recursive-subst ( seq old new -- )
    '[
        _ _
        {
            ! old becomes new
            { [ 3dup drop eq? ] [ 2nip ] }
            ! recurse into arrays
            { [ pick array? ] [ [ dup ] 2dip recursive-subst ] }
            ! otherwise do nothing
            [ 2drop ]
        } cond
    ] map! drop ;

: strip-default-method ( generic new-default -- )
    [
        [ "decision-tree" word-prop ]
        [ "default-method" word-prop ] bi
    ] dip
    recursive-subst ;

: new-default-method ( -- gensym )
    [ [ "No method" throw ] (( -- * )) define-temp ] with-compilation-unit ;

: strip-default-methods ( -- )
    ! In a development image, each generic has its own default method.
    ! This gives better error messages for runtime type errors, but
    ! takes up space. For deployment we merge them all together.
    strip-debugger? [
        "Stripping default methods" show
        [ single-generic? ] instances
        new-default-method '[ _ strip-default-method ] each
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
            init:startup-hooks
            source-files:source-files
            input-stream
            output-stream
            error-stream
        } %

        "io-thread" "io.thread" lookup ,

        "disposables" "destructors" lookup ,

        "functor-words" "functors.backend" lookup ,
        
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
                classes.private:next-method-quot-cache
                classes.private:class-and-cache
                classes.private:class-not-cache
                classes.private:class-or-cache
                classes.private:class<=-cache
                classes.private:classes-intersect-cache
                classes.private:implementors-map
                classes.private:update-map
                main-vocab-hook
                compiler.crossref:compiled-crossref
                compiler.crossref:generic-call-site-crossref
                compiler-impl
                compiler.errors:compiler-errors
                lexer-factory
                print-use-hook
                root-cache
                source-files.errors:error-types
                source-files.errors:error-observers
                vocabs:dictionary
                vocabs:load-vocab-hook
                vocabs:vocab-observers
                word
                parser-notes
            } %

            { } { "layouts" } strip-vocab-globals %

            { } { "math.partial-dispatch" } strip-vocab-globals %

            { } { "math.vectors.simd" } strip-vocab-globals %

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
            
            deploy-ui? get [
                "ui-error-hook" "ui.gadgets.worlds" lookup ,
            ] when
        ] when

        deploy-c-types? get [
            "c-types" "alien.c-types" lookup ,
        ] unless

        "windows-messages" "windows.messages" lookup [ , ] when*
    ] { } make ;

: strip-globals ( stripped-globals -- )
    strip-globals? [
        "Stripping globals" show
        global swap
        '[ drop _ member? not ] assoc-filter
        [ drop string? not ] assoc-filter ! strip CLI args
        sift-assoc
        21 set-special-object
    ] [ drop ] if ;

: strip-c-io ( -- )
    strip-io?
    deploy-io get 3 = os windows? not and
    or [
        [
            c-io-backend forget
            "io.streams.c" forget-vocab
            "io-thread-running?" "io.thread" lookup [
                global delete-at
            ] when*
        ] with-compilation-unit
    ] when ;

: compress ( pred post-process string -- )
    "Compressing " prepend show
    [ instances dup H{ } clone [ [ ] cache ] curry map ] dip call
    become ; inline

: compress-object? ( obj -- ? )
    {
        { [ dup array? ] [ empty? ] }
        { [ dup byte-array? ] [ drop t ] }
        { [ dup string? ] [ drop t ] }
        { [ dup wrapper? ] [ drop t ] }
        [ drop f ]
    } cond ;

: compress-objects ( -- )
    [ compress-object? ] [ ] "objects" compress ;

: remain-compiled ( old new -- old new )
    ! Quotations which were formerly compiled must remain
    ! compiled.
    2dup [
        2dup [ quot-compiled? ] [ quot-compiled? not ] bi* and
        [ nip jit-compile ] [ 2drop ] if
    ] 2each ;

: compress-quotations ( -- )
    [ quotation? ] [ remain-compiled ] "quotations" compress
    [ quotation? ] instances [ f >>cached-effect f >>cache-counter drop ] each ;

SYMBOL: deploy-vocab

: [:c] ( -- word ) ":c" "debugger" lookup ;

: [print-error] ( -- word ) "print-error" "debugger" lookup ;

: deploy-startup-quot ( word -- )
    [
        [ boot ] %
        startup-hooks get values concat %
        strip-debugger? [ , ] [
            ! Don't reference 'try' directly since we don't want
            ! to pull in the debugger and prettyprinter into every
            ! deployed app
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
    set-startup-quot ;

: startup-stripper ( -- )
    t "quiet" set-global
    f output-stream set-global ;

: next-method* ( method -- quot )
    [ "method-class" word-prop ]
    [ "method-generic" word-prop ] bi
    next-method ;

: calls-next-method? ( method -- ? )
    def>> flatten \ (call-next-method) swap member-eq? ;

: compute-next-methods ( -- )
    [ standard-generic? ] instances [
        "methods" word-prop values [ calls-next-method? ] filter
        [ dup next-method* "next-method" set-word-prop ] each
    ] each
    "vocab:tools/deploy/shaker/next-methods.factor" run-file ;

: (clear-megamorphic-cache) ( i array -- )
    ! Can't do any dispatch while clearing caches since that
    ! might leave them in an inconsistent state.
    2dup 1 slot < [
        2dup [ f ] 2dip set-array-nth
        [ 1 + ] dip (clear-megamorphic-cache)
    ] [ 2drop ] if ;

: clear-megamorphic-cache ( array -- )
    [ 0 ] dip (clear-megamorphic-cache) ;

: find-megamorphic-caches ( -- seq )
    "Finding megamorphic caches" show
    [ standard-generic? ] instances [ def>> third ] map ;

: clear-megamorphic-caches ( cache -- )
    "Clearing megamorphic caches" show
    [ clear-megamorphic-cache ] each ;

: strip ( -- )
    startup-stripper
    strip-libc
    strip-destructors
    strip-call
    strip-cocoa
    strip-debugger
    strip-specialized-arrays
    compute-next-methods
    strip-startup-hooks
    add-command-line-hook
    strip-c-io
    strip-default-methods
    strip-compiler-classes
    f 5 set-special-object ! we can't use the Factor debugger or Factor I/O anymore
    deploy-vocab get vocab-main deploy-startup-quot
    find-megamorphic-caches
    stripped-word-props
    stripped-globals strip-globals
    compress-objects
    compress-quotations
    strip-words
    clear-megamorphic-caches ;

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
                "tools.errors" require
                "inspector" require
                deploy-ui? get [
                    "ui.debugger" require
                ] when
            ] unless
            deploy-vocab set
            deploy-vocab get require
            deploy-vocab get vocab-main [
                "Vocabulary has no MAIN: word." print flush 1 exit
            ] unless
            strip
            "Saving final image" show
            save-image-and-exit
        ] deploy-error-handler
    ] bind ;

: do-deploy ( -- )
    "output-image" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    "deploy-config" get parse-file first
    (deploy) ;

MAIN: do-deploy
