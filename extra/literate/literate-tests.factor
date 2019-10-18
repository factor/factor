USING: eval kernel literate math tools.test ;

{ 2 3 t } [
<LITERATE
1
> 2
>   3
blah
>     2dup 1 - =
LITERATE>
] unit-test
