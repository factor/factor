! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: fry git io io.directories io.encodings.utf8 io.files.temp
io.files.unique io.launcher kernel sequences tools.test ;
IN: git.tests

: run-process-stdout ( process -- string )
    >process utf8 [ contents ] with-process-reader ;

: with-empty-test-git-repo ( quot -- )
    '[
        [
            { "git" "init" } run-process drop
            @
        ] cleanup-unique-directory
    ] with-temp-directory ; inline

: with-zero-byte-file-repo ( quot -- )
    '[
        "empty-file" touch-file
        { "git" "add" "empty-file" } run-process drop
        { "git" "commit" "-m" "initial commit of empty file" } run-process drop
        @
    ] with-empty-test-git-repo ; inline

{ "refs/heads/master" } [
    [ git-head-ref ] with-empty-test-git-repo
] unit-test


{ } [
    [
        ! "." t recursive-directory-files
        git-log [ commit. ] each
    ] with-zero-byte-file-repo
] unit-test

{ } [
    [
        { "git" "log" } run-process-stdout print
    ] with-zero-byte-file-repo
] unit-test
