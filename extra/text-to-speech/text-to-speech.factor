! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators command-line generic io kernel math
math.text.english namespaces present sequences splitting
strings system ui.operations ui.operations.syntax vocabs ;

IN: text-to-speech

! 1. "say"
! 2. festival, freetts, gnuspeech, espeech, flite, etc.
! 3. core-audio?
! 4. use google-translate-tts, download and play?

HOOK: speak-text os ( str -- )

{
    { [ os macos?  ] [ "text-to-speech.macos"  ] }
    { [ os linux?   ] [ "text-to-speech.linux"   ] }
    { [ os windows? ] [ "text-to-speech.windows" ] }
} cond require

GENERIC: speak ( obj -- )

M: object speak present speak-text ;

M: integer speak number>text speak-text ;

OPERATION: speak [ \ present ?lookup-method ] H{ }

: speak-main ( -- )
    command-line get [
        [ speak ] each-line
    ] [
        join-words speak
    ] if-empty ;

MAIN: speak-main
