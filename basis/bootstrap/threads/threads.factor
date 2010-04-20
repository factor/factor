! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs.loader kernel io.thread threads
compiler.utilities namespaces ;
IN: bootstrap.threads

{ "bootstrap.threads" "debugger" } "debugger.threads" require-when

[ yield ] yield-hook set-global
