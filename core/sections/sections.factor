! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry io.directories io.files.types io.pathnames
kernel sequences sequences.extras sets splitting system vocabs
words ;
IN: sections

! <{ private linux }
! { private linux }>
! <private <linux linux> private>
! <"private" <"linux" "linux"> "private">

MIXIN: section

SINGLETON: private
SINGLETON: 32-bit
SINGLETON: 64-bit

INSTANCE: private section

INSTANCE: unix section
INSTANCE: linux section
INSTANCE: macosx section
INSTANCE: freebsd section

INSTANCE: x86 section
INSTANCE: arm section

INSTANCE: 32-bit section
INSTANCE: 64-bit section

: word-sections ( word -- hs ) "sections" word-prop ;

: add-word-section ( obj word -- ) word-sections adjoin ;

: remove-word-section ( obj word -- ) word-sections delete ;

: in-section? ( obj word -- ? ) word-sections member? ;

: private-words ( vocab -- words )
    vocab-words [ word-sections private swap in? ] filter ;

: vocab-entries ( vocab -- entries )
    vocab-path qualified-directory-entries ;

: vocab-section-paths ( vocab -- paths )
    [
        vocab-entries
        [ type>> +regular-file+ = ] filter
        [ name>> ] map
        [ ".factor" tail? ] filter
    ] [ vocab-name ] bi
    '[ file-stem _ head? ] filter ;

: vocab>section-paths ( vocab -- assoc )
    [ vocab-section-paths ]
    [ vocab-name ] bi
    '[ file-stem _ ?head drop "-" ?head drop "," split harvest ] map-zip ;