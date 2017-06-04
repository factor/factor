USING: compiler.cfg.registers io.streams.string prettyprint tools.test ;
IN: compiler.cfg.registers.tests

! Ensure prettyprinting of ds/rs-loc is right

{ "D: 3\nR: -1\n" } [
    [ d: 3 . r: -1 . ] with-string-writer
] unit-test
