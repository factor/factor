REQUIRES: libs/http-client libs/xml ;
PROVIDE: libs/yahoo
{ +files+ {
    "yahoo.factor"
    "yahoo.facts"
} }
{ +tests+ { "test.factor" } } ;
