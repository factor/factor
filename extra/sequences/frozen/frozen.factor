! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors sequences ;
IN: sequences.frozen

TUPLE: frozen < sequence-view ;

C: <frozen> frozen

INSTANCE: frozen immutable-sequence
