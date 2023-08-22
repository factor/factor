! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: classes.struct.bit-accessors effects random stack-checker
tools.test ;

{ t } [ 20 random 20 random bit-reader infer ( alien -- n ) effect= ] unit-test
{ t } [ 20 random 20 random bit-writer infer ( n alien -- ) effect= ] unit-test
