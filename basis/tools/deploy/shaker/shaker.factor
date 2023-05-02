! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.libraries arrays assocs byte-arrays
classes classes.builtin classes.private combinators
combinators.private command-line compiler.crossref
compiler.errors compiler.units continuations definitions generic
generic.single generic.standard grouping hashtables init io
io.backend io.encodings.utf8 io.files io.pathnames io.streams.c
kernel kernel.private make math memoize memory namespaces parser
parser.notes quotations sequences sequences.deep
sequences.private sets slots.private source-files
source-files.errors strings strings.parser system
tools.deploy.config vocabs vocabs.loader vocabs.loader.private
vocabs.parser words ;
QUALIFIED: classes.private
IN: tools.deploy.shaker

! This file is some hairy shit.

: add-command-line-hook ( -- )
    [
        (command-line) rest
        command-line set-global
    ] "command-line" startup-hooks get set-at ;

: set-stop-after-last-window? ( -- )
    get-namestack [ "stop-after-last-window?" swap key? ] any? [
        "ui-stop-after-last-window?" "ui.backend" lookup-word [
            "stop-after-last-window?" get swap set-global
        ] when*
    ] when ;

: strip-startup-hooks ( -- )
    "Stripping startup hooks" show
    {
        "alien.strings"
        "cpu.x86.features"
        "environment"
    }
    [ startup-hooks get delete-at ] each
    deploy-threads? get [
        "threads" startup-hooks get delete-at
    ] unless
    strip-io? [
        "io.backend" startup-hooks get delete-at
    ] when
    strip-dictionary? [
        {
            "compiler.units"
            "source-files.errors"
            "vocabs"
            "vocabs.cache"
        } [ startup-hooks get delete-at ] each
    ] when ;

: strip-debugger ( -- )
    strip-debugger? "debugger" lookup-vocab and [
        "Stripping debugger" show
        "vocab:tools/deploy/shaker/strip-debugger.factor"
        run-file
    ] when ;

: strip-ui-error-hook ( -- )
    strip-debugger? deploy-ui? get and "ui" lookup-vocab and [
        "Installing generic UI error hook" show
        "vocab:tools/deploy/shaker/strip-ui-error-hook.factor"
        run-file
    ] when ;

: strip-libc ( -- )
    "libc" lookup-vocab [
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
    "cocoa" lookup-vocab [
        "Stripping unused Cocoa methods" show
        "vocab:tools/deploy/shaker/strip-cocoa.factor"
        run-file
    ] when ;

: strip-gobject ( -- )
    "gobject-introspection.types" lookup-vocab [
        "Stripping GObject type info" show
        "vocab:tools/deploy/shaker/strip-gobject.factor"
        run-file
    ] when ;

: strip-gtk-icon ( -- )
    "ui.backend.gtk2" lookup-vocab [
        "Stripping GTK icon loading code" show
        "vocab:tools/deploy/shaker/strip-gtk-icon.factor"
        run-file
    ] when ;

: strip-specialized-arrays ( -- )
    strip-dictionary? "specialized-arrays" lookup-vocab and [
        "Stripping specialized arrays" show
        "vocab:tools/deploy/shaker/strip-specialized-arrays.factor"
        run-file
    ] when ;

: strip-word-names ( words -- )
    "Stripping word names" show
    [ f >>name f >>vocabulary drop ] each ;

: strip-word-defs ( words -- )
    "Stripping symbolic word definitions" show
    [ [ ] >>def drop ] each ;

: strip-word-props ( stripped-props words -- )
    "Stripping word properties" show
    swap '[
        [
            [ drop _ member? ] assoc-reject sift-values
            >alist f like
        ] change-props drop
    ] each ;

: stripped-word-props ( -- seq )
    [
        strip-dictionary? [
            {
                "alias"
                "boa-check"
                "coercer"
                "combination"
                "constant"
                "constraints"
                "custom-inlining"
                "decision-tree"
                "declared-effect"
                "default"
                "default-method"
                "default-output-classes"
                "dependencies"
                "dependency-checks"
                "derived-from"
                "ebnf-parser"
                "engines"
                "forgotten"

                "generic-call-sites"

                "help"
                "help-loc"
                "help-parent"

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
                "method-class"
                "method-generic"
                "methods"
                "modular-arithmetic"
                "no-compile"
                "owner-generic"
                "outputs"
                "participants"
                "predicate"
                "predicate-definition"
                "predicating"

                "reader"
                "reading"
                "recursive"
                "register"
                "register-size"
                "related"

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

: strip-memoized ( -- )
    "Clearing memoized word caches" show
    [ memoized? ] instances [ reset-memoized ] each ;

: compiler-classes ( -- set )
    { "compiler" "stack-checker" } [
        loaded-child-vocab-names
        [ vocab-words ] map concat
        [ class? ] filter
    ] map concat fast-set ;

: prune-decision-tree ( tree classes -- )
    [ tuple class>type ] 2dip '[
        dup array? [
            [
                dup array? [
                    [
                        2 group
                        [ drop _ in? ] assoc-reject
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
            { [ 2over eq? ] [ 2nip ] }
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
    [ [ "No method" throw ] ( -- * ) define-temp ] with-compilation-unit ;

: strip-default-methods ( -- )
    ! In a development image, each generic has its own default method.
    ! This gives better error messages for runtime type errors, but
    ! takes up space. For deployment we merge them all together.
    strip-debugger? [
        "Stripping default methods" show
        [ single-generic? ] instances
        new-default-method '[ _ strip-default-method ] each
    ] when ;

: vocab-tree-globals ( except names -- words )
    [ loaded-child-vocab-names [ vocab-words ] map concat ] map concat
    swap [ first2 lookup-word ] map sift diff ;

: stripped-globals ( -- seq )
    [
        "inspector-hook" "inspector" lookup-word ,
        {
            source-files:source-files
            continuations:error
            continuations:error-continuation
            continuations:error-thread
            continuations:restarts
        } %

        "disposables" "destructors" lookup-word ,

        "functor-words" "functors.backend" lookup-word ,

        { } {
            "stack-checker"
            "listener"
            "bootstrap"
        } vocab-tree-globals %

        ! Don't want to strip globals from test programs
        { } { "tools" } vocab-tree-globals
        { } { "tools.deploy.test" } vocab-tree-globals diff %

        deploy-unicode? get [
            { } { "unicode" } vocab-tree-globals %
        ] unless

        strip-dictionary? [
            "libraries" "alien" lookup-word ,

            { { "yield-hook" "compiler.utilities" } }
            { "cpu" "compiler" } vocab-tree-globals %

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
                print-use-hook
                root-cache
                require-when-vocabs
                require-when-table
                source-files.errors:error-types
                source-files.errors:error-observers
                vocabs:dictionary
                vocabs:require-hook
                vocabs:vocab-observers
                vocabs.loader:add-vocab-root-hook
                vocabs.parser:manifest
                word
                parser-quiet?
            } %

            { } { "layouts" } vocab-tree-globals %

            { } { "math.partial-dispatch" } vocab-tree-globals %

            { } { "math.vectors.simd" } vocab-tree-globals %

            { } { "peg" } vocab-tree-globals %
        ] when

        strip-prettyprint? [
            { } { "prettyprint.config" } vocab-tree-globals %
        ] when

        strip-debugger? [
            \ compiler.errors:compiler-errors ,
        ] when
    ] { } make ;

: cleared-globals ( -- seq )
    [

        {
            init:startup-hooks
            input-stream
            output-stream
            error-stream
            vm-path
            image-path
            current-directory
        } %

        "io-thread" "io.thread" lookup-word ,

        deploy-threads? [
            "initial-thread" "threads" lookup-word ,
        ] unless

        strip-io? [ io-backend , ] when

        { } {
            "timers"
            "io.launcher"
            "random"
        } vocab-tree-globals %

        "windows-messages" "windows.messages" lookup-word [ , ] when*
    ] { } make ;

: strip-global? ( name stripped-globals -- ? )
    '[ _ member? ] [ tuple? ] bi or ;

: clear-global? ( name cleared-globals -- ? )
    '[ _ member? ] [ string? ] bi or ;

: strip-globals ( -- )
    strip-globals? [| |
        "Stripping globals" show
        stripped-globals :> to-strip
        cleared-globals :> to-clear
        global boxes>>
        [ drop to-strip strip-global? ] assoc-reject!
        [
            [
                swap to-clear clear-global?
                [ f swap value<< ] [ drop ] if
            ] assoc-each
        ] [ rehash ] bi
    ] when ;

: strip-c-io ( -- )
    ! On all platforms, if deploy-io is 1, we strip out C streams.
    ! On Unix, if deploy-io is 3, we strip out C streams as well.
    ! On Windows, even if deploy-io is 3, C streams are still used
    ! for the console, so don't strip it there.
    strip-io?
    native-io? os windows? not and
    or [
        "Stripping C I/O" show
        "vocab:tools/deploy/shaker/strip-c-io.factor" run-file
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
        2dup [ quotation-compiled? ] [ quotation-compiled? not ] bi* and
        [ nip jit-compile ] [ 2drop ] if
    ] 2each ;

: compress-quotations ( -- )
    [ quotation? ] [ remain-compiled ] "quotations" compress
    [ quotation? ] instances [ f >>cached-effect f >>cache-counter drop ] each ;

SYMBOL: deploy-vocab

: [:c] ( -- word ) ":c" "debugger" lookup-word ;

: [print-error] ( -- word ) "print-error" "debugger" lookup-word ;

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
    t parser-quiet? set-global
    f output-stream set-global
    [ V{ "resource:" } clone vocab-roots set-global ]
    "vocabs.loader" startup-hooks get-global set-at ;

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

: write-vocab-manifest ( vocab-manifest-out -- )
    "Writing vocabulary manifest to " write dup print flush
    loaded-vocab-names "VOCABS:" prefix
    deploy-libraries get [ lookup-library path>> ] map members
    "LIBRARIES:" prefix append
    swap utf8 set-file-lines ;

: prepare-deploy-libraries ( -- )
    "Preparing deployed libraries" show
    deploy-libraries get [
        libraries get [
            [ path>> >deployed-library-path ] [ abi>> ] bi make-library
        ] change-at
    ] each

    [
        "deploy-libraries" "alien.libraries" lookup-word forget
        "deploy-library" "alien.libraries" lookup-word forget
        ">deployed-library-path" "alien.libraries.private" lookup-word forget
    ] with-compilation-unit ;

: strip ( vocab-manifest-out -- )
    [ write-vocab-manifest ] when*
    startup-stripper
    prepare-deploy-libraries
    strip-libc
    strip-destructors
    strip-call
    strip-cocoa
    strip-gobject
    strip-gtk-icon
    strip-debugger
    strip-ui-error-hook
    strip-specialized-arrays
    compute-next-methods
    strip-startup-hooks
    add-command-line-hook
    strip-c-io
    strip-default-methods
    strip-compiler-classes
    ! we can't use the Factor debugger or Factor I/O anymore
    f ERROR-HANDLER-QUOT set-special-object
    deploy-vocab get vocab-main deploy-startup-quot
    find-megamorphic-caches
    stripped-word-props
    strip-globals
    compress-objects
    compress-quotations
    strip-words
    strip-memoized
    clear-megamorphic-caches ;

: die-with ( error original-error -- * )
    ! We don't want DCE to drop the error before the die call!
    [ die 1 exit ] ( a -- * ) call-effect-unsafe ;

: die-with2 ( error original-error -- * )
    ! We don't want DCE to drop the error before the die call!
    [ die 1 exit ] ( a b -- * ) call-effect-unsafe ;

: deploy-error-handler ( quot -- )
    [
        strip-debugger?
        [ original-error get die-with2 ]
        ! Don't reference these words literally, if we're stripping the
        ! debugger out we don't want to load the prettyprinter at all
        [ [:c] execute( -- ) nl [print-error] execute( error -- ) flush ] if
        1 exit
    ] recover ; inline

: (deploy) ( final-image vocab-manifest-out vocab config -- )
    ! Does the actual work of a deployment in the slave
    ! stage2 image
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
            [ deploy-vocab namespaces:set ] [ require ] [
                vocab-main [
                    "Vocabulary has no MAIN: word." print flush 1 exit
                ] unless
            ] tri
            set-stop-after-last-window?
            strip
            "Saving final image" show
            save-image-and-exit
        ] deploy-error-handler
    ] with-variables ;

: do-deploy ( -- )
    "output-image" get
    "vocab-manifest-out" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    "deploy-config" get parse-file first
    (deploy) ;

MAIN: do-deploy
