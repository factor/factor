! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax kernel destructors
parser accessors fry words hashtables sequences math math.functions locals
core-foundation core-foundation.strings
core-foundation.attributed-strings
core-graphics core-graphics.types ;
IN: core-text

TYPEDEF: void* CTLineRef
TYPEDEF: void* CTFontRef

FUNCTION: CTFontRef CTFontCreateWithName (
   CFStringRef name,
   CGFloat size,
   CGAffineTransform* matrix
) ;

: <CTFont> ( name size -- font )
    [
        [ <CFString> &CFRelease ] dip f CTFontCreateWithName
    ] with-destructors ;

<<

: C-GLOBAL:
    CREATE-WORD
    dup name>> '[ _ f dlsym *void* ]
    (( -- value )) define-declared ; parsing

>>

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

: <CTLine> ( string font -- line )
    [
        kCTFontAttributeName associate <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString
    ] with-destructors ;

TUPLE: typographic-bounds width ascent descent leading ;

: line-typographic-bounds ( line -- typographic-bounds )
    0 <CGFloat> 0 <CGFloat> 0 <CGFloat>
    [ CTLineGetTypographicBounds ] 3keep [ *CGFloat ] tri@
    typographic-bounds boa ;

TUPLE: line string font line bounds dim bitmap disposed ;

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
        2dup <CTLine> |CFRelease
        dup line-typographic-bounds
        dup bounds>dim 3dup [ draw-line ] with-bitmap-context
        f line boa
    ] with-destructors ;

M: line dispose*
    [
        [ font>> &CFRelease drop ]
        [ line>> &CFRelease drop ] bi
    ] with-destructors ;