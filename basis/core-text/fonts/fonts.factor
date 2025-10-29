! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax assocs combinators
core-foundation core-foundation.dictionaries
core-foundation.strings core-graphics.types destructors fonts
init kernel math memoize namespaces opengl unix.types ;
IN: core-text.fonts

TYPEDEF: void* CTFontRef
TYPEDEF: void* CTFontDescriptorRef

! CTFontSymbolicTraits
: kCTFontItalicTrait ( -- n ) 0 2^ ; inline
: kCTFontBoldTrait ( -- n ) 1 2^ ; inline
: kCTFontExpandedTrait ( -- n ) 5 2^ ; inline
: kCTFontCondensedTrait ( -- n ) 6 2^ ; inline
: kCTFontMonoSpaceTrait ( -- n ) 10 2^ ; inline
: kCTFontVerticalTrait ( -- n ) 11 2^ ; inline
: kCTFontUIOptimizedTrait ( -- n ) 12 2^ ; inline

C-GLOBAL: CFStringRef kCTFontSymbolicTrait
C-GLOBAL: CFStringRef kCTFontWeightTrait
C-GLOBAL: CFStringRef kCTFontWidthTrait
C-GLOBAL: CFStringRef kCTFontSlantTrait

C-GLOBAL: CFStringRef kCTFontNameAttribute
C-GLOBAL: CFStringRef kCTFontDisplayNameAttribute
C-GLOBAL: CFStringRef kCTFontFamilyNameAttribute
C-GLOBAL: CFStringRef kCTFontStyleNameAttribute
C-GLOBAL: CFStringRef kCTFontTraitsAttribute
C-GLOBAL: CFStringRef kCTFontVariationAttribute
C-GLOBAL: CFStringRef kCTFontSizeAttribute
C-GLOBAL: CFStringRef kCTFontMatrixAttribute
C-GLOBAL: CFStringRef kCTFontCascadeListAttribute
C-GLOBAL: CFStringRef kCTFontCharacterSetAttribute
C-GLOBAL: CFStringRef kCTFontLanguagesAttribute
C-GLOBAL: CFStringRef kCTFontBaselineAdjustAttribute
C-GLOBAL: CFStringRef kCTFontMacintoshEncodingsAttribute
C-GLOBAL: CFStringRef kCTFontFeaturesAttribute
C-GLOBAL: CFStringRef kCTFontFeatureSettingsAttribute
C-GLOBAL: CFStringRef kCTFontFixedAdvanceAttribute
C-GLOBAL: CFStringRef kCTFontOrientationAttribute

FUNCTION: CTFontDescriptorRef CTFontDescriptorCreateWithAttributes (
   CFDictionaryRef attributes
)

FUNCTION: CTFontRef CTFontCreateWithName (
   CFStringRef name,
   CGFloat size,
   CGAffineTransform* matrix
)

FUNCTION: CTFontRef CTFontCreateWithFontDescriptor (
   CTFontDescriptorRef descriptor,
   CGFloat size,
   CGAffineTransform* matrix
)

FUNCTION: CTFontRef CTFontCreateCopyWithSymbolicTraits (
   CTFontRef font,
   CGFloat size,
   CGAffineTransform* matrix,
   uint32_t symTraitValue,
   uint32_t symTraitMask
)

FUNCTION: CGFloat CTFontGetAscent ( CTFontRef font )

FUNCTION: CGFloat CTFontGetDescent ( CTFontRef font )

FUNCTION: CGFloat CTFontGetLeading ( CTFontRef font )

FUNCTION: CGFloat CTFontGetCapHeight ( CTFontRef font )

FUNCTION: CGFloat CTFontGetXHeight ( CTFontRef font )

CONSTANT: font-names
    H{
        { "monospace" "Menlo" }
        { "sans-serif" "LucidaGrande" }
        { "serif" "Times" }
    }

: font-name ( string -- string' )
    font-names ?at drop ;

: font-traits ( font -- n )
    [ 0 ] dip
    [ bold?>> [ kCTFontBoldTrait bitor ] when ]
    [ italic?>> [ kCTFontItalicTrait bitor ] when ] bi ;

MEMO:: (cache-font) ( name size traits -- open-font )
    [
        name font-name <CFString> &CFRelease
        size f CTFontCreateWithName dup
        0.0 f traits dup CTFontCreateCopyWithSymbolicTraits
        [ [ CFRelease ] dip ] when*
    ] with-destructors ;

: cache-font ( font -- open-font )
    [ name>> ]
    [ size>> gl-scale-factor get-global [ * ] when* ]
    [ font-traits ] tri (cache-font) ;

MEMO: (cache-font-metrics) ( name size traits -- metrics )
    [ metrics new ] 3dip
    (cache-font) {
        [ CTFontGetAscent >>ascent ]
        [ CTFontGetDescent >>descent ]
        [ CTFontGetLeading >>leading ]
        [ CTFontGetCapHeight >>cap-height ]
        [ CTFontGetXHeight >>x-height ]
    } cleave
    compute-height ;

: cache-font-metrics ( font -- metrics )
    [ name>> ]
    [ size>> gl-scale-factor get-global [ * ] when* ]
    [ font-traits ] tri (cache-font-metrics) ;

STARTUP-HOOK: [
    \ (cache-font) reset-memoized
    \ (cache-font-metrics) reset-memoized
]
