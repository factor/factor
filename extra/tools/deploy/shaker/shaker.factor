! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: qualified io.streams.c init fry namespaces assocs kernel
parser tools.deploy.config vocabs sequences words words.private
memory kernel.private continuations io prettyprint
vocabs.loader debugger system strings ;
QUALIFIED: bootstrap.stage2
QUALIFIED: classes
QUALIFIED: compiler.errors.private
QUALIFIED: compiler.units
QUALIFIED: continuations
QUALIFIED: definitions
QUALIFIED: init
QUALIFIED: inspector
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

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
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
    [ f over set-word-name f swap set-word-vocabulary ] each ;

: strip-word-defs ( words -- )
    "Stripping symbolic word definitions" show
    [ [ ] swap set-word-def ] each ;

: strip-word-props ( retain-props words -- )
    "Stripping word properties" show
    [
        [
            word-props swap
            '[ , nip member? ] assoc-subset
            f assoc-like
        ] keep set-word-props
    ] with each ;

: retained-props ( -- seq )
    [
        "class" ,
        "metaclass" ,
        "layout" ,
        deploy-ui? get [
            "gestures" ,
            "commands" ,
            { "+nullary+" "+listener+" "+description+" }
            [ "ui.commands" lookup , ] each
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
    [ child-vocabs [ words ] map concat ] map concat seq-diff ;

: stripped-globals ( -- seq )
    [
        {
            bootstrap.stage2:bootstrap-time
            continuations:error
            continuations:error-continuation
            continuations:error-thread
            continuations:restarts
            error-hook
            init:init-hooks
            inspector:inspector-hook
            io.thread:io-thread
            libc.private:mallocs
            source-files:source-files
            stderr
            stdio
        } %

        deploy-threads? [
            threads:initial-thread ,
        ] unless

        strip-io? [ io.backend:io-backend , ] when

        [
            io.backend:io-backend ,
            "default-buffer-size" "io.nonblocking" lookup ,
        ] { } make
        { "alarms" "io" "tools" } strip-vocab-globals %

        strip-dictionary? [
            { } { "cpu" } strip-vocab-globals %

            {
                classes:class-and-cache
                classes:class-not-cache
                classes:class-or-cache
                classes:class<-cache
                classes:classes-intersect-cache
                classes:update-map
                compiled-crossref
                compiler.units:recompile-hook
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
    ] { } make ;

: strip-globals ( stripped-globals -- )
    strip-globals? [
        "Stripping globals" show
        global swap
        '[ drop , member? not ] assoc-subset
        [ drop string? not ] assoc-subset ! strip CLI args
        dup keys unparse show
        21 setenv
    ] [ drop ] if ;

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
    retained-props >r
    stripped-globals strip-globals
    r> strip-words ;

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
