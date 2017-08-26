USING: colors.constants colors.mix kernel tools.test ;

{ color: blue } [ color: blue color: red 0.0 linear-gradient ] unit-test
{ color: red } [ color: blue color: red 1.0 linear-gradient ] unit-test

{ color: blue } [ { color: blue color: red color: green } 0.0 sample-linear-gradient ] unit-test
{ color: red } [ { color: blue color: red color: green } 0.5 sample-linear-gradient ] unit-test
{ color: green } [ { color: blue color: red color: green } 1.0 sample-linear-gradient ] unit-test

{ t } [
    { color: blue color: red } 0.5 sample-linear-gradient
    color: blue color: red 0.5 linear-gradient =
] unit-test
