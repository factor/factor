USING: colors.constants colors.mix kernel tools.test ;

{ COLOR: blue } [ COLOR: blue COLOR: red 0.0 linear-gradient ] unit-test
{ COLOR: red } [ COLOR: blue COLOR: red 1.0 linear-gradient ] unit-test

{ COLOR: blue } [ { COLOR: blue COLOR: red COLOR: green } 0.0 sample-linear-gradient ] unit-test
{ COLOR: red } [ { COLOR: blue COLOR: red COLOR: green } 0.5 sample-linear-gradient ] unit-test
{ COLOR: green } [ { COLOR: blue COLOR: red COLOR: green } 1.0 sample-linear-gradient ] unit-test

{ t } [
    { COLOR: blue COLOR: red } 0.5 sample-linear-gradient
    COLOR: blue COLOR: red 0.5 linear-gradient =
] unit-test
