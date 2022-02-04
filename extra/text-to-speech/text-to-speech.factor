! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators command-line generic io kernel math
math.text.english namespaces present sequences splitting
strings system ui.operations vocabs ;

IN: text-to-speech

! 1. "say"
! 2. festival, freetts, gnuspeech, espeech, flite, etc.
! 3. core-audio?
! 4. use google-translate-tts, download and play?

HOOK: speak-text os ( str -- )

USE-LINUX: text-to-speech.linux
USE-MACOSX: text-to-speech.macosx
USE-WINDOWS: text-to-speech.windows

GENERIC: speak ( obj -- )

M: object speak present speak-text ;

M: integer speak number>text speak-text ;

[ \ present ?lookup-method ] \ speak H{ } define-operation

: speak-main ( -- )
    command-line get [
        [ speak ] each-line
    ] [
        join-words speak
    ] if-empty ;

MAIN: speak-main
