! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.

IN: cocoa-speech
USING: cocoa kernel objc-NSObject objc-NSSpeechSynthesizer ;

: say ( string -- )
    NSSpeechSynthesizer [alloc] f [initWithVoice:]
    swap <NSString> [startSpeakingString:] ;

"Hello from Factor" say drop
