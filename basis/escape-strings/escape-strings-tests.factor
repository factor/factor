! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test escape-strings ;
IN: escape-strings.tests

{ "[[asdf]]" } [ "asdf" escape-string ] unit-test
{ "[[[[]]" } [ "[[" escape-string ] unit-test
{ "[=[]]]=]" } [ "]]" escape-string ] unit-test

{ "[===[]]]==][=[=]=]]===]" } [ "]]]==][=[=]=]" escape-string ] unit-test
{ "[==[[=[=]=]]==]" } [ "[=[=]=]" escape-string ] unit-test
{ "[[[a[]]" } [ "[a[" escape-string ] unit-test

{ "[=[ab]]=]" } [ "ab]" escape-string ] unit-test

{ "[==[[=[abcd]]=]]==]" } [ { "abcd]" } escape-strings ] unit-test
{ "[==[[=[abcd]]]=]]==]" } [ { "abcd]]" } escape-strings ] unit-test

{ "[==[]]ab]=]==]" } [ "]]ab]=" escape-string ] unit-test
{ "[=[]]ab]==]=]" } [ "]]ab]==" escape-string ] unit-test
{ "[=[]]ab]===]=]" } [ "]]ab]===" escape-string ] unit-test

{ "[[]ab]=]]" } [ "]ab]=" escape-string ] unit-test
{ "[[]ab]==]]" } [ "]ab]==" escape-string ] unit-test
{ "[[]ab]===]]" } [ "]ab]===" escape-string ] unit-test
