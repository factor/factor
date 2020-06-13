! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences sets system vocabs words ;
IN: sections

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