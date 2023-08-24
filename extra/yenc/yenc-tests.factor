USING: byte-arrays io.encodings.binary io.files kernel sequences
tools.test yenc ;

{ t } [ 255 <iota> >byte-array dup yenc ydec = ] unit-test

{ t } [
    "resource:LICENSE.txt"
    [ yenc-file ydec-file 2nip ] [ binary file-contents ] bi =
] unit-test
