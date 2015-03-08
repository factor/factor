USING: assocs tools.test ;
IN: xml.data

{ "bob" } [ "test" { { "name" "bob" } } { } <tag> "name" of ] unit-test
