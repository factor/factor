! Copyright (C) 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations concurrency.mailboxes
concurrency.messaging kernel system threads ;
IN: tools.deploy.test.22

: linked-error-test ( -- )
    [ "Linked" throw ] "Test" spawn-linked drop
    [ receive drop 1 ] [ error>> "Linked" = 0 1 ? ] recover
    exit ;

MAIN: linked-error-test
