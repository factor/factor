! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs vocabs.loader kernel ;
IN: bootstrap.threads

USE: io.thread
USE: threads

"debugger" vocab [
    "debugger.threads" require
] when
