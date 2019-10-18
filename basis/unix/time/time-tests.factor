
USING: classes.struct tools.test unix.time ;

IN: unix.time

{ S{ timeval f 0 0 } } [ 0 make-timeval ] unit-test
{ S{ timeval f 1 234567 } } [ 1,234,567 make-timeval ] unit-test

{ S{ timespec f 0 0 } } [ 0 make-timespec ] unit-test
{ S{ timespec f 1 234567890 } } [ 1,234,567,890 make-timespec ] unit-test
