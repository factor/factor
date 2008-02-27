IN: temporary
USING: calendar.format tools.test io.streams.string ;

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
