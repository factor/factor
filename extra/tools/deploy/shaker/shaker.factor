! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations words.private tools.deploy.config ;
IN: tools.deploy.shaker

: show ( msg -- )
    #! Use primitives directly so that we can print stuff even
    #! after most of the image has been stripped away
    "\r\n" append stdout fwrite stdout fflush ;

: strip-init-hooks ( -- )
    "Stripping startup hooks" show
    "command-line" init-hooks get delete-at ;

: strip-debugger ( -- )
    strip-debugger? get [
        "Stripping debugger" show
        "resource:extra/tools/deploy/strip-debugger.factor"
        run-file
    ] when ;

: strip-cocoa ( -- )
    "cocoa" vocab [
        "Stripping unused Cocoa methods" show
        "resource:extra/tools/deploy/strip-cocoa.factor"
        run-file
    ] when ;

: strip-assoc ( retained-keys assoc -- newassoc )
    swap [ nip member? ] curry assoc-subset ;

: strip-word-names ( words -- )
    "Stripping word names" show
    [ f over set-word-name f swap set-word-vocabulary ] each ;

: strip-word-defs ( words -- )
    "Stripping unoptimized definitions from optimized words" show
    [ compiled? ] subset [ [ ] swap set-word-def ] each ;

: strip-word-props ( retain-props words -- )
    "Stripping word properties" show
    [
        [ word-props strip-assoc f assoc-like ] keep
        set-word-props
    ] curry* each ;

: retained-props ( -- seq )
    [
        "class" ,
        "metaclass" ,
        "slot-names" ,
        deploy-ui? get [
            "gestures" ,
            "commands" ,
            { "+nullary+" "+listener+" "+description+" }
            [ "ui.commands" lookup , ] each
        ] when
    ] { } make ;

: strip-words ( props -- )
    [ word? ] instances
    strip-word-props? get [ tuck strip-word-props ] [ nip ] if
    strip-word-names? get [ dup strip-word-names ] when
    strip-word-defs ;

USING: bit-arrays byte-arrays io.streams.nested ;

: strip-classes ( -- )
    "Stripping classes" show
    io-backend get [
        c-reader forget
        c-writer forget
    ] when
    { style-stream mirror enum } [ forget ] each ;

: strip-environment ( retain-globals -- )
    "Stripping environment" show
    strip-globals? get [
        global strip-assoc 21 setenv
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
        "io.backend" init-hooks get at [ \ flush , ] when
    ] [ ] make "Boot quotation: " write dup . flush
    set-boot-quot ;

: retained-globals ( -- seq )
    [
        builtins ,
        io-backend ,

        strip-dictionary? get [
            {
                builtins
                dictionary
                inspector-hook
                lexer-factory
                load-vocab-hook
                num-tags
                num-types
                tag-bits
                tag-mask
                tag-numbers
                typemap
                vocab-roots
            } %
        ] unless

        strip-prettyprint? get [
            {
                tab-size
                margin
            } %
        ] unless

        strip-c-types? get not deploy-ui? get or [
            "c-types" "alien.c-types" lookup ,
        ] when

        deploy-ui? get [
            "ui" child-vocabs
            "cocoa" child-vocabs
            deploy-vocab get child-vocabs 3append
            global keys [ word? ] subset
            swap [ >r word-vocabulary r> member? ] curry
            subset %
        ] when
    ] { } make dup . ;

: normalize-strip-flags
    strip-prettyprint? get [
        strip-word-names? off
    ] unless
    strip-dictionary? get [
        strip-prettyprint? off
        strip-word-names? off
        strip-word-props? off
    ] unless ;

: strip ( -- )
    normalize-strip-flags
    strip-cocoa
    strip-debugger
    strip-init-hooks
    deploy-vocab get vocab-main set-boot-quot*
    retained-props >r
    retained-globals strip-environment
    r> strip-words ;

: (deploy) ( final-image vocab config -- )
    #! Does the actual work of a deployment in the slave
    #! stage2 image
    [
        [
            deploy-vocab set
            parse-hook get >r
            parse-hook off
            deploy-vocab get require
            r> [ call ] when*
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
