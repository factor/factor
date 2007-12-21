! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: bit-arrays kernel lazy-lists math math.functions math.ranges sequences ;
IN: math.erato

TUPLE: erato limit bits latest ;

<PRIVATE

: mark-multiples ( n erato -- )
  over sqrt over erato-limit <=
  [
    [ erato-limit over <range> ] keep
    erato-bits [ set-nth ] curry f -rot curry* each
  ] [
    2drop
  ] if ;

PRIVATE>

: <erato> ( n -- erato )
  dup 1 + <bit-array> 1 over set-bits erato construct-boa ;

: next-prime ( erato -- prime/f )
  [ erato-latest 1+ ] keep [ set-erato-latest ] 2keep
  2dup erato-limit <=
  [
    2dup erato-bits nth [ dupd mark-multiples ] [ nip next-prime ] if
  ] [
    2drop f
  ] if ;

: lerato ( n -- lazy-list )
  <erato> [ next-prime ] keep [ nip next-prime ] curry lfrom-by [ ] lwhile ;
