! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logic lists logic.examples.hanoi2
formatting sequences ;
IN: logic.examples.hanoi2.tests

{ t } [
    {
        "The following statements will be printed:"
        "move Top from Left to Center"
        "move 2nd from Left to Right"
        "move Top from Center to Right"
        "move Base from Left to Center"
        "move Top from Right to Left"
        "move 2nd from Right to Center"
        "move Top from Left to Center"
        " "
    } [ "%s\n" printf ] each
    { hanoi L{ "Base" "2nd" "Top" } "Left" "Center" "Right" } query
] unit-test
