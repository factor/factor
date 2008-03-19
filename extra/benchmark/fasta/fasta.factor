! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=fasta&lang=java&id=2
USING: math kernel io io.files locals multiline assocs sequences
sequences.private benchmark.reverse-complement hints io.encodings.ascii
byte-arrays float-arrays ;
IN: benchmark.fasta

: IM 139968 ; inline
: IA 3877 ; inline
: IC 29573 ; inline
: initial-seed 42 ; inline
: line-length 60 ; inline

USE: math.private

: random ( seed -- n seed )
    >float IA * IC + IM mod [ IM /f ] keep ; inline

HINTS: random fixnum ;

: ALU "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA" ; inline

: IUB
    {
        { CHAR: a 0.27 }
        { CHAR: c 0.12 }
        { CHAR: g 0.12 }
        { CHAR: t 0.27 }

        { CHAR: B 0.02 }
        { CHAR: D 0.02 }
        { CHAR: H 0.02 }
        { CHAR: K 0.02 }
        { CHAR: M 0.02 }
        { CHAR: N 0.02 }
        { CHAR: R 0.02 }
        { CHAR: S 0.02 }
        { CHAR: V 0.02 }
        { CHAR: W 0.02 }
        { CHAR: Y 0.02 }
    } ; inline

: homo-sapiens
    {
        { CHAR: a 0.3029549426680 }
        { CHAR: c 0.1979883004921 }
        { CHAR: g 0.1975473066391 }
        { CHAR: t 0.3015094502008 }
    } ; inline

: make-cumulative ( freq -- chars floats )
    dup keys >byte-array
    swap values >float-array unclip [ + ] accumulate swap add ;

:: select-random ( seed chars floats -- seed elt )
    floats seed random -rot
    [ >= ] curry find drop
    chars nth-unsafe ; inline

: make-random-fasta ( seed len chars floats -- seed )
    [ rot drop select-random ] 2curry B{ } map-as print ; inline

: write-description ( desc id -- )
    ">" write write bl print ; inline

:: split-lines ( n quot -- )
    n line-length /mod
    [ [ line-length quot call ] times ] dip
    dup zero? [ drop ] quot if ; inline

: write-random-fasta ( seed n chars floats desc id -- seed )
    write-description
    [ make-random-fasta ] 2curry split-lines ; inline

:: make-repeat-fasta ( k len alu -- k' )
    [let | kn [ alu length ] |
        len [ k + kn mod alu nth-unsafe ] B{ } map-as print
        k len +
    ] ; inline

: write-repeat-fasta ( n alu desc id -- )
    write-description
    [let | k! [ 0 ] alu [ ] |
        [| len | k len alu make-repeat-fasta k! ] split-lines
    ] with-locals ; inline

: fasta ( n out -- )
    homo-sapiens make-cumulative
    IUB make-cumulative
    [let | homo-sapiens-floats [ ]
           homo-sapiens-chars [ ]
           IUB-floats [ ]
           IUB-chars [ ]
           out [ ]
           n [ ]
           seed [ initial-seed ] |

        out ascii [
            n 2 * ALU "Homo sapiens alu" "ONE" write-repeat-fasta

            initial-seed
            n 3 * homo-sapiens-chars homo-sapiens-floats "IUB ambiguity codes" "TWO" write-random-fasta
            n 5 * IUB-chars IUB-floats "Homo sapiens frequency" "THREE" write-random-fasta
            drop
        ] with-file-writer

    ] with-locals ;

: run-fasta 2500000 reverse-complement-in fasta ;

MAIN: run-fasta
