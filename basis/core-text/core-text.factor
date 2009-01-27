! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax kernel
destructors words parser accessors fry words hashtables
sequences memoize assocs math math.functions locals init
namespaces colors core-foundation core-foundation.strings
core-foundation.attributed-strings core-foundation.utilities
core-graphics core-graphics.types ;
IN: core-text

TYPEDEF: void* CTLineRef
TYPEDEF: void* CTFontRef
TYPEDEF: void* CTFontDescriptorRef

<<

: C-GLOBAL:
    CREATE-WORD
    dup name>> '[ _ f dlsym *void* ]
    (( -- value )) define-declared ; parsing

>>

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

C-GLOBAL: kCTFontAttributeName
C-GLOBAL: kCTKernAttributeName
C-GLOBAL: kCTLigatureAttributeName
C-GLOBAL: kCTForegroundColorAttributeName
C-GLOBAL: kCTParagraphStyleAttributeName
C-GLOBAL: kCTUnderlineStyleAttributeName
C-GLOBAL: kCTVerticalFormsAttributeName
C-GLOBAL: kCTGlyphInfoAttributeName

FUNCTION: CTLineRef CTLineCreateWithAttributedString ( CFAttributedStringRef string ) ;

FUNCTION: void CTLineDraw ( CTLineRef line, CGContextRef context ) ;

FUNCTION: CGFloat CTLineGetOffsetForStringIndex ( CTLineRef line, CFIndex charIndex, CGFloat* secondaryOffset ) ;

FUNCTION: CFIndex CTLineGetStringIndexForPosition ( CTLineRef line, CGPoint position ) ;

FUNCTION: double CTLineGetTypographicBounds ( CTLineRef line, CGFloat* ascent, CGFloat* descent, CGFloat* leading ) ;

FUNCTION: CGRect CTLineGetImageBounds ( CTLineRef line, CGContextRef context ) ;

FUNCTION: CTFontRef CTFontCreateCopyWithSymbolicTraits (
   CTFontRef font,
   CGFloat size,
   CGAffineTransform* matrix,
   uint32_t symTraitValue,
   uint32_t symTraitMask
) ;

: <CTLine> ( string font color -- line )
    [
        [
            kCTForegroundColorAttributeName set
            kCTFontAttributeName set
        ] H{ } make-assoc <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString
    ] with-destructors ;

TUPLE: typographic-bounds width ascent descent leading ;

: line-typographic-bounds ( line -- typographic-bounds )
    0 <CGFloat> 0 <CGFloat> 0 <CGFloat>
    [ CTLineGetTypographicBounds ] 3keep [ *CGFloat ] tri@
    typographic-bounds boa ;

TUPLE: line string font line bounds dim bitmap age refs disposed ;

: bounds>dim ( bounds -- dim )
    [ width>> ] [ [ ascent>> ] [ descent>> ] bi + ] bi
    [ ceiling >fixnum ]
    bi@ 2array ;

:: draw-line ( line bounds context -- )
    context 0.0 bounds descent>> CGContextSetTextPosition
    line context CTLineDraw ;

: <line> ( string font -- line )
    [
        CFRetain |CFRelease
        2dup white <CTLine> |CFRelease
        dup line-typographic-bounds
        dup bounds>dim 3dup [ draw-line ] with-bitmap-context
        0 0 f line boa
    ] with-destructors ;

M: line dispose* line>> CFRelease ;

: ref/unref-line ( line n -- )
    '[ _ + ] change-refs 0 >>age drop ;

: ref-line ( line -- ) 1 ref/unref-line ;
: unref-line ( line -- ) -1 ref/unref-line ;

SYMBOL: cached-lines

: cached-line ( string font -- line )
    cached-lines get [ <line> ] 2cache ;

CONSTANT: max-line-age 5

: age ( obj -- ? )
    [ 1+ ] change-age age>> max-line-age >= ;

: age-line ( line -- ? )
    #! Outputs t whether the line is dead.
    dup refs>> 0 = [ age ] [ drop f ] if ;

: age-assoc ( assoc quot -- assoc' )
    '[ nip @ ] assoc-partition
    [ values dispose-each ] dip ;

: age-lines ( -- )
    cached-lines global [ [ age-line ] age-assoc ] change-at ;

[ H{ } clone cached-lines set-global ] "core-text" add-init-hook