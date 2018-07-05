! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences tools.test vocabs zealot.factor ;
IN: zealot.cli-test-changed-vocabs

: zealot-test-changed-vocabs ( -- )
    ci-vocabs-to-test [
        [ require ] each
    ] [
        [ test ] each
    ] bi ;

MAIN: zealot-test-changed-vocabs