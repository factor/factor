USING: sequences strings terminfo tools.test ;

{ t } [
    "vt102" terminfo-names member?
] unit-test

{ t } [
    "vt102" terminfo-path string?
] unit-test
