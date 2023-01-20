! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays colors colors.cmyk kernel locals math.functions
ranges sequences tools.test ;

{ t } [
    0.0 1.0 0.1 <range> [| r |
        0.0 1.0 0.1 <range> [| g |
            0.0 1.0 0.1 <range> [| b |
                r g b 1.0 <rgba> dup >cmyka color=
            ] all?
        ] all?
    ] all?
] unit-test
