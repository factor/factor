USING: io io.files io.streams.duplex kernel sequences
sequences.private strings vectors words memoize splitting
hints unicode.case continuations io.encodings.ascii ;
IN: benchmark.reverse-complement

MEMO: trans-map ( -- str )
    256 >string
    "TGCAAKYRMBDHV" "ACGTUMRYKVHDB"
    [ pick set-nth ] 2each ;

: do-trans-map ( str -- )
    [ ch>upper trans-map nth ] change-each ;

HINTS: do-trans-map string ;

: translate-seq ( seq -- str )
    concat dup reverse-here dup do-trans-map ;

: show-seq ( seq -- )
    translate-seq 60 <groups> [ print ] each ;

: do-line ( seq line -- seq )
    dup first ">;" memq? [
        over show-seq print dup delete-all
    ] [
        over push
    ] if ;

HINTS: do-line vector string ;

: (reverse-complement) ( seq -- )
    readln [ do-line (reverse-complement) ] [ show-seq ] if* ;

: reverse-complement ( infile outfile -- )
    ascii <file-writer> [
        swap ascii <file-reader> [
            swap <duplex-stream> [
                500000 <vector> (reverse-complement)
            ] with-stream
        ] with-disposal
    ] with-disposal ;

: reverse-complement-in
    "reverse-complement-in.txt" temp-file ;

: reverse-complement-out
    "reverse-complement-out.txt" temp-file ;

: reverse-complement-main ( -- )
    reverse-complement-in
    reverse-complement-out
    reverse-complement ;

MAIN: reverse-complement-main
