USING: io.encodings.ascii io.files kernel magic tools.test ;

! Image headers can match unrelated entries in newer magic databases.
! Use known content rather than depending on an unrecognized image format.
{ "ASCII text" "text/plain" "us-ascii" } [
    [
        "Factor magic test.\n" over ascii set-file-contents
        [ guess-file ] [ guess-mime-type ] [ guess-mime-encoding ] tri
    ] with-test-file
] unit-test
