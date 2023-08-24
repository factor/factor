! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs classes classes.tuple
classes.tuple.private kernel math sequences sequences.private
slots.private ;

IN: named-tuples

MIXIN: named-tuple

M: named-tuple assoc-size tuple-size ;

M: named-tuple at*
    [ nip ] [ ?offset-of-slot ] 2bi [ slot t ] [ drop f f ] if* ;

M: named-tuple set-at set-slot-named ;

M: named-tuple >alist
    dup class-of all-slots
    [ [ offset>> slot ] [ name>> ] bi swap ] with { } map>assoc ;

INSTANCE: named-tuple assoc

M: named-tuple length tuple-size ;

M: named-tuple nth-unsafe
    [ integer>fixnum ] dip array-nth ;

M: named-tuple set-nth-unsafe
    [ integer>fixnum ] dip set-array-nth ;

M: named-tuple like class-of slots>tuple ;

INSTANCE: named-tuple sequence

