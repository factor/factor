USING: pcre.utils tools.test ;
IN: pcre.utils.tests

[ { "Bords" "words" "word" } ] [
    "Bords, words, word." { ", " ", " "." } split-subseqs
] unit-test
