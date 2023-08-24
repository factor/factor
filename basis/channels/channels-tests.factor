! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
USING: channels kernel sequences sorting threads tools.test ;

{ V{ 10 } } [
    V{ } clone <channel>
    [ from swap push ] in-thread
    10 swap to
] unit-test

{ 20 } [
    <channel>
    [ 20 swap to ] in-thread
    from
] unit-test

{ { 1 2 3 4 } } [
    V{ } clone <channel>
    [ from swap push ] in-thread
    [ from swap push ] in-thread
    [ from swap push ] in-thread
    [ from swap push ] in-thread
    4 over to
    2 over to
    1 over to
    3 swap to
    sort
] unit-test

{ { 1 2 4 9 } } [
    V{ } clone <channel>
    [ 4 swap to ] in-thread
    [ 2 swap to ] in-thread
    [ 1 swap to ] in-thread
    [ 9 swap to ] in-thread
    2dup from swap push
    2dup from swap push
    2dup from swap push
    dupd from swap push
    sort
] unit-test
