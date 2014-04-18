! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel linked-assocs literals locals sequences
tools.test yaml yaml.private grouping ;
IN: yaml.tests

! TODO real conformance tests here

! Basic test
CONSTANT: test-string """--- # Favorite movies
 - Casablanca
 - North by Northwest
 - The Man Who Wasn't There
 - last:
   - foo
   - bar
   - baz
"""
CONSTANT: test-obj {
    "Casablanca"
    "North by Northwest"
    "The Man Who Wasn't There"
    H{ { "last" { "foo" "bar" "baz" } } }
}
CONSTANT: test-represented-string """--- !!seq
- !!str Casablanca
- !!str North by Northwest
- !!str The Man Who Wasn't There
- !!map
  !!str last: !!seq
  - !!str foo
  - !!str bar
  - !!str baz
...
"""

${ test-obj } [ $ test-string yaml> ] unit-test
${ test-represented-string } [ $ test-obj >yaml ] unit-test
${ test-represented-string } [ $ test-represented-string yaml> >yaml ] unit-test

! Non-scalar key
CONSTANT: complex-key H{ { { "foo" } "bar" } }
CONSTANT: complex-key-represented """--- !!map
? !!seq
- !!str foo
: !!str bar
...
"""

${ complex-key } [ $ complex-key-represented yaml> ] unit-test

! Multiple docs
CONSTANT: test-docs """--- !!str a
...
--- !!seq
- !!str b
- !!str c
...
--- !!map
!!str d: !!str e
...
"""
CONSTANT: test-objs { "a" { "b" "c" } H{ { "d" "e" } } }

${ test-objs } [ $ test-docs yaml-docs> ] unit-test
${ test-docs } [ $ test-objs >yaml-docs ] unit-test
${ test-docs } [ $ test-docs yaml-docs> >yaml-docs ] unit-test

! Misc types
CONSTANT: test-types { 1 t f 1.0 }
CONSTANT: test-represented-types """--- !!seq
- !!int 1
- !!bool true
- !!bool false
- !!float 1.0
...
"""

${ test-types } [ $ test-represented-types yaml> ] unit-test
${ test-types } [ $ test-types >yaml yaml> ] unit-test


! Anchors
CONSTANT: test-anchors """- &1 "1"
- *1
- &2 ["1","2"]
- *2
- &3
  *1 : "one"
- *3
"""
CONSTANT: test-anchors-obj {
  "1" "1" { "1" "2" } { "1" "2" } H{ { "1" "one" } } H{ { "1" "one" } }
}

${ test-anchors-obj } [ $ test-anchors yaml> ] unit-test
${ test-anchors-obj } [ $ test-anchors-obj >yaml yaml> ] unit-test
! and test indentity
{ t } [ $ test-anchors yaml> 2 group [ all-eq? ] all? ] unit-test
{ t } [ $ test-anchors yaml> >yaml yaml> 2 group [ all-eq? ] all? ] unit-test

! Anchors and fancy types
CONSTANT: fancy-anchors """- &1 [ "foo" ]
- &2 !!set
  ? *1
- *2
"""
CONSTANT: fancy-anchors-obj {
  { "foo" } HS{ { "foo" } } HS{ { "foo" } }
}
${ fancy-anchors-obj } [ $ fancy-anchors yaml> ] unit-test
${ fancy-anchors-obj } [ $ fancy-anchors-obj >yaml yaml> ] unit-test

! Simple Recursive output
: simple-recursive-list ( -- obj )
  { f } clone [ 0 over set-nth ] keep ;
CONSTANT: simple-recursive-list-anchored T{ yaml-anchor f "0" {
  T{ yaml-alias f "0" }
} }
CONSTANT: simple-recursive-list-yaml """&0
- *0"""

${ simple-recursive-list-anchored } [ simple-recursive-list replace-identities ] unit-test
${ simple-recursive-list-anchored } [ $ simple-recursive-list-yaml yaml> replace-identities ] unit-test
${ simple-recursive-list-anchored } [ simple-recursive-list >yaml yaml> replace-identities ] unit-test

! many recursive outputs
: many-recursive-objects ( -- obj )
  4 [ simple-recursive-list ] replicate ;
CONSTANT: many-recursive-objects-anchored {
  T{ yaml-anchor f "0" { T{ yaml-alias f "0" } } }
  T{ yaml-anchor f "1" { T{ yaml-alias f "1" } } }
  T{ yaml-anchor f "2" { T{ yaml-alias f "2" } } }
  T{ yaml-anchor f "3" { T{ yaml-alias f "3" } } }
}

${ many-recursive-objects-anchored } [ many-recursive-objects replace-identities ] unit-test

! Advanced recursive outputs
:: transitive-recursive-objects ( -- obj )
  { f } :> list
  HS{ list } :> set
  H{ { set list } } :> hash
  hash 0 list set-nth
  list ;
CONSTANT: transitive-recursive-objects-anchored T{ yaml-anchor f "0" {
  H{ { HS{ T{ yaml-alias f "0" } } T{ yaml-alias f "0" } } }
} }

${ transitive-recursive-objects-anchored } [ transitive-recursive-objects replace-identities ] unit-test


! Lifted from pyyaml
! http://pyyaml.org/browser/pyyaml/trunk/tests/data

! !!!!!!!!!!!!!!!
! construct-bool
! TODO this is yaml 1.1, test it once a correct system
! for switching between 1.2 and 1.1 is available
! CONSTANT: construct-bool-obj H{
!     { "canonical" t }
!     { "answer" f }
!     { "logical" t }
!     { "option" t }
!     { "but" H{ { "y" "is a string" } { "n" "is a string" } } }
! }
! 
! CONSTANT: construct-bool-str """canonical: yes
! answer: NO
! logical: True
! option: on
! 
! 
! but:
!     y: is a string
!     n: is a string
! """
! 
! ${ construct-bool-obj } [ $ construct-bool-str yaml> ] unit-test
! ${ construct-bool-obj } [ $ construct-bool-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-int
! TODO _ in numbers is yaml 1.1, test it once a correct system
! for switching between 1.2 and 1.1 is available
! CONSTANT: construct-int-obj H{
!     { "canonical" 685230 }
!     { "decimal" 685230 }
!     { "octal" 685230 }
!     { "hexadecimal" 685230 }
!     { "binary" 685230 }
!     { "sexagesimal" 685230 }
! }
! CONSTANT: construct-int-str """canonical: 685230
! decimal: +685_230
! octal: 02472256
! hexadecimal: 0x_0A_74_AE
! binary: 0b1010_0111_0100_1010_1110
! sexagesimal: 190:20:30
! """
! 
! ${ construct-int-obj } [ $ construct-int-str yaml> ] unit-test
! ${ construct-int-obj } [ $ construct-int-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-map
CONSTANT: construct-map-obj H{ {
      "Block style"
      H{ { "Clark" "Evans" } { "Brian" "Ingerson" } { "Oren" "Ben-Kiki" } }
    } {
      "Flow style"
      H{ { "Clark" "Evans" } { "Brian" "Ingerson" } { "Oren" "Ben-Kiki" } }
    }
}

CONSTANT: construct-map-str """# Unordered set of key: value pairs.
Block style: !!map
  Clark : Evans
  Brian : Ingerson
  Oren  : Ben-Kiki
Flow style: !!map { Clark: Evans, Brian: Ingerson, Oren: Ben-Kiki }
"""

${ construct-map-obj } [ $ construct-map-str yaml> ] unit-test
${ construct-map-obj } [ $ construct-map-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-null
CONSTANT: construct-null-obj {
    f
    H{
        { "empty" f }
        { "canonical" f }
        { "english" f }
        { f "null key" }
    } H{
        {
          "sparse"
          { f "2nd entry" f "4th entry" f }
        }
    }
}


CONSTANT: construct-null-str """# A document may be null.
---
---
# This mapping has four keys,
# one has a value.
empty:
canonical: ~
english: null
~: null key
---
# This sequence has five
# entries, two have values.
sparse:
  - ~
  - 2nd entry
  -
  - 4th entry
  - Null
"""

${ construct-null-obj } [ $ construct-null-str yaml-docs> ] unit-test
! TODO Decide what to do with null -> f -> false
! ${ construct-null-obj } [ $ construct-null-obj >yaml-docs yaml-docs> ] unit-test

! !!!!!!!!!!!!!!!
! construct-seq
CONSTANT: construct-seq-obj H{
    { "Block style" { "Mercury" "Venus" "Earth" "Mars" "Jupiter" "Saturn" "Uranus" "Neptune" "Pluto" } }
    { "Flow style" { "Mercury" "Venus" "Earth" "Mars" "Jupiter" "Saturn" "Uranus" "Neptune" "Pluto" } }
}

CONSTANT: construct-seq-str """# Ordered sequence of nodes
Block style: !!seq
- Mercury   # Rotates - no light/dark sides.
- Venus     # Deadliest. Aptly named.
- Earth     # Mostly dirt.
- Mars      # Seems empty.
- Jupiter   # The king.
- Saturn    # Pretty.
- Uranus    # Where the sun hardly shines.
- Neptune   # Boring. No rings.
- Pluto     # You call this a planet?
Flow style: !!seq [ Mercury, Venus, Earth, Mars,      # Rocks
                    Jupiter, Saturn, Uranus, Neptune, # Gas
                    Pluto ]                           # Overrated
"""

${ construct-seq-obj } [ $ construct-seq-str yaml> ] unit-test
${ construct-seq-obj } [ $ construct-seq-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-set
CONSTANT: construct-set-obj H{
  {
   "baseball players" HS{
      "Mark McGwire"
      "Sammy Sosa"
      "Ken Griffey"
    }
  } {
    "baseball teams" HS{
      "Boston Red Sox"
      "Detroit Tigers"
      "New York Yankees"
    }
  }
}

CONSTANT: construct-set-str """# Explicitly typed set.
baseball players: !!set
  ? Mark McGwire
  ? Sammy Sosa
  ? Ken Griffey
# Flow style
baseball teams: !!set { Boston Red Sox, Detroit Tigers, New York Yankees }
"""

${ construct-set-obj } [ $ construct-set-str yaml> ] unit-test
${ construct-set-obj } [ $ construct-set-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-binary

! # byte-arrays contents generate by the following python script
! # which uses the string from pyyaml tests
! from __future__ import print_function
! l=0
! for char in "GIF89a\x0c\x00\x0c\x00\x84\x00\x00\xff\xff\xf7\xf5\xf5\xee\xe9\xe9\xe5fff\x00\x00\x00\xe7\xe7\xe7^^^\xf3\xf3\xed\x8e\x8e\x8e\xe0\xe0\xe0\x9f\x9f\x9f\x93\x93\x93\xa7\xa7\xa7\x9e\x9e\x9eiiiccc\xa3\xa3\xa3\x84\x84\x84\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9\xff\xfe\xf9!\xfe\x0eMade with GIMP\x00,\x00\x00\x00\x00\x0c\x00\x0c\x00\x00\x05,  \x8e\x810\x9e\xe3@\x14\xe8i\x10\xc4\xd1\x8a\x08\x1c\xcf\x80M$z\xef\xff0\x85p\xb8\xb01f\r\x1b\xce\x01\xc3\x01\x1e\x10' \x82\n\x01\x00;":
!     s = str(ord(char))
!     print(s, end='')
!     l=l+len(s)+1
!     if (l >= 60):
!         print("\n", end='')
!         l = 0
!     else:
!         print(' ', end='')
! print("\n", end='')
CONSTANT: construct-binary-obj H{
  {
   "canonical" B{
      71 73 70 56 57 97 12 0 12 0 132 0 0 255 255 247 245 245 238
      233 233 229 102 102 102 0 0 0 231 231 231 94 94 94 243 243 237
      142 142 142 224 224 224 159 159 159 147 147 147 167 167 167
      158 158 158 105 105 105 99 99 99 163 163 163 132 132 132 255
      254 249 255 254 249 255 254 249 255 254 249 255 254 249 255
      254 249 255 254 249 255 254 249 255 254 249 255 254 249 255
      254 249 255 254 249 255 254 249 255 254 249 33 254 14 77 97
      100 101 32 119 105 116 104 32 71 73 77 80 0 44 0 0 0 0 12 0
      12 0 0 5 44 32 32 142 129 48 158 227 64 20 232 105 16 196 209
      138 8 28 207 128 77 36 122 239 255 48 133 112 184 176 49 102
      13 27 206 1 195 1 30 16 39 32 130 10 1 0 59
    }
  } {
   "generic" B{
      71 73 70 56 57 97 12 0 12 0 132 0 0 255 255 247 245 245 238
      233 233 229 102 102 102 0 0 0 231 231 231 94 94 94 243 243 237
      142 142 142 224 224 224 159 159 159 147 147 147 167 167 167
      158 158 158 105 105 105 99 99 99 163 163 163 132 132 132 255
      254 249 255 254 249 255 254 249 255 254 249 255 254 249 255
      254 249 255 254 249 255 254 249 255 254 249 255 254 249 255
      254 249 255 254 249 255 254 249 255 254 249 33 254 14 77 97
      100 101 32 119 105 116 104 32 71 73 77 80 0 44 0 0 0 0 12 0
      12 0 0 5 44 32 32 142 129 48 158 227 64 20 232 105 16 196 209
      138 8 28 207 128 77 36 122 239 255 48 133 112 184 176 49 102
      13 27 206 1 195 1 30 16 39 32 130 10 1 0 59
    }
  } {
    "description" "The binary value above is a tiny arrow encoded as a gif image."
  }
}

CONSTANT: construct-binary-str """canonical: !!binary "\\
 R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5\\
 OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+\\
 +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC\\
 AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs="
generic: !!binary |
 R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5
 OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+
 +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC
 AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
description:
 The binary value above is a tiny arrow encoded as a gif image.
"""

${ construct-binary-obj } [ $ construct-binary-str yaml> ] unit-test
${ construct-binary-obj } [ $ construct-binary-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-merge
! TODO decide when to merge
! CONSTANT: construct-merge-obj {
!     H{ { "x" 1 } { "y" 2 } }
!     H{ { "x" 0 } { "y" 2 } }
!     H{ { "r" 10 } }
!     H{ { "r" 1 } }
!     H{ { "x" 1 } { "y" 2 } { "r" 10 } { "label" "center/big" } }
!     H{ { "x" 1 } { "y" 2 } { "r" 10 } { "label" "center/big" } }
!     H{ { "x" 1 } { "y" 2 } { "r" 10 } { "label" "center/big" } }
!     H{ { "x" 1 } { "y" 2 } { "r" 10 } { "label" "center/big" } }
! }
! 
! CONSTANT: construct-merge-str """---
! - &CENTER { x: 1, 'y': 2 }
! - &LEFT { x: 0, 'y': 2 }
! - &BIG { r: 10 }
! - &SMALL { r: 1 }
! 
! # All the following maps are equal:
! 
! - # Explicit keys
!   x: 1
!   'y': 2
!   r: 10
!   label: center/big
! 
! - # Merge one map
!   << : *CENTER
!   r: 10
!   label: center/big
! 
! - # Merge multiple maps
!   << : [ *CENTER, *BIG ]
!   label: center/big
! 
! - # Override
!   << : [ *BIG, *LEFT, *SMALL ]
!   x: 1
!   label: center/big
! """
! 
! ${ construct-merge-obj } [ $ construct-merge-str yaml> ] unit-test
! ${ construct-merge-obj } [ $ construct-merge-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-omap
CONSTANT: construct-omap-obj H{
  {
    "Bestiary"
    $[ <linked-hash> {
        { "aardvark" "African pig-like ant eater. Ugly." }
        { "anteater" "South-American ant eater. Two species." }
        { "anaconda" "South-American constrictor snake. Scaly." }
    } assoc-union! ]
  } {
    "Numbers"
    $[ <linked-hash> {
        { "one" 1 }
        { "two" 2 }
        { "three" 3 }
    } assoc-union! ]
  }
}

CONSTANT: construct-omap-str """# Explicitly typed ordered map (dictionary).
Bestiary: !!omap
  - aardvark: African pig-like ant eater. Ugly.
  - anteater: South-American ant eater. Two species.
  - anaconda: South-American constrictor snake. Scaly.
  # Etc.
# Flow style
Numbers: !!omap [ one: 1, two: 2, three : 3 ]
"""

${ construct-omap-obj } [ $ construct-omap-str yaml> ] unit-test
${ construct-omap-obj } [ construct-omap-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-pairs
CONSTANT: construct-pairs-obj H{
  {
    "Block tasks" {
      { "meeting" "with team." }
      { "meeting" "with boss." }
      { "break" "lunch." }
      { "meeting" "with client." }
    }
  } {
    "Flow tasks" {
      { "meeting" "with team" } { "meeting" "with boss" }
    }
  }
}

CONSTANT: construct-pairs-str """# Explicitly typed pairs.
Block tasks: !!pairs
  - meeting: with team.
  - meeting: with boss.
  - break: lunch.
  - meeting: with client.
Flow tasks: !!pairs [ meeting: with team, meeting: with boss ]
"""

CONSTANT: construct-pairs-obj-roundtripped H{
  {
    "Block tasks" {
      H{ { "meeting" "with team." } }
      H{ { "meeting" "with boss." } }
      H{ { "break" "lunch." } }
      H{ { "meeting" "with client." } }
    }
  } {
    "Flow tasks" {
      H{ { "meeting" "with team" } } H{ { "meeting" "with boss" } }
    }
  }
}

${ construct-pairs-obj } [ $ construct-pairs-str yaml> ] unit-test
${ construct-pairs-obj } [ $ construct-pairs-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-timestamp
! TODO what to do with timestamp ?
! CONSTANT: construct-timestamp-obj f
! 
! CONSTANT: construct-timestamp-str """canonical:        2001-12-15T02:59:43.1Z
! valid iso8601:    2001-12-14t21:59:43.10-05:00
! space separated:  2001-12-14 21:59:43.10 -5
! no time zone (Z): 2001-12-15 2:59:43.10
! date (00:00:00Z): 2002-12-14
! """
! 
! ${ construct-timestamp-obj } [ $ construct-timestamp-str yaml> ] unit-test
! ${ construct-timestamp-obj } [ $ construct-timestamp-obj >yaml yaml> ] unit-test

! !!!!!!!!!!!!!!!
! construct-value
! TODO: find something better to do with '=' ? see http://yaml.org/type/value.html
! Maybe a global parameter to replace all maps with their default values ? See pyyaml SafeConstructor
CONSTANT: construct-value-obj {
    H{ { "link with" { "library1.dll" "library2.dll" } } }
    H{ {
        "link with" {
            H{ { "=" "library1.dll" } { "version" 1.2 } }
            H{ { "=" "library2.dll" } { "version" 2.3 } }
        }
    } }
}

CONSTANT: construct-value-str """---     # Old schema
link with:
  - library1.dll
  - library2.dll
---     # New schema
link with:
  - = : library1.dll
    version: 1.2
  - = : library2.dll
    version: 2.3
"""

${ construct-value-obj } [ $ construct-value-str yaml-docs> ] unit-test
${ construct-value-obj } [ $ construct-value-obj >yaml-docs yaml-docs> ] unit-test

! !!!!!!!!!!!!!!!
! errors

[ "- foo\n:)" yaml> ] [ libyaml-parser-error? ] must-fail-with
[ "- &foo 1\n- *baz\n" yaml> ] [ yaml-undefined-anchor? ] must-fail-with
[ "" yaml> ] [ yaml-no-document? ] must-fail-with
