REQUIRES: libs/memoize ;
USING: io kernel sequences strings vectors words memoize tools ;
IN: reverse-complement

MEMO: trans-map ( -- str )
    256 >string
    "TGCAAKYRMBDHV" "ACGTUMRYKVHDB"
    [ pick set-nth ] 2each ;

: do-trans-map ( str -- ) [ ch>upper trans-map nth ] inject ;

\ do-trans-map { string } "specializer" set-word-prop

: translate-seq ( seq -- str )
    concat dup nreverse dup do-trans-map ;

: show-seq ( seq -- )
    translate-seq 60 <groups> [ print ] each ;

: do-line ( seq line -- seq )
    dup first ">;" memq? [
        over show-seq print dup delete-all
    ] [
        over push
    ] if ;

: (reverse-complement) ( seq -- )
    readln [ do-line (reverse-complement) ] [ show-seq ] if* ;

: reverse-complement ( infile outfile -- )
    <file-writer> >r <file-reader> r> <duplex-stream> [
        500000 <vector> (reverse-complement)
    ] with-stream ;

USE: test

: run
    "/Users/slava/reverse-complement-in.txt"
    "/Users/slava/reverse-complement-out.txt" 
    [ reverse-complement ] time ;
