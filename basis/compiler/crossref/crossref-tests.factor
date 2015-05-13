USING: compiler.crossref fry kernel sequences tools.test vocabs words ;
IN: compiler.crossref.tests

! Dependencies of all words should always be satisfied unless we're
! in the middle of recompiling something
[ { } ] [
    all-words dup [ subwords ] map concat append
    H{ } clone '[ _ dependencies-satisfied? ] reject
] unit-test
