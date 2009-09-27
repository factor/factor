! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax assocs core-foundation
core-foundation.dictionaries core-foundation.strings
core-graphics.types core-text.utilities destructors init
kernel math memoize fonts combinators unix.types ;
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

C-GLOBAL: kCTFontSymbolicTrait
C-GLOBAL: kCTFontWeightTrait
C-GLOBAL: kCTFontWidthTrait
C-GLOBAL: kCTFontSlantTrait

C-GLOBAL: kCTFontNameAttribute
C-GLOBAL: kCTFontDisplayNameAttribute
C-GLOBAL: kCTFontFamilyNameAttribute
C-GLOBAL: kCTFontStyleNameAttribute
C-GLOBAL: kCTFontTraitsAttribute
C-GLOBAL: kCTFontVariationAttribute
C-GLOBAL: kCTFontSizeAttribute
C-GLOBAL: kCTFontMatrixAttribute
C-GLOBAL: kCTFontCascadeListAttribute
C-GLOBAL: kCTFontCharacterSetAttribute
C-GLOBAL: kCTFontLanguagesAttribute
C-GLOBAL: kCTFontBaselineAdjustAttribute
C-GLOBAL: kCTFontMacintoshEncodingsAttribute
C-GLOBAL: kCTFontFeaturesAttribute
C-GLOBAL: kCTFontFeatureSettingsAttribute
C-GLOBAL: kCTFontFixedAdvanceAttribute
C-GLOBAL: kCTFontOrientationAttribute

FUNCTION: CTFontDescriptorRef CTFontDescriptorCreateWithAttributes (
   CFDictionaryRef attributes
) ;

FUNCTION: CTFontRef CTFontCreateWithName (
   CFStringRef name,
   CGFloat size,
   CGAffineTransform* matrix
) ;

FUNCTION: CTFontRef CTFontCreateWithFontDescriptor (
   CTFontDescriptorRef descriptor,
   CGFloat size,
   CGAffineTransform* matrix
) ;

FUNCTION: CTFontRef CTFontCreateCopyWithSymbolicTraits (
   CTFontRef font,
   CGFloat size,
   CGAffineTransform* matrix,
   uint32_t symTraitValue,
   uint32_t symTraitMask
) ;

FUNCTION: CGFloat CTFontGetAscent ( CTFontRef font ) ;

FUNCTION: CGFloat CTFontGetDescent ( CTFontRef font ) ;

FUNCTION: CGFloat CTFontGetLeading ( CTFontRef font ) ;

FUNCTION: CGFloat CTFontGetCapHeight ( CTFontRef font ) ;

FUNCTION: CGFloat CTFontGetXHeight ( CTFontRef font ) ;

CONSTANT: font-names
    H{
        { "monospace" "Monaco" }
        { "sans-serif" "Lucida Grande" }
        { "serif" "Times" }
    }

: font-name ( string -- string' )
    font-names ?at drop ;

: (bold) ( x -- y ) kCTFontBoldTrait bitor ; inline

: (italic) ( x -- y ) kCTFontItalicTrait bitor ; inline

: font-traits ( font -- n )
    [ 0 ] dip
    [ bold?>> [ (bold) ] when ]
    [ italic?>> [ (italic) ] when ] bi ;

: apply-font-traits ( font style -- font' )
    [ drop ] [ [ 0.0 f ] dip font-traits dup ] 2bi
    CTFontCreateCopyWithSymbolicTraits
    dup [ [ CFRelease ] dip ] [ drop ] if ;

MEMO: (cache-font) ( font -- open-font )
    [
        [
            [ name>> font-name <CFString> &CFRelease ] [ size>> ] bi
            f CTFontCreateWithName
        ] keep apply-font-traits
    ] with-destructors ;

: cache-font ( font -- open-font )
    strip-font-colors (cache-font) ;

MEMO: (cache-font-metrics) ( font -- metrics )
    [ metrics new ] dip
    (cache-font) {
        [ CTFontGetAscent >>ascent ]
        [ CTFontGetDescent >>descent ]
        [ CTFontGetLeading >>leading ]
        [ CTFontGetCapHeight >>cap-height ]
        [ CTFontGetXHeight >>x-height ]
    } cleave
    compute-height ;

: cache-font-metrics ( font -- metrics )
    strip-font-colors (cache-font-metrics) ;

[
    \ (cache-font) reset-memoized
    \ (cache-font-metrics) reset-memoized
] "core-text.fonts" add-init-hook
