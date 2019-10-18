USING: xmode.keyword-map xmode.tokens
tools.test namespaces assocs kernel strings ;

f <keyword-map> dup "k" set

{
    { "int" KEYWORD1 }
    { "void" KEYWORD2 }
    { "size_t" KEYWORD3 }
} assoc-union! drop

{ 3 } [ "k" get assoc-size ] unit-test
{ KEYWORD1 } [ "int" "k" get at ] unit-test
{ "_" } [ "k" get keyword-map-no-word-sep* >string ] unit-test
{ } [ LITERAL1 "x-y" "k" get set-at ] unit-test
{ "-_" } [ "k" get keyword-map-no-word-sep* >string ] unit-test

t <keyword-map> dup "k" set
{
    { "Foo" KEYWORD1 }
    { "bbar" KEYWORD2 }
    { "BAZ" KEYWORD3 }
} assoc-union! drop

{ KEYWORD1 } [ "fOo" "k" get at ] unit-test

{ KEYWORD2 } [ "BBAR" "k" get at ] unit-test

{ KEYWORD3 } [ "baz" "k" get at ] unit-test
