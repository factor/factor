USING: assocs multiline present toml tools.test ;

! Example document

{
    H{
        { "title" "TOML Example" }
        {
            "owner"
            H{
                { "name" "Tom Preston-Werner" }
                { "organization" "GitHub" }
                {
                    "bio"
                    "GitHub Cofounder & CEO\nLikes tater tots and beer."
                }
                { "dob" "1979-05-27T07:32:00Z" }
            }
        }
        {
            "database"
            H{
                { "server" "192.168.1.1" }
                { "ports" { 8001 8001 8002 } }
                { "connection_max" 5000 }
                { "enabled" t }
            }
        }
        {
            "servers"
            H{
                {
                    "alpha"
                    H{
                        { "ip" "10.0.0.1" }
                        { "dc" "eqdc10" }
                    }
                }
                {
                    "beta"
                    H{
                        { "ip" "10.0.0.2" }
                        { "dc" "eqdc10" }
                        { "country" "中国" }
                    }
                }
            }
        }
        {
            "clients"
            H{
                { "data" { { "gamma" "delta" } { 1 2 } } }
                { "hosts" { "alpha" "omega" } }
            }
        }
        {
            "products"
            V{
                H{
                    { "name" "Hammer" }
                    { "sku" 738594937 }
                }
                H{
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
    H{
        { "deps" H{
            { "temp_targets" H{ { "case" 72.0 } } } }
        }
    }
} [
    "[deps]
    temp_targets = { case = 72.0 }" toml>
] unit-test

! TESTS FROM 1.0.0 SPEC

! Comments
{
    H{ { "key" "value" } { "another" "# This is not a comment" } }
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
    H{
        { "character encoding" "value" }
        { "quoted \"value\"" "value" }
        { "ʎǝʞ" "value" }
        { "key2" "value" }
        { "127.0.0.1" "value" }
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
{ H{ { "" "blank" } } } [ [=[ "" = "blank"     # VALID but discouraged]=] toml> ] unit-test
{ H{ { "" "blank" } } } [ [=[ '' = "blank"     # VALID but discouraged]=] toml> ] unit-test

{
    H{
        { "physical" H{ { "color" "orange" } { "shape" "round" } } }
        { "name" "Orange" }
        { "site" H{ { "google.com" t } } }
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
    H{
        { "fruit" H{
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

{ H{ { "3" H{ { "14159" "pi" } } } } } [
    [=[ 3.14159 = "pi" ]=] toml>
] unit-test

! Strings

{
    H{
        {
            "str"
            "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF."
        }
    }
} [
    [=[ str = "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF." ]=]
    toml>
] unit-test

{ H{ { "str1" "Roses are red\nViolets are blue" } } } [
    [=[ str1 = """
Roses are red
Violets are blue"""]=] toml>
] unit-test

{
    H{
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
    H{
        { "regex" "<\\i\\c*\\s*>" }
        { "quoted" "Tom \"Dubs\" Preston-Werner" }
        { "winpath2" "\\\\ServerX\\admin$\\system32\\" }
        { "winpath" "C:\\Users\\nodejs\\templates" }
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
    H{
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
    H{
        { "flt1" "1.0" }
        { "flt2" "3.1415" }
        { "flt3" "-0.01" }
        { "flt4" "5.0e+22" }
        { "flt5" "1000000.0" }
        { "flt6" "-0.02" }
        { "flt7" "6.626e-34" }
        { "flt8" "224617.445991228" }
        { "sf1" "1/0." }
        { "sf3" "-1/0." }
        { "sf2" "1/0." }
        { "sf5" "0/0." }
        { "sf4" "0/0." }
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

{ H{ { "bool1" t } { "bool2" f } } } [
    [=[ bool1 = true
bool2 = false]=] toml>
] unit-test

! Offset Date-Time

! XXX:

! Local Date-Time

! XXX:

! Local Date

! XXX:

! Local Time

! XXX:

! Array

{
    H{
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
                H{
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
    H{
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
    H{ { "j" H{ { "ʞ" H{ { "l" H{ { "key1" t } } } } } } } }
} [
    [=[
[ j . "ʞ" . 'l' ]
key1 = true
]=] toml>
] unit-test

! Inline Table

{
    H{
        {
            "name"
            H{ { "first" "Tom" } { "last" "Preston-Werner" } }
        }
        { "point" H{ { "x" 1 } { "y" 2 } } }
        { "animal" H{ { "type" H{ { "name" "pug" } } } } }
    }
} [
    [=[
name = { first = "Tom", last = "Preston-Werner" }
point = { x = 1, y = 2 }
animal = { type.name = "pug" }]=] toml>
] unit-test

! Array of Tables

{
    H{
        { "points" {
                H{ { "x" 1 } { "y" 2 } { "z" 3 } }
                H{ { "x" 7 } { "y" 8 } { "z" 9 } }
                H{ { "x" 2 } { "y" 4 } { "z" 8 } }
            }
        }
    }
} [
    [=[ points = [ { x = 1, y = 2, z = 3 },
           { x = 7, y = 8, z = 9 },
           { x = 2, y = 4, z = 8 } ] ]=] toml>
] unit-test

{ H{ { "a" { } } } } [ "a=[]" toml> ] unit-test
{ H{ { "a" { 1 } } } } [ "a=[1]" toml> ] unit-test
{ H{ { "a" { 1 2 3 } } } } [ "a=[1,2,3]" toml> ] unit-test
{ H{ { "a" { 1 2 3 } } } } [ "a=[,1,,,,2,,3,,]" toml> ] unit-test
{ H{ { "a" { 1 2 3 } } } } [ "a=[ # this\n,1,, # is\n,,2, #a\n,3,, # comment \n]" toml> ] unit-test

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
