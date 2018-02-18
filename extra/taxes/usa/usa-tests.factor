USING: kernel money tools.test
taxes.usa taxes.usa.federal taxes.usa.mn
calendar taxes.usa.w4 usa-cities math.finance ;

{
    426 23
} [
    12000 2008 3 f <w4> <federal> net biweekly
    dollars/cents
] unit-test

{
    426 23
} [
    12000 2008 3 t <w4> <federal> net biweekly
    dollars/cents
] unit-test

{
    684 4
} [
    20000 2008 3 f <w4> <federal> net biweekly
    dollars/cents
] unit-test



{
    804 58
} [
    24000 2008 3 f <w4> <federal> net biweekly
    dollars/cents
] unit-test

{
    831 31
} [
    24000 2008 3 t <w4> <federal> net biweekly
    dollars/cents
] unit-test


{
    780 81
} [
    24000 2008 3 f <w4> <mn> net biweekly
    dollars/cents
] unit-test

{
    818 76
} [
    24000 2008 3 t <w4> <mn> net biweekly
    dollars/cents
] unit-test


{
    2124 39
} [
    78250 2008 3 f <w4> <mn> net biweekly
    dollars/cents
] unit-test

{
    2321 76
} [
    78250 2008 3 t <w4> <mn> net biweekly
    dollars/cents
] unit-test


{
    2612 63
} [
    100000 2008 3 f <w4> <mn> net biweekly
    dollars/cents
] unit-test

{
    22244 52
} [
    1000000 2008 3 f <w4> <mn> net biweekly
    dollars/cents
] unit-test

{
    578357 40
} [
    1000000 2008 3 f <w4> <mn> net
    dollars/cents
] unit-test

{
    588325 41
} [
    1000000 2008 3 t <w4> <mn> net
    dollars/cents
] unit-test


{ 30 97 } [
    24000 2008 2 f <w4> <mn> MN withholding* biweekly dollars/cents
] unit-test

{ 173 66 } [
    78250 2008 2 f <w4> <mn> MN withholding* biweekly dollars/cents
] unit-test


{ 138 69 } [
    24000 2008 2 f <w4> <federal> total-withholding biweekly dollars/cents
] unit-test

{ 754 72 } [
    78250 2008 2 f <w4> <federal> total-withholding biweekly dollars/cents
] unit-test
