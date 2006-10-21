REQUIRES: contrib/lazy-lists contrib/parser-combinators ;
PROVIDE: contrib/lambda
{ +files+ {
    "nodes.factor"
    "parser.factor"
    "core.factor"
    "lambda.factor"
} }
{ +tests+ {
    "test/lambda.factor"
} } ;

USE: lambda
MAIN: contrib/lambda lambda ;