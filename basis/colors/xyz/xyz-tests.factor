! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays colors colors.xyz kernel math.functions
ranges sequences tools.test ;

{ t } [
    0.0 1.0 0.1 <range> [| r |
        0.0 1.0 0.1 <range> [| g |
            0.0 1.0 0.1 <range> [| b |
                r g b 1.0 <rgba> dup >xyza >rgba
                [ >rgba-components 4array ] bi@
                [ 0.00001 ~ ] 2all?
            ] all?
        ] all?
    ] all?
] unit-test
