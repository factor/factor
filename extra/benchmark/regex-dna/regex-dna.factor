! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io io.encodings.ascii io.files kernel sequences
assocs math.parser namespaces regexp benchmark.knucleotide ;
IN: benchmark.regex-dna

! Based on https://shootout.alioth.debian.org/gp4/benchmark.php?test=regexdna&lang=ruby&id=1

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
        [ count-matches number>string print ]
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

! Make sure we read the file with \n as the newline delimiter.
: regex-dna ( file -- )
    ascii file-lines [ "\n" append ] map concat dup length ilen set
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
