USING: lambda parser-combinators test kernel ;

[ "Yuuki" ] [ "Yuuki" <id> some call variable-node-var ] unit-test
[ T{ lambda-node f "a" "b" } ] [ "( a. b )" lambda-parse ] unit-test

[ T{ lambda-node f "a" "c" } ]
    [ "c" "b" T{ lambda-node f "a" "b" } substitute ] unit-test
[ T{ lambda-node f "a" "b" } ]
    [ "c" "a" T{ lambda-node f "a" "b" } substitute ] unit-test

[ T{ lambda-node f "b" "b" } ]
    [ "((a. (c. (b. (b (a c))))) (d. d))" lambda-parse reduce ] unit-test