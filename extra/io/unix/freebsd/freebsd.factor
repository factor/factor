IN: io.unix.freebsd
USING: io.unix.bsd io.backend core-foundation.fsevents ;

TUPLE: freebsd-io ;

INSTANCE: freebsd-io bsd-io

T{ freebsd-io } set-io-backend
