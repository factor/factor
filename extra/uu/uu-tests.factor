USING: kernel tools.test uu ;
IN: uu.tests

CONSTANT: plain
"The smooth-scaled python crept over the sleeping dog"

CONSTANT: encoded
"begin
M5&AE('-M;V]T:\"US8V%L960@<'ET:&]N(&-R97!T(&]V97(@=&AE('-L965P
':6YG(&1O9P  
end
"

{ t } [ plain string>uu encoded = ] unit-test
{ t } [ encoded uu>string plain = ] unit-test

{ "Cat" } [
    "begin 644 cat.txt\n#0V%T\n`\nend\n" uu>string
] unit-test
