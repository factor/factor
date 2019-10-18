USING: alien calendar kernel math test ;

[ t ] [ 239293000 [
    unix-time>timestamp timestamp>timeval
    timeval>timestamp timestamp>timeval *ulong
] keep = ] unit-test


[ t ] [ 23929000.3 [
    unix-time>timestamp timestamp>timeval
    timeval>timestamp timestamp>timeval *ulong
] keep >bignum = ] unit-test
