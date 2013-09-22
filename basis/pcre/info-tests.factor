USING: pcre pcre.info sequences tools.test ;

[ { { 3 "day" } { 2 "month" } { 1 "year" } } ]
[
    "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})" <compiled-pcre>
    name-table-entries
] unit-test

[ { 100 110 120 130 } ] [ 100 10 4 gen-array-addrs ] unit-test
