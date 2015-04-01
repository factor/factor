! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators generic kernel math math.text.english present
strings system ui.operations vocabs ;

IN: text-to-speech

! 1. "say"
! 2. festival, freetts, gnuspeech, espeech, flite, etc.
! 3. core-audio?
! 4. use google-translate-tts, download and play?

HOOK: speak-text os ( str -- )

{
    { [ os macosx?  ] [ "text-to-speech.macosx"  ] }
    { [ os linux?   ] [ "text-to-speech.linux"   ] }
    { [ os windows? ] [ "text-to-speech.windows" ] }
} cond require

GENERIC: speak ( obj -- )

M: object speak present speak-text ;

M: integer speak number>text speak-text ;

[ \ present ?lookup-method ] \ speak H{ } define-operation
