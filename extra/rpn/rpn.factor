! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel lists math math.parser
sequences splitting ;
IN: rpn

SINGLETONS: add-insn sub-insn mul-insn div-insn ;
TUPLE: push-insn value ;

GENERIC: eval-insn ( stack insn -- stack )

: binary-op ( stack quot: ( x y -- z ) -- stack )
    [ uncons uncons ] dip dip cons ; inline

M: add-insn eval-insn drop [ + ] binary-op ;
M: sub-insn eval-insn drop [ - ] binary-op ;
M: mul-insn eval-insn drop [ * ] binary-op ;
M: div-insn eval-insn drop [ / ] binary-op ;
M: push-insn eval-insn value>> swons ;

: rpn-tokenize ( string -- string' )
    " " split harvest sequence>list ;

: rpn-parse ( string -- tokens )
    rpn-tokenize [
        {
            { "+" [ add-insn ] }
            { "-" [ sub-insn ] }
            { "*" [ mul-insn ] }
            { "/" [ div-insn ] }
            [ string>number push-insn boa ]
        } case
    ] lmap ;

: print-stack ( list -- )
    [ number>string print ] leach ;

: rpn-eval ( tokens -- )
    nil [ eval-insn ] foldl print-stack ;

: rpn ( -- )
    "RPN> " write flush
    readln [ rpn-parse rpn-eval rpn ] when* ;

MAIN: rpn
