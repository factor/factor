! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: google.translate system text-to-speech windows.winmm ;

IN: text-to-speech.windows

M: windows speak-text
    translate-tts open-command play-command close-command ;
