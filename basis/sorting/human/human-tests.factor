USING: sorting.human tools.test sorting ;

{ { "x1y" "x2" "x10y" } }
[ { "x1y" "x10y" "x2" } [ human<=> ] sort-with ] unit-test

{ { "4dup" "nip" } }
[ { "4dup" "nip" } [ human<=> ] sort-with ] unit-test

{ { "4dup" "nip" } }
[ { "nip" "4dup" } [ human<=> ] sort-with ] unit-test

{ { "4dup" "4nip" "5drop" "nip" "nip2" "nipd" } }
[ { "nip" "4dup" "4nip" "5drop" "nip2" "nipd" } [ human<=> ] sort-with ] unit-test


{ { "Abc" "abc" "def" "gh" } }
[ { "abc" "Abc" "def" "gh" } [ human<=> ] sort-with ] unit-test

{ { "abc" "Abc" "def" "gh" } }
[ { "abc" "Abc" "def" "gh" } [ humani<=> ] sort-with ] unit-test
