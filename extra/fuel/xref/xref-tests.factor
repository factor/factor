USING: arrays definitions fuel.xref fuel.xref.private io.pathnames kernel math
sequences sets tools.test ;
QUALIFIED: tools.crossref
IN: fuel.xref.tests

{ t } [
    "fuel" apropos-xref empty? not
] unit-test

{ t } [
    "fuel" vocab-xref length 2 =
] unit-test

{ { } } [
    "i-dont-exist!" callees-xref
] unit-test

: random-word ( -- )
    3 dup 2drop
    3 1array drop ;

{ 2 } [
    \ random-word tools.crossref:uses format-xrefs group-xrefs
    members length
] unit-test

{ f f } [
    \ drop where normalize-loc
] unit-test

{ t t } [
    \ where where normalize-loc [ absolute-path? ] [ integer? ] bi*
] unit-test
