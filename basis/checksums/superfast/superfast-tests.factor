USING: checksums fry kernel math sequences tools.test ;
IN: checksums.superfast

{
    {
        0
        4064760690
        2484602674
        1021960881
        3514307704
        762925594
        95280079
        516333699
        1761749771
        3841726064
        2549850032
    }
} [
    "1234567890" [ length 1 + ] keep 0 <superfast>
    '[ _ swap head _ checksum-bytes ] { } map-integers
] unit-test
