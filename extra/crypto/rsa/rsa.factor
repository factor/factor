USING: math.miller-rabin kernel math math.functions namespaces
sequences ;
IN: crypto.rsa

SYMBOL: d
SYMBOL: p
SYMBOL: q
SYMBOL: n
SYMBOL: m
SYMBOL: ee

! e = public key, d = private key, n = public modulus
TUPLE: rsa e d n ;

C: <rsa> rsa

! n bits
: generate-rsa-keypair ( numbits -- <rsa> )
    [
        2 /i 2 unique-primes first2 [ q set p set ] 2keep [ * n set ] 2keep
        [ 1- ] 2apply * m set
        65537 ee set
        m get ee get mod-inv m get + d set
        ee get d get n get <rsa>
    ] with-scope ;

: rsa-encrypt ( message rsa -- encrypted ) [ rsa-e ] keep rsa-n ^mod ;
: rsa-decrypt ( encrypted rsa -- message ) [ rsa-d ] keep rsa-n ^mod ;

