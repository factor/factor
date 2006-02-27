USING: kernel math namespaces math-contrib errors ;

IN: crypto
SYMBOL: d
SYMBOL: p
SYMBOL: q
SYMBOL: n
SYMBOL: m
SYMBOL: ee

! e = public key, d = private key, n = public modulus
TUPLE: rsa e d n ;

! n bits
: generate-key-pair ( bitlen -- <rsa> )
    [
        2 /i generate-two-unique-primes [ q set p set ] 2keep [ * n set ] 2keep
        [ 1- ] 2apply * m set
        m get next-miller-rabin-prime ee set
        m get ee get find-relative-prime* ee set
        m get ee get mod-inv m get + d set
        ee get d get n get <rsa>
    ] with-scope ;

: rsa-encrypt ( message rsa -- encrypted ) [ rsa-e ] keep rsa-n ^mod ;
: rsa-decrypt ( encrypted rsa -- message ) [ rsa-d ] keep rsa-n ^mod ;

