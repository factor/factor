USING: assocs calendar kernel linked-assocs multiline present
toml tools.test ;

! Example document

{
    LH{
        { "title" "TOML Example" }
        {
            "owner"
            LH{
                { "name" "Tom Preston-Werner" }
                { "organization" "GitHub" }
                {
                    "bio"
                    "GitHub Cofounder & CEO\nLikes tater tots and beer."
                }
                { "dob"
                    T{ timestamp
                        { year 1979 }
                        { month 5 }
                        { day 27 }
                        { hour 7 }
                        { minute 32 }
                    }
                }
            }
        }
        {
            "database"
            LH{
                { "server" "192.168.1.1" }
                { "ports" { 8001 8001 8002 } }
                { "connection_max" 5000 }
                { "enabled" t }
            }
        }
        {
            "servers"
            LH{
                {
                    "alpha"
                    LH{
                        { "ip" "10.0.0.1" }
                        { "dc" "eqdc10" }
                    }
                }
                {
                    "beta"
                    LH{
                        { "ip" "10.0.0.2" }
                        { "dc" "eqdc10" }
                        { "country" "中国" }
                    }
                }
            }
        }
        {
            "clients"
            LH{
                { "data" { { "gamma" "delta" } { 1 2 } } }
                { "hosts" { "alpha" "omega" } }
            }
        }
        {
            "products"
            V{
                LH{
                    { "name" "Hammer" }
                    { "sku" 738594937 }
                }
                LH{
                    { "name" "Nail" }
                    { "sku" 284758393 }
                    { "color" "gray" }
                }
            }
        }
    }
} [
    [=[

# This is a TOML document. Boom.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z # First class dates? Why not?

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # You can indent as you please. Tabs or spaces. TOML don't care.
  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"
  country = "中国" # This should be parsed as UTF-8

[clients]
data = [ ["gamma", "delta"], [1, 2] ] # just an update to make sure parsers support it

# Line breaks are OK when inside arrays
hosts = [
  "alpha",
  "omega"
]

# Products

  [[products]]
  name = "Hammer"
  sku = 738594937

  [[products]]
  name = "Nail"
  sku = 284758393
  color = "gray"

    ]=] toml>
] unit-test

{
    LH{
        { "deps" LH{
            { "temp_targets" LH{ { "case" 72.0 } } } }
        }
    }
} [
    "[deps]
    temp_targets = { case = 72.0 }" toml>
] unit-test

{
    LH{ { "foo" LH{ { "bar" LH{ { "baz" 123 } } } { "qux" 456 } } } }
} [
[=[
[foo.bar]
baz = 123
[foo]
qux = 456
]=] toml>
] unit-test

! TESTS FROM 1.0.0 SPEC

! Comments
{
    LH{ { "key" "value" } { "another" "# This is not a comment" } }
} [
    [=[ # This is a full-line comment
key = "value"  # This is a comment at the end of a line
another = "# This is not a comment"]=] toml>
] unit-test

! Key/Value Pairs

[ [=[ key = # INVALID]=] toml> ] must-fail

[ [=[ key = 1234abcd ]=] toml> ] must-fail

[ [=[ first = "Tom" last = "Preston-Werner" # INVALID]=] toml> ] must-fail

! Keys

{
    LH{
        { "127.0.0.1" "value" }
        { "character encoding" "value" }
        { "ʎǝʞ" "value" }
        { "key2" "value" }
        { "quoted \"value\"" "value" }
    }
} [
    [=[
"127.0.0.1" = "value"
"character encoding" = "value"
"ʎǝʞ" = "value"
'key2' = "value"
'quoted "value"' = "value"
 ]=] toml>
] unit-test

[ [=[ = "no key name"  # INVALID]=] toml> ] must-fail
{ LH{ { "" "blank" } } } [ [=[ "" = "blank"     # VALID but discouraged]=] toml> ] unit-test
{ LH{ { "" "blank" } } } [ [=[ '' = "blank"     # VALID but discouraged]=] toml> ] unit-test

{
    LH{
        { "name" "Orange" }
        { "physical" LH{ { "color" "orange" } { "shape" "round" } } }
        { "site" LH{ { "google.com" t } } }
    }
} [
    [=[
name = "Orange"
physical.color = "orange"
physical.shape = "round"
site."google.com" = true
]=] toml>
] unit-test

{
    LH{
        { "fruit" LH{
                { "name" "banana" }
                { "color" "yellow" }
                { "flavor" "banana" }
            }
        }
    }
} [
    [=[
fruit.name = "banana"     # this is best practice
fruit. color = "yellow"    # same as fruit.color
fruit . flavor = "banana"   # same as fruit.flavor]=] toml>
] unit-test

[ [=[
# DO NOT DO THIS
name = "Tom"
name = "Pradyun"
]=] toml> ] [ duplicate-key? ] must-fail-with

[ [=[ # THE FOLLOWING IS INVALID

# This defines the value of fruit.apple to be an integer.
fruit.apple = 1

# But then this treats fruit.apple like it's a table.
# You can't turn an integer into a table.
fruit.apple.smooth = true]=] toml> ] must-fail

{ LH{ { "3" LH{ { "14159" "pi" } } } } } [
    [=[ 3.14159 = "pi" ]=] toml>
] unit-test

! Strings

{
    LH{
        {
            "str"
            "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF."
        }
    }
} [
    [=[ str = "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF." ]=]
    toml>
] unit-test

{ LH{ { "str1" "Roses are red\nViolets are blue" } } } [
    [=[ str1 = """
Roses are red
Violets are blue"""]=] toml>
] unit-test

{
    LH{
        { "str1" "The quick brown fox jumps over the lazy dog." }
        { "str2" "The quick brown fox jumps over the lazy dog." }
        { "str3" "The quick brown fox jumps over the lazy dog." }
    }
} [
    [=[
# The following strings are byte-for-byte equivalent:
str1 = "The quick brown fox jumps over the lazy dog."

str2 = """
The quick brown \


  fox jumps over \
    the lazy dog."""

str3 = """\
       The quick brown \
       fox jumps over \
       the lazy dog.\
       """
   ]=] toml>
] unit-test

{
    LH{
        { "winpath" "C:\\Users\\nodejs\\templates" }
        { "winpath2" "\\\\ServerX\\admin$\\system32\\" }
        { "quoted" "Tom \"Dubs\" Preston-Werner" }
        { "regex" "<\\i\\c*\\s*>" }
    }
} [
    [=[ # What you see is what you get.
winpath  = 'C:\Users\nodejs\templates'
winpath2 = '\\ServerX\admin$\system32\'
quoted   = 'Tom "Dubs" Preston-Werner'
regex    = '<\i\c*\s*>' ]=] toml>
] unit-test

! Integer

{
    LH{
        { "int1" 99 }
        { "int2" 42 }
        { "int3" 0 }
        { "int4" -17 }
        { "int5" 1000 }
        { "int6" 5349221 }
        { "int7" 5349221 }
        { "int8" 12345 }
        { "hex1" 0xdeadbeef }
        { "hex2" 0xdeadbeef }
        { "hex3" 0xdeadbeef }
        { "oct1" 0o01234567 }
        { "oct2" 0o755 }
        { "bin1" 0b11010110 }
    }
} [
    [=[
int1 = +99
int2 = 42
int3 = 0
int4 = -17
int5 = 1_000
int6 = 5_349_221
int7 = 53_49_221  # Indian number system grouping
int8 = 1_2_3_4_5  # VALID but discouraged

# hexadecimal with prefix `0x`
hex1 = 0xDEADBEEF
hex2 = 0xdeadbeef
hex3 = 0xdead_beef

# octal with prefix `0o`
oct1 = 0o01234567
oct2 = 0o755 # useful for Unix file permissions

# binary with prefix `0b`
bin1 = 0b11010110
]=] toml>
] unit-test

[ [=[ key = +0o99 ]=] toml> ] must-fail

! Floats

{
    LH{
        { "flt1" "1.0" }
        { "flt2" "3.1415" }
        { "flt3" "-0.01" }
        { "flt4" "5e+22" }
        { "flt5" "1000000.0" }
        { "flt6" "-0.02" }
        { "flt7" "6.626e-34" }
        { "flt8" "224617.445991228" }
        { "sf1" "1/0." }
        { "sf2" "1/0." }
        { "sf3" "-1/0." }
        { "sf4" "0/0." }
        { "sf5" "0/0." }
        { "sf6" "0/0." }
    }
} [
    [=[
# fractional
flt1 = +1.0
flt2 = 3.1415
flt3 = -0.01

# exponent
flt4 = 5e+22
flt5 = 1e06
flt6 = -2E-2

# both
flt7 = 6.626e-34

flt8 = 224_617.445_991_228

# infinity
sf1 = inf  # positive infinity
sf2 = +inf # positive infinity
sf3 = -inf # negative infinity

# not a number
sf4 = nan  # actual sNaN/qNaN encoding is implementation-specific
sf5 = +nan # same as `nan`
sf6 = -nan # valid, actual encoding is implementation-specific
]=] toml> [ present ] assoc-map
] unit-test

[ [=[ invalid_float_1 = .7]=] toml> ] must-fail
[ [=[ invalid_float_2 = 7.]=] toml> ] must-fail
[ [=[ invalid_float_2 = 3.e+20]=] toml> ] must-fail

! Booleans

{ LH{ { "bool1" t } { "bool2" f } } } [
    [=[ bool1 = true
bool2 = false]=] toml>
] unit-test

! Offset Date-Time

{
    LH{
        {
            "odt1"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { hour 7 }
                { minute 32 }
            }
        }
        {
            "odt2"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { minute 32 }
                { gmt-offset T{ duration { hour -7 } } }
            }
        }
        {
            "odt3"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { minute 32 }
                { second 999999/1000000 }
                { gmt-offset T{ duration { hour -7 } } }
            }
        }
        {
            "odt4"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { hour 7 }
                { minute 32 }
            }
        }
    }
} [
    [=[
odt1 = 1979-05-27T07:32:00Z
odt2 = 1979-05-27T00:32:00-07:00
odt3 = 1979-05-27T00:32:00.999999-07:00
odt4 = 1979-05-27 07:32:00Z
]=] toml>
] unit-test

! Local Date-Time

{
    LH{
        {
            "ldt1"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { hour 7 }
                { minute 32 }
            }
        }
        {
            "ldt2"
            T{ timestamp
                { year 1979 }
                { month 5 }
                { day 27 }
                { minute 32 }
                { second 999999/1000000 }
            }
        }
    }
} [
    [=[
ldt1 = 1979-05-27T07:32:00
ldt2 = 1979-05-27T00:32:00.999999
]=] toml>
] unit-test

! Local Date

{ LH{ { "ld1" "1979-05-27" } } } [
    [=[
ld1 = 1979-05-27
]=] toml>
] unit-test

! Local Time

{ LH{ { "lt1" "07:32:00" } { "lt2" "00:32:00.999999" } } } [
    [=[
lt1 = 07:32:00
lt2 = 00:32:00.999999
]=] toml>
] unit-test

! Array

{
    LH{
        { "integers" { 1 2 3 } }
        { "colors" { "red" "yellow" "green" } }
        { "nested_arrays_of_ints" { { 1 2 } { 3 4 5 } } }
        { "nested_mixed_array" { { 1 2 } { "a" "b" "c" } } }
        { "string_array" { "all" "strings" "are the same" "type" } }
        { "numbers" { 0.1 0.2 0.5 1 2 5 } }
        {
            "contributors"
            {
                "Foo Bar <foo@example.com>"
                LH{
                    { "name" "Baz Qux" }
                    { "email" "bazqux@example.com" }
                    { "url" "https://example.com/bazqux" }
                }
            }
        }
    }
} [
    [=[
integers = [ 1, 2, 3 ]
colors = [ "red", "yellow", "green" ]
nested_arrays_of_ints = [ [ 1, 2 ], [3, 4, 5] ]
nested_mixed_array = [ [ 1, 2 ], ["a", "b", "c"] ]
string_array = [ "all", 'strings', """are the same""", '''type''' ]

# Mixed-type arrays are allowed
numbers = [ 0.1, 0.2, 0.5, 1, 2, 5 ]
contributors = [
  "Foo Bar <foo@example.com>",
  { name = "Baz Qux", email = "bazqux@example.com", url = "https://example.com/bazqux" }
]
]=] toml>
] unit-test

{
    LH{
        { "integers2" { 1 2 3 } }
        { "integers3" { 1 2 } }
    }
} [
    [=[ integers2 = [
  1, 2, 3
]

integers3 = [
  1,
  2, # this is ok
]]=] toml>
] unit-test

! Table

{
    LH{ { "j" LH{ { "ʞ" LH{ { "l" LH{ { "key1" t } } } } } } } }
} [
    [=[
[ j . "ʞ" . 'l' ]
key1 = true
]=] toml>
] unit-test

! Inline Table

{
    LH{
        {
            "name"
            LH{ { "first" "Tom" } { "last" "Preston-Werner" } }
        }
        { "point" LH{ { "x" 1 } { "y" 2 } } }
        { "animal" LH{ { "type" LH{ { "name" "pug" } } } } }
    }
} [
    [=[
name = { first = "Tom", last = "Preston-Werner" }
point = { x = 1, y = 2 }
animal = { type.name = "pug" }]=] toml>
] unit-test

! Array of Tables

{
    LH{
        { "points" {
                LH{ { "x" 1 } { "y" 2 } { "z" 3 } }
                LH{ { "x" 7 } { "y" 8 } { "z" 9 } }
                LH{ { "x" 2 } { "y" 4 } { "z" 8 } }
            }
        }
    }
} [
    [=[ points = [ { x = 1, y = 2, z = 3 },
           { x = 7, y = 8, z = 9 },
           { x = 2, y = 4, z = 8 } ] ]=] toml>
] unit-test

{ LH{ { "a" { } } } } [ "a=[]" toml> ] unit-test
{ LH{ { "a" { 1 } } } } [ "a=[1]" toml> ] unit-test
{ LH{ { "a" { 1 2 3 } } } } [ "a=[1,2,3]" toml> ] unit-test
{ LH{ { "a" { 1 2 3 } } } } [ "a=[,1,,,,2,,3,,]" toml> ] unit-test
{ LH{ { "a" { 1 2 3 } } } } [ "a=[ # this\n,1,, # is\n,,2, #a\n,3,, # comment \n]" toml> ] unit-test

! unreleased

! Clarify Unicode and UTF-8 references.
! Relax comment parsing; most control characters are again permitted.
! Allow newline after key/values in inline tables.
! Allow trailing comma in inline tables.
! Clarify where and how dotted keys define tables.
! Add new \e shorthand for the escape character.
! Add \x00 notation to basic strings.
! Seconds in Date-Time and Time values are now optional.
! Allow non-English scripts in unquoted (bare) keys
! Clarify newline normalization in multi-line literal strings.


{ t } [
    LH{
        { "name" "Factor" }
        { "age" 22 }
        { "list" { 4 8 15 16 23 42 } }
        { "map" { LH{ { "one" 1 } { "two" 2 } } } }
    } [ >toml toml> ] keep =
] unit-test
