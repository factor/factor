! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bootstrap.image calendar cli.git
combinators combinators.short-circuit concurrency.combinators
environment formatting http.client io io.directories
io.encodings.utf8 io.launcher io.pathnames kernel math.parser
memory modern.paths namespaces parser.notes prettyprint
regexp.classes sequences sequences.extras sets splitting system
system-info threads tools.test tools.test.private vocabs
vocabs.hierarchy vocabs.hierarchy.private vocabs.loader
vocabs.metadata zealot ;
IN: zealot.factor

! XXX: Could check if it's a branch instead with a git command
: git-checksum? ( str -- ? )
    { [ length 40 = ] [ [ hex-digit? ] all? ] } 1&& ;

: download-boot-checksum-branch ( path branch -- )
    '[ _ "https://downloads.factorcode.org/images/%s/checksums.txt" sprintf download ] with-directory ;

: download-boot-checksum-git-checksum ( path checksum -- )
    '[ _ "https://downloads.factorcode.org/images/build/checksums.txt.%s" sprintf download ] with-directory ;

: download-boot-checksums ( path branch/checksum -- )
    dup git-checksum?
    [ download-boot-checksum-git-checksum ]
    [ download-boot-checksum-branch ] if ;

: download-boot-image ( path url -- )
    '[ _ my-arch-name "boot.%s.image" sprintf download-to ] with-directory ;

: arch-git-boot-image-path ( arch git-id -- str )
    "https://downloads.factorcode.org/images/build/boot.%s.image.%s" sprintf ;

: download-my-boot-image ( path branch/checksum -- )
    dup git-checksum?
    [ [ my-arch-name ] dip arch-git-boot-image-path ]
    [ my-boot-image-name "https://downloads.factorcode.org/images/%s/%s" sprintf ] if
    download-boot-image ;

HOOK: compile-factor-command os ( -- array )
M: macosx compile-factor-command ( -- array )
    { "arch" "-x86_64" "make" "-j" } cpus number>string suffix ;
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
            factor-path "-i=" my-boot-image-name append "-no-user-init" 3array
            os macosx = [ { "arch" "-x86_64" } prepend ] when
                >>command
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
    f long-unit-tests-enabled? set-global
    call ; inline

: zealot-load-and-save ( vocabs path -- )
    dup "load-and-save to " prepend print flush yield
    '[
        [ load ] each _ save-image
    ] with-child-options ;

: zealot-load-basis ( -- ) basis-vocabs "factor.image.basis" zealot-load-and-save ;
: zealot-load-extra ( -- ) extra-vocabs "factor.image.extra" zealot-load-and-save ;

! like ``"" load`` -- only platform-friendly vocabs
: zealot-vocabs-from-root ( root -- seq ) "" vocabs-to-load [ vocab-name ] map ;
: zealot-all-vocabs ( -- seq ) vocab-roots get [ zealot-vocabs-from-root ] map-concat ;
: zealot-core-vocabs ( -- seq ) "resource:core" zealot-vocabs-from-root ;
: zealot-basis-vocabs ( -- seq ) "resource:basis" zealot-vocabs-from-root ;
: zealot-extra-vocabs ( -- seq ) "resource:extra" zealot-vocabs-from-root ;

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

: zealot-load-commands ( path -- )
    [
        zealot-load-basis-command
        zealot-load-extra-command 2array
        [ try-process ] parallel-each
    ] with-directory ;

: zealot-test-command ( command log-path -- process )
    <process>
        swap >>stdout
        swap >>command
        +closed+ >>stdin
        +stdout+ >>stderr
        60 minutes >>timeout
        +new-group+ >>group ;

: zealot-load-and-test ( vocabs -- )
    '[
        _ [ [ load ] each ] [ test-vocabs ] bi
    ] with-child-options ;

: load-and-test-command ( i -- command )
    [
        factor-path
        "-i=factor.image"
    ] dip
    [
        "-e=USING: zealot.factor tools.test grouping.extras formatting ; [ %d all-zealot-vocabs 32 n-groups nth zealot-load-and-test ] with-child-options"
        sprintf 3array
    ] [ "./test-%d-log" sprintf ] bi

    <process>
        swap >>stdout
        swap >>command
        +closed+ >>stdin
        +stdout+ >>stderr
        60 minutes >>timeout
        +new-group+ >>group ;

: zealot-test-commands ( path -- )
    [
        32 <iota> [
            load-and-test-command
        ] map [ try-process ] parallel-each
    ] with-directory ;

: zealot-test-commands-old ( path -- )
    [
        factor-path "-i=factor.image" "-e=USE: zealot.factor USE: tools.test [ zealot-core-vocabs test-vocabs ] with-child-options" 3array
        "./test-core-log" zealot-test-command

        factor-path "-i=factor.image.basis" "-e=USE: zealot.factor USE: tools.test [ zealot-basis-vocabs test-vocabs ] with-child-options" 3array
        "./test-basis-log" zealot-test-command

        factor-path "-i=factor.image.extra" "-e=USE: zealot.factor USE: tools.test [ zealot-extra-vocabs test-vocabs ] with-child-options" 3array
        "./test-extra-log" zealot-test-command 3array

        [ try-process ] parallel-each
    ] with-directory ;

: checkout-new-factor ( branch/checksum -- path branch/checksum )
    "factor" "factor" zealot-github-ensure drop

    [ "factor" "factor" zealot-github-clone-paths nip ] dip
    over <pathname> . flush yield
    {
        [ drop "factor" "factor" zealot-github-add-build-remote drop ]
        [ drop [ git-fetch-all* ] with-directory drop ]
        [ zealot-build-checkout drop ]
        [ ]
    } 2cleave ;

: bootstrap-new-factor ( path branch/checksum -- path branch/checksum )
    {
        [ "ZEALOT DOWNLOADING BOOT IMAGE" print flush download-my-boot-image ]
        [ "ZEALOT DOWNLOADING CHECKSUMS" print flush download-boot-checksums ]
        [ "ZEALOT COMPILING" print flush drop compile-factor ]
        [ "ZEALOT BOOTSTRAPPING" print flush drop bootstrap-factor ]
        [ ]
    } 2cleave ;

: test-new-factor ( path branch/checksum -- )
    {
        [ "ZEALOT LOADING ROOTS" print flush drop zealot-load-commands ]
        [ "ZEALOT TESTING ROOTS" print flush drop zealot-test-commands ]
    } 2cleave ;

: check-new-factor ( path branch/checksum cmd -- out )
    nip [ factor-path "-i=factor.image" ] dip "-e=%s" sprintf 3array
    "./test-bisect-log" zealot-test-command
    '[ _ process-contents ] with-directory ;

: build-new-factor ( branch/checksum -- )
    checkout-new-factor bootstrap-new-factor test-new-factor ;

: bisect-new-factor ( branch/checksum cmd -- out )
    [ checkout-new-factor bootstrap-new-factor ] dip check-new-factor ;

: factor-clean-branch ( -- str )
    os cpu [ name>> ] bi@ { { CHAR: . CHAR: - } } substitute
    "-" glue "origin/clean-" prepend ;

: vocab-path>vocab ( path -- vocab )
    [ parent-directory ] map
    [ "/" split1 nip ] map
    [ path-separator split harvest "." join ] map ;

: changed-factor-vocabs ( old-rev new-rev -- vocabs )
    [
        default-vocab-roots
        [ ":" split1 nip ] map
        [ "/" append ] map
    ] 2dip git-diff-name-only*
    [ ".factor" tail? ] filter
    [ swap [ head? ] with any? ] with filter
    [ parent-directory ] map
    [ "/" split1 nip ] map
    [ path-separator split harvest "." join ] map members ;

: changed-factor-vocabs-from-master ( -- vocabs )
    "HEAD" "origin/master" changed-factor-vocabs ;

: changed-factor-vocabs-from-clean ( -- vocabs )
    "HEAD" factor-clean-branch changed-factor-vocabs ;

: testing-a-branch? ( -- ? )
    "CI_BRANCH" os-env "master" or
    "master" = not ;

: reject-unloadable-vocabs ( vocabs -- vocabs' )
    [ don't-load? ] reject ;

! Test changes from a CI_BRANCH against origin/master
! Test master against last clean build, e.g. origin/clean-linux-x86-64
: ci-vocabs-to-test ( -- vocabs )
    testing-a-branch? [
        changed-factor-vocabs-from-master
    ] [
        changed-factor-vocabs-from-clean
    ] if reject-unloadable-vocabs ;
