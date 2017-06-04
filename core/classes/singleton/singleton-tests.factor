USING: classes.singleton io.streams.string kernel see tools.test ;
IN: classes.singleton.tests

SINGLETON: bzzt
{ t } [ bzzt bzzt? ] unit-test
{ t } [ bzzt bzzt eq? ] unit-test

GENERIC: zammo ( obj -- str )
M: bzzt zammo drop "yes!" ;
{ "yes!" } [ bzzt zammo ] unit-test

SINGLETON: omg
{ t } [ omg singleton-class? ] unit-test
{ "IN: classes.singleton.tests\nSINGLETON: omg\n" } [ [ omg see ] with-string-writer ] unit-test

SINGLETON: word-and-singleton

: word-and-singleton ( -- x ) 3 ;

{ t } [ \ word-and-singleton word-and-singleton? ] unit-test
{ 3 } [ word-and-singleton ] unit-test
