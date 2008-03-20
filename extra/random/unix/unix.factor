USING: alien.c-types io io.files io.nonblocking kernel
namespaces random io.encodings.binary singleton ;
IN: random.unix

SINGLETON: unix-random

: file-read-unbuffered ( n path -- bytes )
    over default-buffer-size [
        binary <file-reader> [ read ] with-stream
    ] with-variable ;

M: unix-random os-crypto-random-bytes ( n -- byte-array )
    "/dev/random" file-read-unbuffered ;

M: unix-random os-random-bytes ( n -- byte-array )
    "/dev/urandom" file-read-unbuffered ;

M: unix-random os-crypto-random-32 ( -- r )
    4 os-crypto-random-bytes *uint ;

M: unix-random os-random-32 ( -- r )
     4 os-random-bytes *uint ;
