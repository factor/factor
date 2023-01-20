! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io io.encodings.utf8 io.launcher system text-to-speech ;

IN: text-to-speech.linux

M: linux speak-text
    "festival --tts" utf8 [ print ] with-process-writer ;
