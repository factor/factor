IN: io.unix.openbsd
USING: io.unix.bsd io.backend core-foundation.fsevents ;

TUPLE: openbsd-io ;

INSTANCE: openbsd-io bsd-io

T{ openbsd-io } set-io-backend
