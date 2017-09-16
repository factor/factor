! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays bootstrap.image calendar cli.git
combinators concurrency.combinators formatting fry http.client
io io.directories io.launcher io.pathnames kernel math.parser
memory modern.paths namespaces parser.notes prettyprint
sequences system system-info threads tools.test vocabs
vocabs.hierarchy vocabs.hierarchy.private vocabs.loader zealot ;
IN: zealot.factor

: download-boot-checksums ( path branch -- )
    '[ _ "http://downloads.factorcode.org/images/%s/checksums.txt" sprintf download ] with-directory ;

: download-boot-image ( path branch image-name -- )
    '[ _ _ "http://downloads.factorcode.org/images/%s/%s" sprintf download ] with-directory ;

: download-my-boot-image ( path branch -- )
    my-boot-image-name download-boot-image ;

HOOK: compile-factor-command os ( -- array )
M: unix compile-factor-command ( -- array )
    { "make" "-j" } cpus number>string suffix ;
M: windows compile-factor-command ( -- array )
    { "nmake" "/f" "NMakefile" "x86-64" } ;

HOOK: factor-path os ( -- path )
M: unix factor-path "./factor" ;
M: windows factor-path "./factor.com" ;

: compile-factor ( path -- )
    [
        <process>
            compile-factor-command >>command
            "./compile-log" >>stdout
            +stdout+ >>stderr
            +new-group+ >>group
        try-process
    ] with-directory ;

: bootstrap-factor ( path -- )
    [
        <process>
            factor-path "-i=" my-boot-image-name append "-no-user-init" 3array >>command
            +closed+ >>stdin
            "./bootstrap-log" >>stdout
            +stdout+ >>stderr
            30 minutes >>timeout
            +new-group+ >>group
        try-process
    ] with-directory ;

! Meant to run in the child process
: with-child-options ( quot -- )
    f parser-quiet? set-global
    f restartable-tests? set-global
    call ; inline

: zealot-load-and-save ( vocabs path -- )
    dup "load-and-save to " prepend print flush yield
    '[
        [ load ] each _ save-image
    ] with-child-options ;

: zealot-load-basis1 ( -- ) basis-vocabs "factor.image.basis" zealot-load-and-save ;
: zealot-load-extra2 ( -- ) extra-vocabs "factor.image.extra" zealot-load-and-save ;
: zealot-load-basis ( -- ) { "roman" } "factor.image.basis" zealot-load-and-save ;
: zealot-load-extra ( -- ) { "roman" } "factor.image.extra" zealot-load-and-save ;

! like ``"" load`` -- only platform-friendly vocabs
: zealot-all-vocabs ( -- seq )
    vocab-roots get [ "" vocabs-to-load [ vocab-name ] map ] map ;

: zealot-load-all ( -- ) zealot-all-vocabs "factor.image.all" zealot-load-and-save ;

: zealot-load-command ( command log-path -- process )
    <process>
        swap >>stdout
        swap >>command
        +closed+ >>stdin
        +stdout+ >>stderr
        60 minutes >>timeout
        +new-group+ >>group ;

: zealot-load-basis-command ( -- process )
    factor-path "-e=USE: zealot.factor zealot-load-basis" 2array
    "./load-basis-log" zealot-load-command ;

: zealot-load-extra-command ( -- process )
    factor-path "-e=USE: zealot.factor zealot-load-extra" 2array
    "./load-extra-log" zealot-load-command ;

! Meant to run in the child process
: zealot-test-all ( -- )
    [ test-all ] with-child-options ;

: zealot-test-command ( command log-path -- process )
    <process>
        swap >>stdout
        swap >>command
        +closed+ >>stdin
        +stdout+ >>stderr
        60 minutes >>timeout
        +new-group+ >>group ;

: zealot-test-basis-command ( -- process )
    factor-path "-e=USE: zealot.factor zealot-test-basis" 2array
    "./test-basis" zealot-test-command ;

: zealot-test-extra-command ( -- process )
    factor-path "-e=USE: zealot.factor zealot-test-extra" 2array
    "./test-extra" zealot-test-command ;


: zealot-test-all-command ( path -- )
    [
        <process>
            factor-path "-run=\"mason.test\"" 2array >>command
            +closed+ >>stdin
            "./load-all-log" >>stdout
            +stdout+ >>stderr
            60 minutes >>timeout
            +new-group+ >>group
        try-process
    ] with-directory ;

: zealot-load-commands ( path -- )
    [
        zealot-load-basis-command
        zealot-load-extra-command 2array
        [ try-process ] parallel-each
    ] with-directory ;

: zealot-test-commands ( path -- )
    [
        f [
            [ drop zealot-test-basis-command ]
            [ drop zealot-test-extra-command ]
        ] parallel-cleave 2drop
    ] with-directory ;

: build-new-factor ( branch -- )
    [ "factor" "factor" zealot-github-clone-paths nip ] dip
    over <pathname> . flush yield
    {
        [ drop "factor" "factor" zealot-github-add-build-remote drop ]
        [ drop [ git-fetch-all* ] with-directory drop ]
        [ zealot-build-checkout-branch drop ]
        [ download-my-boot-image ]
        [ download-boot-checksums ]
        [ drop compile-factor ]
        [ drop bootstrap-factor ]
        [ "ZEALOT LOAD" print flush yield drop zealot-load-commands ]
        ! [ drop zealot-test-commands ]
    } 2cleave ;