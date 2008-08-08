! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: compiler.tree.intrinsics

: <immutable-tuple-boa> ( ... class -- tuple ) "Intrinsic" throw ;
