! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs vocabs.loader kernel io.thread threads
compiler.utilities namespaces ;
IN: bootstrap.threads

"debugger" vocab [
    "debugger.threads" require
] when

[ yield ] yield-hook set-global