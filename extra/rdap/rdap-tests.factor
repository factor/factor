USING: assocs rdap tools.test ;

{ "factorcode.org" } [ "factorcode.org" lookup-domain "ldhName" of ] unit-test
{ "1.1.1.0 - 1.1.1.255" } [ "1.1.1.1" lookup-ipv4 "handle" of ] unit-test
