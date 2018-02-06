! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry git io io.directories io.encodings.utf8
io.launcher io.streams.string kernel sequences tools.test ;
IN: git.tests

: run-process-stdout ( process -- string )
    >process utf8 [ contents ] with-process-reader ;

: with-empty-test-git-repo ( quot -- )
    '[
        { "git" "init" } run-process drop
        @
    ] with-test-directory ; inline

: with-zero-byte-file-repo ( quot -- )
    '[
        "empty-file" touch-file
        { "git" "add" "empty-file" } run-process drop
        { "git" "commit" "-m" "initial commit of empty file" } run-process drop
        @
    ] with-empty-test-git-repo ; inline

{ "hello" } [
    commit new "author" "hello\r\n"
    [ parse-commit-field ] with-string-reader
    author>>
] unit-test

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
