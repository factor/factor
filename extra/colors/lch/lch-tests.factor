! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays colors kernel locals math.functions math.ranges
sequences tools.test ;

IN: colors.lch

{ t } [
    0.0 1.0 0.1 <range> [| r |
        0.0 1.0 0.1 <range> [| g |
            0.0 1.0 0.1 <range> [| b |
                r g b 1.0 <rgba> dup >LCHuv >rgba
                [ >rgba-components 4array ] bi@
                [ 0.00001 ~ ] 2all?
            ] all?
        ] all?
    ] all?
] unit-test

{ t } [
    0.0 1.0 0.1 <range> [| r |
        0.0 1.0 0.1 <range> [| g |
            0.0 1.0 0.1 <range> [| b |
                r g b 1.0 <rgba> dup >LCHab >rgba
                [ >rgba-components 4array ] bi@
                [ 0.00001 ~ ] 2all?
            ] all?
        ] all?
    ] all?
] unit-test
