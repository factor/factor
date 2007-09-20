! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init command-line namespaces words debugger io
kernel.private math memory continuations kernel io.files
io.backend system parser vocabs sequences prettyprint
vocabs.loader combinators splitting source-files strings
definitions assocs ;
IN: bootstrap.stage2

! Wrap everything in a catch which starts a listener so
! you can see what went wrong, instead of dealing with a
! fep
[
    vm file-name windows? [ >lower ".exe" ?tail drop ] when
    ".image" append "output-image" set-global

    "math compiler tools help ui ui.tools io" "include" set-global
    "" "exclude" set-global

    parse-command-line

    "Cross-referencing..." print flush
    H{ } clone changed-words set-global
    H{ } clone crossref set-global
    xref-words
    xref-sources

    ! Set dll paths
    wince? [ "windows.ce" require ] when
    winnt? [ "windows.nt" require ] when

    [
        ! Compile everything if compiler is loaded
        all-words [ changed-word ] each

        "exclude" "include"
        [ get-global " " split [ empty? not ] subset ] 2apply
        seq-diff
        [ "bootstrap." swap append require ] each
    ] no-parse-hook

    init-io
    init-stdio

    changed-words get clear-assoc

    "compile-errors" "generator" lookup [
        f swap set-global
    ] when*

    run-bootstrap-init

    f error set-global
    f error-continuation set-global

    "deploy-vocab" get [
        "tools.deploy" run
    ] [
        "listener" require
        "none" require

        [
            boot
            do-init-hooks
            [ parse-command-line ] try
            [ run-user-init ] try
            [ "run" get run ] try
            stdio get [ stream-flush ] when*
        ] set-boot-quot

        : count-words all-words swap subset length pprint ;
    
        [ compiled? ] count-words " compiled words" print
        [ symbol? ] count-words " symbol words" print
        [ ] count-words " words total" print

        "Bootstrapping is complete." print
        "Now, you can run ./factor -i=" write
        "output-image" get print flush

        "output-image" get resource-path save-image-and-exit
    ] if
] [ error-hook get call "listener" run ] recover
