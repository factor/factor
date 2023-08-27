! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test compression.zstd ;
IN: compression.zstd.tests

{ B{ 1 2 3 4 } } [
    B{ 1 2 3 4 } 5 zstd-compress-level zstd-uncompress
] unit-test

{ B{ 1 2 3 4 } } [
    B{ 1 2 3 4 } zstd-compress zstd-uncompress
] unit-test

! bad compressed buffer, should fail
[
    B{ 1 2 3 4 } zstd-uncompress-size
] [ zstd-error? ] must-fail-with

