! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.encodings.ascii io.files kernel sequences
assocs math.parser namespaces regexp benchmark.knucleotide ;
IN: benchmark.regex-dna

! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=regexdna&lang=ruby&id=1

: strip-line-breaks ( string -- string' )
    re">.*\n|\n" "" re-replace ;

: count-patterns ( string -- )
    {
        re:: "agggtaaa|tttaccct" "i"
        re:: "[cgt]gggtaaa|tttaccc[acg]" "i"
        re:: "a[act]ggtaaa|tttacc[agt]t" "i"
        re:: "ag[act]gtaaa|tttac[agt]ct" "i"
        re:: "agg[act]taaa|ttta[agt]cct" "i"
        re:: "aggg[acg]aaa|ttt[cgt]ccct" "i"
        re:: "agggt[cgt]aa|tt[acg]accct" "i"
        re:: "agggta[cgt]a|t[acg]taccct" "i"
        re:: "agggtaa[cgt]|[acg]ttaccct" "i"
    } [
        [ raw>> write bl ]
        [ count-matches number>string print ]
        bi
    ] with each ;

: do-replacements ( string -- string' )
    {
        { re"B" "(c|g|t)" }
        { re"D" "(a|g|t)" }
        { re"H" "(a|c|t)" }
        { re"K" "(g|t)" }
        { re"M" "(a|c)" }
        { re"N" "(a|c|g|t)" }
        { re"R" "(a|g)" }
        { re"S" "(c|t)" }
        { re"V" "(a|c|g)" }
        { re"W" "(a|t)" }
        { re"Y" "(c|t)" }
    } [ re-replace ] assoc-each ;

SYMBOL: ilen
SYMBOL: clen

: regex-dna ( file -- )
    ascii file-contents dup length ilen set
    strip-line-breaks dup length clen set
    dup count-patterns
    do-replacements
    nl
    ilen get number>string print
    clen get number>string print
    length number>string print ;

: regex-dna-benchmark ( -- )
    knucleotide-in regex-dna ;

MAIN: regex-dna-benchmark
