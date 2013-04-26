USING: alien.c-types cocoa.runtime tools.test ;
IN: cocoa.messages

{ "( sender-stub:void() )" }
[ { void { } } sender-stub-name ] unit-test

{ "( sender-stub:id(id,SEL,void*,Class) )" }
[ { id { id SEL void* Class } } sender-stub-name ] unit-test
