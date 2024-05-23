! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
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

{ "[0[]0]" } [ "" number-escape-string ] unit-test
{ "[0[]]0]" } [ "]" number-escape-string ] unit-test
{ "[1[]0]1]" } [ "]0" number-escape-string ] unit-test
{ "[1[]0]]1]" } [ "]0]" number-escape-string ] unit-test
{ "[2[]1]]2]" } [ "]1]" number-escape-string ] unit-test
{ "[2[]0]1]]2]" } [ "]0]1]" number-escape-string ] unit-test
{ "[10[]0]1]2]3]4]5]6]7]8]9]]10]" } [ "]0]1]2]3]4]5]6]7]8]9]" number-escape-string ] unit-test
{ "[10[]0]1]2]3]4]5]6]7]8]9]00]]10]" } [ "]0]1]2]3]4]5]6]7]8]9]00]" number-escape-string ] unit-test

