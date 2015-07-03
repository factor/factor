IN: math.partial-dispatch.tests
USING: math.partial-dispatch math.private
tools.test math kernel sequences ;

{ t } [ \ + integer fixnum math-both-known? ] unit-test
{ t } [ \ + bignum fixnum math-both-known? ] unit-test
{ t } [ \ + integer bignum math-both-known? ] unit-test
{ t } [ \ + float fixnum math-both-known? ] unit-test
{ f } [ \ + real fixnum math-both-known? ] unit-test
{ f } [ \ + object number math-both-known? ] unit-test
{ f } [ \ number= fixnum object math-both-known? ] unit-test
{ t } [ \ number= integer fixnum math-both-known? ] unit-test
{ f } [ \ >fixnum \ shift derived-ops member-eq? ] unit-test
{ f } [ \ >integer \ /i derived-ops member-eq? ] unit-test
{ t } [ \ fixnum-shift \ shift derived-ops member-eq? ] unit-test

{ { integer fixnum } } [ \ +-integer-fixnum integer-op-input-classes ] unit-test
{ { fixnum fixnum } } [ \ fixnum+ integer-op-input-classes ] unit-test
{ { fixnum fixnum } } [ \ fixnum+fast integer-op-input-classes ] unit-test
{ { integer } } [ \ bitnot integer-op-input-classes ] unit-test

{ shift } [ \ fixnum-shift generic-variant ] unit-test
{ fixnum-shift-fast } [ \ fixnum-shift no-overflow-variant ] unit-test

{ fixnum-shift-fast } [ \ shift modular-variant ] unit-test
{ fixnum-bitnot } [ \ bitnot modular-variant ] unit-test
{ fixnum+fast } [ \ fixnum+ modular-variant ] unit-test
{ fixnum+fast } [ \ fixnum+fast modular-variant ] unit-test

{ 3 } [ 1 2 +-integer-integer ] unit-test
{ 3 } [ 1 >bignum 2 +-integer-integer ] unit-test
{ 3 } [ 1 2 >bignum +-integer-integer ] unit-test
{ 3 } [ 1 >bignum 2 >bignum +-integer-integer ] unit-test
