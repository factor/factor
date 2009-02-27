! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors regexp.matchers prettyprint io io.encodings.ascii
io.files kernel sequences assocs namespaces regexp ;
IN: benchmark.regex-dna

! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=regexdna&lang=ruby&id=1

: strip-line-breaks ( string -- string' )
    R/ >.*\n|\n/ "" re-replace ;

: count-patterns ( string -- )
    {
        R/ agggtaaa|tttaccct/i
        R/ [cgt]gggtaaa|tttaccc[acg]/i
        R/ a[act]ggtaaa|tttacc[agt]t/i
        R/ ag[act]gtaaa|tttac[agt]ct/i
        R/ agg[act]taaa|ttta[agt]cct/i
        R/ aggg[acg]aaa|ttt[cgt]ccct/i
        R/ agggt[cgt]aa|tt[acg]accct/i
        R/ agggta[cgt]a|t[acg]taccct/i
        R/ agggtaa[cgt]|[acg]ttaccct/i
    } [
        [ raw>> write bl ]
        [ count-matches . ]
        bi
    ] with each ;

: do-replacements ( string -- string' )
    {
        { R/ B/ "(c|g|t)" }
        { R/ D/ "(a|g|t)" }
        { R/ H/ "(a|c|t)" }
        { R/ K/ "(g|t)" }
        { R/ M/ "(a|c)" }
        { R/ N/ "(a|c|g|t)" }
        { R/ R/ "(a|g)" }
        { R/ S/ "(c|t)" }
        { R/ V/ "(a|c|g)" }
        { R/ W/ "(a|t)" }
        { R/ Y/ "(c|t)" }
    } [ re-replace ] assoc-each ;

SYMBOL: ilen
SYMBOL: clen

: regex-dna ( file -- )
    ascii file-contents dup length ilen set
    strip-line-breaks dup length clen set
    dup count-patterns
    do-replacements
    nl
    ilen get .
    clen get .
    length . ;

: regex-dna-main ( -- )
    "resource:extra/benchmark/regex-dna/regex-dna-test-in.txt" regex-dna ;

MAIN: regex-dna-main
