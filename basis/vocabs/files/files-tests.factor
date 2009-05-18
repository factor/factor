IN: vocabs.files.tests
USING: tools.test vocabs.files vocabs arrays grouping ;

[ t ] [
    "kernel" vocab-files
    "kernel" vocab vocab-files
    "kernel" <vocab-link> vocab-files
    3array all-equal?
] unit-test