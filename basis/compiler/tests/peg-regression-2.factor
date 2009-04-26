IN: compiler.tests.peg-regression-2
USING: peg.ebnf strings tools.test ;

GENERIC: <times> ( times -- term' )
M: string <times> ;

EBNF: parse-regexp

Times = .* => [[ "foo" ]]

Regexp = Times:t => [[ t <times> ]]

;EBNF

[ "foo" ] [ "a" parse-regexp ] unit-test
