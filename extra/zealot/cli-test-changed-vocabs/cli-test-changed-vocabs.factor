! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel sequences tools.test.private vocabs zealot.factor ;
IN: zealot.cli-test-changed-vocabs

: zealot-test-changed-vocabs ( -- )
    ci-vocabs-to-test [ [ require ] [ test-vocab ] bi ] each ;

MAIN: zealot-test-changed-vocabs

