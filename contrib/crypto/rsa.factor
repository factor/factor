USING: kernel math namespaces math-contrib ;

IN: crypto
SYMBOL: d
SYMBOL: p
SYMBOL: q
SYMBOL: n
SYMBOL: m
SYMBOL: ee

: while-gcd ( -- )
    m get ee get gcd nip 1 > [ ee [ 2 + ] change while-gcd ] when ;

! n bits
: generate-key-pair ( bitlen -- )
    2 swap 1- 2 /i shift
    [ random-int next-miller-rabin-prime p set ] keep
    random-int next-miller-rabin-prime q set

    p get q get * n set
    p get 1- q get 1- * m set
    3 ee set
    while-gcd
    m get ee get mod-inv m get + d set ;

: rsa-encrypt ( message -- encrypted )
    ee get n get ^mod ;

: rsa-decrypt ( encrypted -- message )
    d get n get ^mod ;
