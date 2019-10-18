REQUIRES: libs/lazy-lists libs/parser-combinators ;
PROVIDE: libs/lambda
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
MAIN: libs/lambda lambda ;