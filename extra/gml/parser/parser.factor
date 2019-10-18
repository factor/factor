! Copyright (C) 2010 Slava Pestov.
USING: accessors kernel arrays strings math.parser peg peg.ebnf
multiline gml.types gml.runtime sequences sequences.deep locals
combinators math ;
IN: gml.parser

TUPLE: comment string ;

C: <comment> comment

: register-index ( name registers -- n )
    2dup index dup [ 2nip ] [ drop [ nip length ] [ push ] 2bi ] if ;

: resolve-register ( insn registers -- )
    [ dup name>> ] dip register-index >>n drop ;

ERROR: missing-usereg ;

:: (resolve-registers) ( array registers -- ? )
    f :> use-registers!
    array [
        {
            { [ dup use-registers? ] [ use-registers! ] }
            { [ dup read-register? ] [ registers resolve-register ] }
            { [ dup exec-register? ] [ registers resolve-register ] }
            { [ dup write-register? ] [ registers resolve-register ] }
            { [ dup proc? ] [
                dup [ use-registers? ] any? [ drop ] [
                    array>> registers (resolve-registers) drop
                ] if
            ] }
            [ drop ]
        } cond
    ] each
    use-registers ;

:: resolve-registers ( array -- )
    V{ } clone :> registers
    array [ use-registers? ] any? [
        array registers (resolve-registers)
        registers length >>n drop
    ] when ;

: parse-proc ( array -- proc )
    >array [ resolve-registers ] [ { } <proc> ] bi ;

ERROR: bad-vector-length seq n ;

: parse-vector ( seq -- vec )
    dup length {
        { 2 [ first2 <vec2d> ] }
        { 3 [ first3 <vec3d> ] }
        [ bad-vector-length ]
    } case ;

EBNF: parse-gml [=[

Letter = [a-zA-Z]
Digit = [0-9]
Digits = Digit+

Sign = ('+' => [[ first ]]|'-' => [[ first ]])?

StopChar = ('('|')'|'['|']'|'{'|'}'|'/'|'/'|';'|':'|'!'|'.')

Space = [ \t\n\r]

Spaces = Space* => [[ ignore ]]

Newline = [\n\r]

Number = Sign Digit+ ('.' => [[ first ]] Digit+)? ('e' => [[ first ]] Sign Digit+)?
    => [[ flatten sift >string string>number ]]

VectorComponents = (Number:f Spaces ',' Spaces => [[ f ]])*:fs Number:f Spaces => [[ fs f suffix ]]

Vector = '(' Spaces VectorComponents ')' => [[ second parse-vector ]]

StringChar = !('"').

String = '"' StringChar+:s '"' => [[ s >string ]]

NameChar = !(Space|StopChar).

Name = NameChar+ => [[ >string ]]

Comment = ('%' (!(Newline) .)* (Newline|!(.))) => [[ <comment> ]]

ArrayStart = '[' => [[ marker ]]

ArrayEnd = ']' => [[ exec" ]" ]]

ExecArray = '{' Token*:ts Spaces '}' => [[ ts parse-proc ]]

LiteralName = '/' Name:n => [[ n >gml-name ]]

UseReg = "usereg" !(NameChar) => [[ <use-registers> ]]

ReadReg = ";" Name:n => [[ n <read-register> ]]
ExecReg = ":" Name:n => [[ n <exec-register> ]]
WriteReg = "!" Name:n => [[ n <write-register> ]]

ExecName = Name:n => [[ n >gml-exec-name ]]

PathNameComponent = "." Name:n => [[ n >gml-name ]]
PathName = PathNameComponent+ => [[ <pathname> ]]

Token = Spaces
    (Comment |
     Number |
     Vector |
     String |
     ArrayStart |
     ArrayEnd |
     ExecArray |
     LiteralName |
     UseReg |
     ReadReg |
     ExecReg |
     WriteReg |
     ExecName |
     PathName)

Tokens = Token* => [[ [ comment? ] reject ]]

Program = Tokens Spaces !(.) => [[ parse-proc ]]

]=]
