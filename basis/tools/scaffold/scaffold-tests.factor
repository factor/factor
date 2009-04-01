! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test tools.scaffold unicode.case kernel
multiline tools.scaffold.private io.streams.string ;
IN: tools.scaffold.tests

: undocumented-word ( obj1 obj2 -- obj3 obj4 )
    [ >lower ] [ >upper ] bi* ;

[
<" HELP: undocumented-word
{ $values
    { "obj1" object } { "obj2" object }
    { "obj3" object } { "obj4" object }
}
{ $description "" } ;
">
]
[
    [ \ undocumented-word (help.) ] with-string-writer
] unit-test
