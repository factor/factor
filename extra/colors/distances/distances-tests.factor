USING: colors colors.distances combinators tools.test ;

{
    0x1.05d584e1086dep6 ! 65.45851470579098
    0x1.37bbbd6552ee2p6 ! 77.93333967512766
    0x1.1c031c5c4748dp7 ! 142.0060757481591
    0x1.5aaed5f26115p6 ! 86.6707380172495
} [
    50/255 100/255 200/255 1.0 <rgba>
    100/255 200/255 50/255 1.0 <rgba>
    {
        [ CIEDE2000 ]
        [ CIE94 ]
        [ CIE76 ]
        [ CMC-l:c ]
    } 2cleave
] unit-test
