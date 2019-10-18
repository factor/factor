REQUIRES: libs/shuffle ;
PROVIDE: libs/unicode
{ +files+ {
    "utf8.factor"
    "utf16.factor"
    "case.factor"
} }
{ +tests+ { "utf8-test.factor" "utf16-test.factor" } } ;
