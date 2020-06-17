! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry io.directories io.files.types
io.pathnames kernel sequences sequences.extras sets splitting
system vocabs words ;
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
    [ head? ] curry
    [ file-stem ] prepose filter ;

: vocab/stem>sections ( vocab stem -- sections )
    ?head drop "-" ?head drop "," split harvest ;

: vocab>section-paths ( vocab -- assoc )
    [ vocab-section-paths ]
    [ vocab-name ] bi
    [ vocab/stem>sections ] curry
    [ file-stem ] prepose map-zip ;

HOOK: platform-sections os ( -- seq )
M: linux platform-sections { "linux" "unix" } ;
M: macosx platform-sections { "macosx" "unix" } ;
M: freebsd platform-sections { "freebsd" "unix" } ;

: default-load-sections ( -- seq )
    platform-sections { "docs" "private" } append ;

: default-test-sections ( -- seq )
    platform-sections { "docs" "private" "tests" } append ;

: default-use-sections ( -- seq )
    platform-sections { "docs" "tests" } append ;

: load-section-file? ( required-sections -- ? )
    default-load-sections diff empty? ;

: vocab>loadable-paths ( vocab -- paths )
    vocab>section-paths
    [ nip load-section-file? ] assoc-filter keys ;