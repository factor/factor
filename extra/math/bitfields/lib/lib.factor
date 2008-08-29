USING: hints kernel math ;
IN: math.bitfields.lib

: clear-bit ( x n -- y ) 2^ bitnot bitand ; inline
: set-bit ( x n -- y ) 2^ bitor ; inline
: bit-clear? ( x n -- ? ) 2^ bitand zero? ; inline
: unmask ( x n -- ? ) bitnot bitand ; inline
: unmask? ( x n -- ? ) unmask 0 > ; inline
: mask ( x n -- ? ) bitand ; inline
: mask? ( x n -- ? ) mask 0 > ; inline
: wrap ( m n -- m' ) 1- bitand ; inline
: bits ( m n -- m' ) 2^ wrap ; inline
: mask-bit ( m n -- m' ) 1- 2^ mask ; inline

: shift-mod ( n s w -- n )
    >r shift r> 2^ wrap ; inline

: bitroll ( x s w -- y )
     [ wrap ] keep
     [ shift-mod ]
     [ [ - ] keep shift-mod ] 3bi bitor ; inline

: bitroll-32 ( n s -- n' ) 32 bitroll ;

HINTS: bitroll-32 bignum fixnum ;

: bitroll-64 ( n s -- n' ) 64 bitroll ;

HINTS: bitroll-64 bignum fixnum ;

