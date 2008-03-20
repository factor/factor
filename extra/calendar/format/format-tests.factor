USING: calendar.format calendar kernel tools.test
io.streams.string ;
IN: calendar.format.tests

[ 0 ] [
    "Z" [ read-rfc3339-gmt-offset ] with-string-reader
] unit-test

[ 1 ] [
    "+01" [ read-rfc3339-gmt-offset ] with-string-reader
] unit-test

[ -1 ] [
    "-01" [ read-rfc3339-gmt-offset ] with-string-reader
] unit-test

[ -1-1/2 ] [
    "-01:30" [ read-rfc3339-gmt-offset ] with-string-reader
] unit-test

[ 1+1/2 ] [
    "+01:30" [ read-rfc3339-gmt-offset ] with-string-reader
] unit-test

[ ] [ now timestamp>rfc3339 drop ] unit-test
[ ] [ now timestamp>rfc822 drop ] unit-test
