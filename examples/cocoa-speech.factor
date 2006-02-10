! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.

! This example requires Mac OS X. It has only been tested on
! 10.4. It must be run from a Factor runtime linked against the
! Cocoa library; you can obtain one with the 'macosx-sdl' target
! in the Makefile.

IN: cocoa-speech
USING: cocoa kernel objc-NSObject objc-NSSpeechSynthesizer ;

: say ( string -- )
    NSSpeechSynthesizer [alloc] f [initWithVoice:]
    swap <NSString> [startSpeakingString:] ;

"Hello from Factor" say
