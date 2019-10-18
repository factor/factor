REQUIRES: libs/memoize ;
PROVIDE: libs/regexp
{ +files+ {
    "tables.factor"
    "regexp.factor"
} } { +tests+ {
    "test/regexp.factor"
    "test/tables.factor"
} } ;

