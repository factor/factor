USING: sequences.deep kernel tools.test strings math arrays
namespaces make sequences ;
IN: sequences.deep.tests

{ [ "hello" 3 4 swap ] } [ [ { "hello" V{ 3 4 } } swap ] flatten ] unit-test

{ "ABC" } [ { { 65 } 66 { { 67 } } } "" flatten-as ] unit-test

{ "foo" t } [ { { "foo" } "bar" } [ string? ] (deep-find) ] unit-test

{ f f } [ { { "foo" } "bar" } [ number? ] (deep-find) ] unit-test

{ { { "foo" } "bar" } t } [ { { "foo" } "bar" } [ array? ] (deep-find) ] unit-test

: change-something ( seq -- newseq )
    dup array? [ "hi" suffix ] [ "hello" append ] if ;

{ { { "heyhello" "hihello" } "hihello" } }
[ "hey" 1array 1array [ change-something ] deep-map ] unit-test

{ { { "heyhello" "hihello" } } }
[ "hey" 1array 1array [ change-something ] deep-map! ] unit-test

{ t } [ "foo" [ string? ] deep-any?  ] unit-test

{ "foo" } [ "foo" [ string? ] deep-find ] unit-test

{ { { 1 2 } 1 2 } } [ [ { 1 2 } [ , ] deep-each ] { } make ] unit-test

{ t }
[ { { 1 2 3 } 4 } { { { 1 { { 1 2 3 } 4 } } } 2 } deep-member? ] unit-test

{ t }
[ { { 1 2 3 } 4 } { { { 1 2 3 } 4 } 2 } deep-member? ] unit-test

{ f }
[ { 1 2 3 { 4 } } { 1 2 3 4 } deep-subseq-of? ] unit-test

{ t }
[ { 1 2 3 4 } { 1 2 3 4 } deep-subseq-of? ] unit-test

{ t }
[ { { 1 2 3 4 } } { 1 2 3 4 } deep-subseq-of? ] unit-test

{ 3 } [
    { 1 { 2 3 { 4 } } 5 { { 6 } 7 } } 0 [
        dup integer? [ even? [ 1 + ] when ] [ drop ] if
    ] deep-reduce
] unit-test

{ V{ 1 } } [ 1 flatten1 ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } flatten1 ] unit-test
{ { 1 2 3 { { 4 } } } } [ { 1 { 2 } { 3 { { 4 } } } } flatten1 ] unit-test
