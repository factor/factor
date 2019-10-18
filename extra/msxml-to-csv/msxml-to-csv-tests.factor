USING: msxml-to-csv tools.test csv io.encodings.utf8
io.files.temp kernel ;

{ t } [
    "test.csv" temp-file
    "resource:extra/msxml-to-csv/test.xml" msxml>csv
    "test.csv" temp-file utf8 file>csv
    "resource:extra/msxml-to-csv/test.csv" utf8 file>csv =
] unit-test
