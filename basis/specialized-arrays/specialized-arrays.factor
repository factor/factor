! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences vocabs vocabs.loader ;
IN: specialized-arrays

MIXIN: specialized-array
INSTANCE: specialized-array sequence

GENERIC: direct-array-syntax ( obj -- word )

"prettyprint" vocab [
    "specialized-arrays.prettyprint" require
] when
