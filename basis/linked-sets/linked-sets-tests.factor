USING: kernel linked-sets sets tools.test ;

{ V{ 1 2 3 } 3 } [
    0 <linked-set> 1 over adjoin
                   2 over adjoin
                   3 over adjoin
    [ members ] [ cardinality ] bi
] unit-test

{ V{ 1 3 } 2 } [
    0 <linked-set> 1 over adjoin
                   2 over adjoin
                   3 over adjoin
                   2 over delete
    [ members ] [ cardinality ] bi
] unit-test

{ V{ 1 3 4 } 3 } [
    0 <linked-set> 1 over adjoin
                   2 over adjoin
                   3 over adjoin
                   2 over delete
                   4 over adjoin
    [ members ] [ cardinality ] bi
] unit-test

{ V{ } 0 } [
    0 <linked-set> 1 over adjoin
                   2 over adjoin
                   3 over adjoin
                   dup clear-set
    [ members ] [ cardinality ] bi
] unit-test

{ V{ 1 2 3 } 3 } [
    { 1 2 3 } >linked-set
    [ members ] [ cardinality ] bi
] unit-test

{ t } [
    { 1 2 3 } [ >linked-set ] [ >linked-set ] bi =
] unit-test
