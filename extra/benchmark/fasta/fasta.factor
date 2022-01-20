! Based on http://shootout.alioth.debian.org/gp4/benchmark.php?test=fasta&lang=java&id=2
USING: alien.data assocs benchmark.reverse-complement
byte-arrays io io.encodings.ascii io.files kernel math sequences
sequences.private specialized-arrays strings typed ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:double
IN: benchmark.fasta

CONSTANT: IM 139968
CONSTANT: IA 3877
CONSTANT: IC 29573
CONSTANT: initial-seed 42
CONSTANT: line-length 60

: next-fasta-random ( seed -- seed n )
    IA * IC + IM mod dup IM /f ; inline

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

TYPED: make-cumulative ( freq -- chars: byte-array floats: double-array )
    [ keys >byte-array ]
    [ values c:double >c-array 0.0 [ + ] accumulate* ] bi ;

:: select-random ( seed chars floats -- seed elt )
    seed next-fasta-random floats [ <= ] with find drop chars nth-unsafe ; inline

TYPED: make-random-fasta ( seed: float len: fixnum chars: byte-array floats: double-array -- seed: float )
    '[ _ _ select-random ] "" replicate-as print ;

: write-description ( desc id -- )
    ">" write write bl print ;

:: n-split-lines ( n quot -- )
    n line-length /mod
    [ [ line-length quot call ] times ] dip
    quot unless-zero ; inline

TYPED: write-random-fasta ( seed: float n: fixnum chars: byte-array floats: double-array desc id -- seed: float )
    write-description
    '[ _ _ make-random-fasta ] n-split-lines ;

TYPED:: make-repeat-fasta ( k: fixnum len: fixnum alu: string -- k': fixnum )
    alu length :> kn
    len <iota> [ k + kn mod alu nth-unsafe ] "" map-as print
    k len + ;

: write-repeat-fasta ( n alu desc id -- )
    write-description
    [let
        :> alu
        0 :> k!
        [| len | k len alu make-repeat-fasta k! ] n-split-lines
    ] ;

: fasta ( n out -- )
    homo-sapiens make-cumulative
    IUB make-cumulative
    [let
        :> ( n out IUB-chars IUB-floats homo-sapiens-chars homo-sapiens-floats )
        initial-seed :> seed

        out ascii [
            n 2 * ALU "Homo sapiens alu" "ONE" write-repeat-fasta

            initial-seed

            n 3 * homo-sapiens-chars homo-sapiens-floats
            "IUB ambiguity codes" "TWO" write-random-fasta

            n 5 * IUB-chars IUB-floats
            "Homo sapiens frequency" "THREE" write-random-fasta

            drop
        ] with-file-writer
    ] ;

: fasta-benchmark ( -- ) 2500000 reverse-complement-in fasta ;

MAIN: fasta-benchmark
