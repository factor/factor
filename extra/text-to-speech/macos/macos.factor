! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: formatting io.launcher system text-to-speech ;

IN: text-to-speech.macos

M: macos speak-text
    "say \"%s\"" sprintf try-process ;
