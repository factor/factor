USING: colors colors.mix kernel tools.test ;

{ t } [
    COLOR: blue COLOR: red 0.0 linear-gradient
    COLOR: blue color=
] unit-test

{ t } [
    COLOR: blue COLOR: red 1.0 linear-gradient
    COLOR: red color=
] unit-test

{ t } [
    { COLOR: blue COLOR: red COLOR: green } 0.0 sample-linear-gradient
    COLOR: blue color=
] unit-test

{ t } [
    { COLOR: blue COLOR: red COLOR: green } 0.5 sample-linear-gradient
    COLOR: red color=
] unit-test

{ t } [
    { COLOR: blue COLOR: red COLOR: green } 1.0 sample-linear-gradient
    COLOR: green color=
] unit-test

{ t } [
    { COLOR: blue COLOR: red } 0.5 sample-linear-gradient
    COLOR: blue COLOR: red 0.5 linear-gradient =
] unit-test
