! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors qualified io.streams.c init fry namespaces
assocs kernel parser lexer strings.parser tools.deploy.config
vocabs sequences words words.private memory kernel.private
continuations io prettyprint vocabs.loader debugger system
strings sets vectors quotations byte-arrays ;
QUALIFIED: bootstrap.stage2
QUALIFIED: classes
QUALIFIED: command-line
QUALIFIED: compiler.errors.private
QUALIFIED: compiler.units
QUALIFIED: continuations
QUALIFIED: definitions
QUALIFIED: init
QUALIFIED: io.backend
QUALIFIED: io.thread
QUALIFIED: layouts
QUALIFIED: libc.private
QUALIFIED: libc.private
QUALIFIED: listener
QUALIFIED: prettyprint.config
QUALIFIED: source-files
QUALIFIED: threads
QUALIFIED: vocabs
IN: tools.deploy.shaker

! This file is some hairy shit.

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
    "cpu.x86" init-hooks get delete-at
    "command-line" init-hooks get delete-at
    "libc" init-hooks get delete-at
    deploy-threads? get [
        "threads" init-hooks get delete-at
    ] unless
    native-io? [
        "io.thread" init-hooks get delete-at
    ] unless
    strip-io? [
        "io.backend" init-hooks get delete-at
    ] when ;

: strip-debugger ( -- )
    strip-debugger? [
        "Stripping debugger" show
        "resource:extra/tools/deploy/shaker/strip-debugger.factor"
        run-file
    ] when ;

: strip-libc ( -- )
    "libc" vocab [
        "Stripping manual memory management debug code" show
        "resource:extra/tools/deploy/shaker/strip-libc.factor"
        run-file
    ] when ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "resource:extra/tools/deploy/shaker/strip-cocoa.factor"
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
        [
            props>> swap
            '[ drop , member? not ] assoc-filter sift-assoc
            dup assoc-empty? [ drop f ] [ >alist >vector ] if
        ] keep (>>props)
    ] with each ;

: stripped-word-props ( -- seq )
    [
        strip-dictionary? [
            {
                "coercer"
                "compiled-effect"
                "compiled-uses"
                "constraints"
                "declared-effect"
                "default"
                "default-method"
                "default-output-classes"
                "derived-from"
                "identities"
                "if-intrinsics"
                "infer"
                "inferred-effect"
                "interval"
                "intrinsics"
                "loc"
                "members"
                "methods"
                "method-class"
                "method-generic"
                "combination"
                "cannot-infer"
                "no-compile"
                "optimizer-hooks"
                "output-classes"
                "participants"
                "predicate"
                "predicate-definition"
                "predicating"
                "tuple-dispatch-generic"
                "slots"
                "slot-names"
                "specializer"
                "step-into"
                "step-into?"
                "superclass"
                "reading"
                "writing"
                "type"
                "engines"
            } %
        ] when
        
        strip-prettyprint? [
            {
                "break-before"
                "break-after"
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

: strip-recompile-hook ( -- )
    [ [ f ] { } map>assoc ]
    compiler.units:recompile-hook
    set-global ;

: strip-vocab-globals ( except names -- words )
    [ child-vocabs [ words ] map concat ] map concat swap diff ;

: stripped-globals ( -- seq )
    [
        "callbacks" "alien.compiler" lookup ,

        "inspector-hook" "inspector" lookup ,

        {
            bootstrap.stage2:bootstrap-time
            continuations:error
            continuations:error-continuation
            continuations:error-thread
            continuations:restarts
            listener:error-hook
            init:init-hooks
            io.thread:io-thread
            libc.private:mallocs
            source-files:source-files
            input-stream
            output-stream
            error-stream
        } %

        deploy-threads? [
            threads:initial-thread ,
        ] unless

        strip-io? [ io.backend:io-backend , ] when

        { } {
            "alarms"
            "tools"
            "io.launcher"
        } strip-vocab-globals %

        strip-dictionary? [
            { } { "cpu" } strip-vocab-globals %

            {
                gensym
                name>char-hook
                classes:class-and-cache
                classes:class-not-cache
                classes:class-or-cache
                classes:class<=-cache
                classes:classes-intersect-cache
                classes:implementors-map
                classes:update-map
                command-line:main-vocab-hook
                compiled-crossref
                compiler.units:recompile-hook
                compiler.units:update-tuples-hook
                definitions:crossref
                interactive-vocabs
                layouts:num-tags
                layouts:num-types
                layouts:tag-mask
                layouts:tag-numbers
                layouts:type-numbers
                lexer-factory
                listener:listener-hook
                root-cache
                vocab-roots
                vocabs:dictionary
                vocabs:load-vocab-hook
                word
            } %

            { } { "optimizer.math.partial" } strip-vocab-globals %
        ] when

        strip-prettyprint? [
            {
                prettyprint.config:margin
                prettyprint.config:string-limit
                prettyprint.config:tab-size
            } %
        ] when

        strip-debugger? [
            {
                compiler.errors.private:compiler-errors
                continuations:thread-error-hook
            } %
        ] when

        deploy-c-types? get [
            "c-types" "alien.c-types" lookup ,
        ] unless

        deploy-ui? get [
            "ui-error-hook" "ui.gadgets.worlds" lookup ,
        ] when

        "<computer>" "inference.dataflow" lookup [ , ] when*

        "windows-messages" "windows.messages" lookup [ , ] when*

    ] { } make ;

: strip-globals ( stripped-globals -- )
    strip-globals? [
        "Stripping globals" show
        global swap
        '[ drop , member? not ] assoc-filter
        [ drop string? not ] assoc-filter ! strip CLI args
        sift-assoc
        dup keys unparse show
        21 setenv
    ] [ drop ] if ;

: compress ( pred string -- )
    "Compressing " prepend show
    instances
    dup H{ } clone [ [ ] cache ] curry map
    become ; inline

: compress-byte-arrays ( -- )
    [ byte-array? ] "byte arrays" compress ;

: compress-quotations ( -- )
    [ quotation? ] "quotations" compress ;

: compress-strings ( -- )
    [ string? ] "strings" compress ;

: finish-deploy ( final-image -- )
    "Finishing up" show
    >r { } set-datastack r>
    { } set-retainstack
    V{ } set-namestack
    V{ } set-catchstack
    "Saving final image" show
    [ save-image-and-exit ] call-clear ;

SYMBOL: deploy-vocab

: set-boot-quot* ( word -- )
    [
        \ boot ,
        init-hooks get values concat %
        ,
        strip-io? [ \ flush , ] unless
    ] [ ] make "Boot quotation: " write dup . flush
    set-boot-quot ;

: strip ( -- )
    strip-libc
    strip-cocoa
    strip-debugger
    strip-recompile-hook
    strip-init-hooks
    deploy-vocab get vocab-main set-boot-quot*
    stripped-word-props >r
    stripped-globals strip-globals
    r> strip-words
    compress-byte-arrays
    compress-quotations
    compress-strings ;

: (deploy) ( final-image vocab config -- )
    #! Does the actual work of a deployment in the slave
    #! stage2 image
    [
        [
            deploy-vocab set
            deploy-vocab get require
            strip
            finish-deploy
        ] [
            print-error flush 1 exit
        ] recover
    ] bind ;

: do-deploy ( -- )
    "output-image" get
    "deploy-vocab" get
    "Deploying " write dup write "..." print
    dup deploy-config dup .
    (deploy) ;

MAIN: do-deploy
