! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=fasta&lang=java&id=2
USING: math kernel io io.files locals multiline assocs sequences
sequences.private benchmark.reverse-complement hints io.encodings.ascii
byte-arrays specialized-arrays.double ;
IN: benchmark.fasta

CONSTANT: IM 139968
CONSTANT: IA 3877
CONSTANT: IC 29573
CONSTANT: initial-seed 42
CONSTANT: line-length 60

: random ( seed -- n seed )
    >float IA * IC + IM mod [ IM /f ] keep ; inline

HINTS: random fixnum ;

CONSTANT: ALU "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"

CONSTANT: IUB
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
    }

CONSTANT: homo-sapiens
    {
        { CHAR: a 0.3029549426680 }
        { CHAR: c 0.1979883004921 }
        { CHAR: g 0.1975473066391 }
        { CHAR: t 0.3015094502008 }
    }

: make-cumulative ( freq -- chars floats )
    [ keys >byte-array ]
    [ values >double-array ] bi unclip [ + ] accumulate swap suffix ;

:: select-random ( seed chars floats -- seed elt )
    floats seed random -rot
    [ >= ] curry find drop
    chars nth-unsafe ; inline

: make-random-fasta ( seed len chars floats -- seed )
    [ rot drop select-random ] 2curry "" map-as print ; inline

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
        len [ k + kn mod alu nth-unsafe ] "" map-as print
        k len +
    ] ; inline

: write-repeat-fasta ( n alu desc id -- )
    write-description
    [let | k! [ 0 ] alu [ ] |
        [| len | k len alu make-repeat-fasta k! ] split-lines
    ] ; inline

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

    ] ;

: run-fasta ( -- ) 2500000 reverse-complement-in fasta ;

MAIN: run-fasta
