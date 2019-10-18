! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.

! This example requires Mac OS X. It has only been tested on
! 10.4. It must be run from a Factor runtime linked against the
! Cocoa library; you can obtain one with the 'macosx-sdl' target
! in the Makefile.

IN: cocoa-speech
USING: alien compiler kernel objective-c sequences words ;

! Define classes and messages
OBJC-MESSAGE: id alloc ;
OBJC-CLASS: NSString
: NSASCIIStringEncoding 1 ; inline
OBJC-MESSAGE: id initWithCString: char* encoding: uint ;
OBJC-CLASS: NSSpeechSynthesizer
OBJC-MESSAGE: id initWithVoice: id ;
OBJC-MESSAGE: bool startSpeakingString: id ;

! A utility
: <NSString> ( string -- alien )
    NSString [alloc]
    swap NSASCIIStringEncoding [initWithCString:encoding:] ;

! As usual, alien invoke words need to be compiled
"cocoa-speech" words [ try-compile ] each

! A utility
: <NSSpeechSynthesizer> ( voice -- synth )
    NSSpeechSynthesizer [alloc] swap [initWithVoice:] ;

! Call the TTS API
f <NSSpeechSynthesizer>
"Hello from Factor" <NSString>
[startSpeakingString:]
