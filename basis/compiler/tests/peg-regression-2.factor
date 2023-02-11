USING: peg.ebnf strings tools.test multiline ;
IN: compiler.tests.peg-regression-2

GENERIC: <times> ( times -- term' )
M: string <times> ;

EBNF: parse-regexp [=[

Times = .* => [[ "foo" ]]

Regexp = Times:t => [[ t <times> ]]

]=]

{ "foo" } [ "a" parse-regexp ] unit-test
