! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factlog factlog.examples.hanoi
formatting sequences ;
IN: factlog.examples.hanoi.tests

{ t } [
    {
        "The following statements will be printed:"
        "move disk from left to center"
        "move disk from left to right"
        "move disk from center to right"
        "move disk from left to center"
        "move disk from right to left"
        "move disk from right to center"
        "move disk from left to center"
        " "
    } [ "%s\n" printf ] each
    { hanoi 3 } query
] unit-test
