USING: arrays bech32 sequences tools.test ;

! bech32

{ "a" B{ } } [ "A12UEL5L" bech32> ] unit-test
{ "a" B{ } } [ "a12uel5l" bech32> ] unit-test

{
    "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio"
    B{ }
} [
    "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs"
    bech32>
] unit-test

{
    "abcdef"
    "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\e\x1c\x1d\x1e\x1f"
} [
    "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw" bech32> "" like
] unit-test

{
    "1"
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
} [
    "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j"
    bech32> "" like
] unit-test

{
    "split"
    "\x18\x17\x19\x18\x16\x1c\x01\x10\v\x1d\b\x19\x17\x1d\x13\r\x10\x17\x1d\x16\x19\x1c\x01\x10\v\x03\x19\x1d\e\x19\x03\x03\x1d\x13\v\x19\x03\x03\x19\r\x18\x1d\x01\x19\x03\x03\x19\r"
} [
    "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w"
    bech32> "" like
] unit-test

{
    {
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
    }
} [
    {
        "\x201nwldj5"
        "\x7f1axkwrx"
        "\x801eym55h"
        "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx"
        "pzry9x0s0muk"
        "1pzry9x0s0muk"
        "x1b4n0q5v"
        "li1dgmt3"
        "de1lg7wt"
        "A1G7SGD8"
        "10a06t8"
        "1qzzfhee"
    } [ bech32> 2array ] map
] unit-test

! bech32m

{ "a" B{ } } [ "A1LQFN3A" bech32m> ] unit-test
{ "a" B{ } } [ "a1lqfn3a" bech32m> ] unit-test

{
    "an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber1"
    B{ }
} [
    "an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6"
    bech32m>
] unit-test

{
    "abcdef"
    "\x1f\x1e\x1d\x1c\e\x1a\x19\x18\x17\x16\x15\x14\x13\x12\x11\x10\x0f\x0e\r\f\v\n\t\b\a\x06\x05\x04\x03\x02\x01\0"
} [
    "abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx" bech32m> "" like
] unit-test

{
    "1"
    "\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f\x1f"
} [
    "11llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllludsr8"
    bech32m> "" like
] unit-test

{
    "split"
    "\x18\x17\x19\x18\x16\x1c\x01\x10\v\x1d\b\x19\x17\x1d\x13\r\x10\x17\x1d\x16\x19\x1c\x01\x10\v\x03\x19\x1d\e\x19\x03\x03\x1d\x13\v\x19\x03\x03\x19\r\x18\x1d\x01\x19\x03\x03\x19\r"
} [
    "split1checkupstagehandshakeupstreamerranterredcaperredlc445v"
    bech32m> "" like
] unit-test

{
    {
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
        { f f }
    }
} [
    {
        "\x201xj0phk"
        "\x7f1g6xzxy"
        "\x801vctc34"
        "an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4"
        "qyrz8wqd2c9m"
        "1qyrz8wqd2c9m"
        "y1b0jsk6g"
        "lt1igcx5c0"
        "in1muywd"
        "mm1crxm3i"
        "au1s5cgom"
        "M1VUXWEZ"
        "16plkw9"
        "1p2gdwpf"
    } [ bech32m> 2array ] map
] unit-test
