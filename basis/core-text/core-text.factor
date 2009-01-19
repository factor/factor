! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax kernel destructors
parser accessors fry words
core-foundation core-foundation.strings
core-foundation.attributed-strings ;
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
