! Copyback (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test persistent.deques kernel math ;
IN: persistent.deques.tests

{ 3 2 1 t }
[ { 1 2 3 } sequence>deque 3 [ pop-back ] times deque-empty? ] unit-test

{ 1 2 3 t }
[ { 1 2 3 } sequence>deque 3 [ pop-front ] times deque-empty? ] unit-test

{ 1 3 2 t }
[ { 1 2 3 } sequence>deque pop-front 2 [ pop-back ] times deque-empty? ]
unit-test

{ { 2 3 4 5 6 1 } }
[ { 1 2 3 4 5 6 } sequence>deque pop-front swap push-back deque>sequence ]
unit-test

{ 1 } [ { 1 2 3 4 } sequence>deque peek-front ] unit-test
{ 4 } [ { 1 2 3 4 } sequence>deque peek-back ] unit-test

{ 1 t } [ <deque> 1 push-front pop-back deque-empty? ] unit-test
{ 1 t } [ <deque> 1 push-front pop-front deque-empty? ] unit-test
{ 1 t } [ <deque> 1 push-back pop-front deque-empty? ] unit-test
{ 1 t } [ <deque> 1 push-back pop-back deque-empty? ] unit-test

{ 1 f }
[ <deque> 1 push-front 2 push-front pop-back deque-empty? ] unit-test

{ 1 f }
[ <deque> 1 push-back 2 push-back pop-front deque-empty? ] unit-test

{ 2 f }
[ <deque> 1 push-back 2 push-back pop-back deque-empty? ] unit-test

{ 2 f }
[ <deque> 1 push-front 2 push-front pop-front deque-empty? ] unit-test
