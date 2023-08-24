! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: io.streams.string multiline logic lists
logic.examples.hanoi2 sequences tools.test ;

{
    t [=[ move Top from Left to Center
move 2nd from Left to Right
move Top from Center to Right
move Base from Left to Center
move Top from Right to Left
move 2nd from Right to Center
move Top from Left to Center
]=] } [
    [
        { hanoi L{ "Base" "2nd" "Top" } "Left" "Center" "Right" } query
    ] with-string-writer
] unit-test
