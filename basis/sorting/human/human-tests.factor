USING: sorting.human tools.test sorting.slots sorting ;
IN: sorting.human.tests

[ { "x1y" "x2" "x10y" } ]
[ { "x1y" "x10y" "x2" } { human<=> } sort-by ] unit-test

[ { "4dup" "nip" } ]
[ { "4dup" "nip" } [ human<=> ] sort ] unit-test

[ { "4dup" "nip" } ]
[ { "nip" "4dup" } [ human<=> ] sort ] unit-test

[ { "4dup" "4nip" "5drop" "nip" "nip2" "nipd" } ]
[ { "nip" "4dup" "4nip" "5drop" "nip2" "nipd" } [ human<=> ] sort ] unit-test
