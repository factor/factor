IN: micros.tests
USING: micros tools.test math math.functions system kernel ;

! a bit racy but I can't think of a better way to check this right now
[ t ]
[ millis 1000 / micros 1000000 / [ truncate ] bi@ = ] unit-test

