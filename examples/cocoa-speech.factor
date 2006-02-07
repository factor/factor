! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.

! This example requires Mac OS X. It has only been tested on
! 10.4. It must be run from a Factor runtime linked against the
! Cocoa library; you can obtain one with the 'macosx-sdl' target
! in the Makefile.

IN: cocoa-speech
USING: alien compiler kernel objc sequences words ;

! Define classes and messages
: init-cocoa
    "NSObject" define-objc-class
    "NSString" define-objc-class
    "NSSpeechSynthesizer" define-objc-class ; parsing

init-cocoa

USING: objc-NSString objc-NSObject objc-NSSpeechSynthesizer ;

: NSASCIIStringEncoding 1 ; inline

! A utility
: <NSString> ( string -- alien )
    NSString [alloc]
    swap NSASCIIStringEncoding [initWithCString:encoding:] ;

! A utility
: <NSSpeechSynthesizer> ( voice -- synth )
    NSSpeechSynthesizer [alloc] swap [initWithVoice:] ;

! Call the TTS API
: speech-test
    f <NSSpeechSynthesizer>
    "Hello from Factor" <NSString>
    [startSpeakingString:] ;

! As usual, alien invoke words need to be compiled
"cocoa-speech" words [ try-compile ] each

speech-test
