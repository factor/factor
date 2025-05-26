! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io sequences zealot.factor ;
IN: zealot.cli-changed-vocabs

: zealot-changed-vocabs ( -- ) ci-vocabs-to-test write-lines ;

MAIN: zealot-changed-vocabs

