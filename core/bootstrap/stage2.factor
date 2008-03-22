! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init command-line namespaces words debugger io
kernel.private math memory continuations kernel io.files
io.backend system parser vocabs sequences prettyprint
vocabs.loader combinators splitting source-files strings
definitions assocs compiler.errors compiler.units
math.parser generic ;
IN: bootstrap.stage2

SYMBOL: bootstrap-time

: default-image-name ( -- string )
    vm file-name windows? [ "." split1 drop ] when
    ".image" append resource-path ;

: do-crossref ( -- )
    "Cross-referencing..." print flush
    H{ } clone crossref set-global
    xref-words
    xref-generics
    xref-sources ;

: load-components ( -- )
    "exclude" "include"
    [ get-global " " split [ empty? not ] subset ] 2apply
    seq-diff
    [ "bootstrap." prepend require ] each ;

: compile-remaining ( -- )
    "Compiling remaining words..." print flush
    vocabs [ words [ compiled? not ] subset compile ] each ;

: count-words ( pred -- )
    all-words swap subset length number>string write ;

: print-report ( time -- )
    1000 /i
    60 /mod swap
    "Bootstrap completed in " write number>string write
    " minutes and " write number>string write " seconds." print

    [ compiled? ] count-words " compiled words" print
    [ symbol? ] count-words " symbol words" print
    [ ] count-words " words total" print

    "Bootstrapping is complete." print
    "Now, you can run Factor:" print
    vm write " -i=" write "output-image" get print flush ;

! Wrap everything in a catch which starts a listener so
! you can see what went wrong, instead of dealing with a
! fep

! We time bootstrap
millis >r

default-image-name "output-image" set-global

"math help handbook compiler random tools ui ui.tools io" "include" set-global
"" "exclude" set-global

parse-command-line

"-no-crossref" cli-args member? [ do-crossref ] unless

! Set dll paths
wince? [ "windows.ce" require ] when
winnt? [ "windows.nt" require ] when

"deploy-vocab" get [
    "stage2: deployment mode" print
] [
    "listener" require
    "none" require
] if

[
    load-components

    run-bootstrap-init

    "bootstrap.compiler" vocab [
        compile-remaining
    ] when
] with-compiler-errors
:errors

f error set-global
f error-continuation set-global

"deploy-vocab" get [
    "tools.deploy.shaker" run
] [
    [
        boot
        do-init-hooks
        [
            parse-command-line
            run-user-init
            "run" get run
            stdio get [ stream-flush ] when*
        ] [ print-error 1 exit ] recover
    ] set-boot-quot

    millis r> - dup bootstrap-time set-global
    print-report

    "output-image" get save-image-and-exit
] if
