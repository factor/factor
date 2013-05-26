! Copyright (C) 2013 Loryn Jenkins.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test math.decimal math.decimal.private ;
IN: math.decimal.tests

{ 1/10 }        [ 1 1/10^ ] unit-test
{ 1/100 }       [ 2 1/10^ ] unit-test
{ 1 }           [ 0 1/10^ ] unit-test
{ 10 }          [ -1 1/10^ ] unit-test
{ 100 }         [ -2 1/10^ ] unit-test

{ 1/2 }         [ 2+1/2 0 decrem ] unit-test
{ 1/2 }         [ -2-1/2 0 decrem ] unit-test
{ 1/2 }         [ 2+1/2 0 decmod ] unit-test
{ -1/2 }        [ -2-1/2 0 decmod ] unit-test

{ 1/20 }        [ 2+15/100 1 decrem ] unit-test
{ 1/20 }        [ -2-15/100 1 decrem ] unit-test
{ 1/20 }        [ 2+15/100 1 decmod ] unit-test
{ -1/20 }       [ -2-15/100 1 decmod ] unit-test

{ 2+1/10 }      [ 2+15/100 1 /decmod drop ] unit-test
{ 1/20 }        [ 2+15/100 1 /decmod nip ] unit-test
{ -2-1/10 }     [ -2-15/100 1 /decmod drop ] unit-test
{ -1/20 }       [ -2-15/100 1 /decmod nip ] unit-test
{ 189+18/100 }  [ 189+189/1000 2 /decmod drop ] unit-test
{ 9/1000 }      [ 189+189/1000 2 /decmod nip ] unit-test
{ -189-18/100 } [ -189-189/1000 2 /decmod drop ] unit-test
{ -9/1000 }     [ -189-189/1000 2 /decmod nip ] unit-test

{ 189+9/50 }    [ 189+189/1000 2 truncate* ] unit-test
{ -189-9/50 }   [ -189-189/1000 2 truncate* ] unit-test

{ f }           [ 2+1/2 1 lsd-odd? ] unit-test
{ t }           [ 2+3/20 1 lsd-odd? ] unit-test
{ t }           [ 2+3125/1000 1 lsd-odd? ] unit-test
{ f }           [ 0 1 lsd-odd? ] unit-test 
{ t }           [ 23 0 lsd-odd? ] unit-test
{ f }           [ 24 0 lsd-odd? ] unit-test
{ f }           [ 2456 -2 lsd-odd? ] unit-test
{ t }           [ 2346 -2 lsd-odd? ] unit-test

{ 189+19/100 }  [ 189+189/1000 2 round* ] unit-test
{ 189+9/50 }    [ 189+182/1000 2 round* ] unit-test
{ 189+9/50 }    [ 189+18245/100000 2 round* ] unit-test

{ 24 }          [ 23+1/2 0 round* ] unit-test
{ 24 }          [ 24+1/2 0 round* ] unit-test
{ -24 }         [ -23-1/2 0 round* ] unit-test
{ -24 }         [ -24-1/2 0 round* ] unit-test