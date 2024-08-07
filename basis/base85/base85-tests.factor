USING: base85 byte-arrays kernel sequences strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base85 base85> = ] unit-test

{ "NM!" } [ "He" >base85 >string ] unit-test
{ t } [ "He" dup >base85 base85> >string = ] unit-test

{ "00" } [ B{ 0 } >base85 >string ] unit-test
{ "\0" } [ "00" base85> >string ] unit-test

{ t } [ 256 <iota> >byte-array dup >z85 z85> = ] unit-test
{ "xK#0@zY<mxA+]m" } [ "hello world" >z85 >string ] unit-test
{ "hello world" } [ "xK#0@zY<mxA+]m" z85> >string ] unit-test

{ t } [ 256 <iota> >byte-array dup >ascii85 ascii85> = ] unit-test
{ "BOu!rD]j7BEbo7" } [ "hello world" >ascii85 >string ] unit-test
{ "hello world" } [ "BOu!rD]j7BEbo7" ascii85> >string ] unit-test

{ t } [ 256 <iota> >byte-array dup >adobe85 adobe85> = ] unit-test
{ "<~BOu!rD]j7BEbo7~>" } [ "hello world" >adobe85 >string ] unit-test
{ "hello world" } [ "<~BOu!rD]j7BEbo7~>" adobe85> >string ] unit-test
{ "hello world" } [ "BOu!rD]j7BEbo7~>" adobe85> >string ] unit-test
