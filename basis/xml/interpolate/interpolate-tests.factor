! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test xml.interpolate multiline kernel assocs
sequences accessors xml.writer xml.interpolate.private
locals ;
IN: xml.interpolate.tests

[ "a" "c" { "a" "c" } ] [
    "<?xml version='1.0'?><x><-a-><b val=<-c->/></x>"
    interpolated-doc
    [ second var>> ]
    [ fourth "val" swap at var>> ]
    [ extract-variables ] tri
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<x>
  one
  <b val="two"/>
  y
  <foo/>
</x>"} ] [
    [let* | a [ "one" ] c [ "two" ] x [ "y" ]
           d [ [XML <-x-> <foo/> XML] ] |
        <XML
            <x> <-a-> <b val=<-c->/> <-d-> </x>
        XML> pprint-xml>string
    ]
] unit-test
