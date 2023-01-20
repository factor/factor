! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: backtrack kernel prettyprint sequences splitting ;
IN: rosetta-code.amb

! https://rosettacode.org/wiki/Amb

! Define and give an example of the Amb operator.

! The Amb operator takes some number of expressions (or values
! if that's simpler in the language) and nondeterministically
! yields the one or fails if given no parameter, amb returns the
! value that doesn't lead to failure.

! The example is using amb to choose four words from the following strings:

! set 1: "the" "that" "a"
! set 2: "frog" "elephant" "thing"
! set 3: "walked" "treaded" "grows"
! set 4: "slowly" "quickly"

! It is a failure if the last character of word 1 is not equal
! to the first character of word 2, and similarly with word 2 and
! word 3, as well as word 3 and word 4. (the only successful
! sentence is "that thing grows slowly").

CONSTANT: words {
    { "the" "that" "a" }
    { "frog" "elephant" "thing" }
    { "walked" "treaded" "grows" }
    { "slowly" "quickly"  }
}

: letters-match? ( str1 str2 -- ? ) [ last ] [ first ] bi* = ;

: sentence-match? ( seq -- ? ) dup rest [ letters-match? ] 2all? ;

: select ( seq -- seq' ) [ amb-lazy ] map ;

: search ( -- )
    words select dup sentence-match? [ join-words ] [ fail ] if . ;

MAIN: search
