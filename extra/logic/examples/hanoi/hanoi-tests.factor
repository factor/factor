! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: io.streams.string literals logic logic.examples.hanoi
multiline tools.test ;

${
    t [=[ move disk from left to center
move disk from left to right
move disk from center to right
move disk from left to center
move disk from right to left
move disk from right to center
move disk from left to center
]=] } [
    [ { hanoi 3 } query ] with-string-writer
] unit-test
