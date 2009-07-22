IN: bit-sets.tests
USING: bit-sets tools.test bit-arrays ;

[ ?{ t f t f t f } ] [
    ?{ t f f f t f }
    ?{ f f t f t f } bit-set-union
] unit-test

[ ?{ f f f f t f } ] [
    ?{ t f f f t f }
    ?{ f f t f t f } bit-set-intersect
] unit-test

[ ?{ t f t f f f } ] [
    ?{ t t t f f f }
    ?{ f t f f t t } bit-set-diff
] unit-test
