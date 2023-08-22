! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.classes core-foundation.strings ;
IN: core-foundation.fonts

: all-font-families ( -- seq )
    NSFontManager -> sharedFontManager -> availableFontFamilies CF>string-array ;

: all-fonts ( -- seq )
    NSFontManager -> sharedFontManager -> availableFonts CF>string-array ;
