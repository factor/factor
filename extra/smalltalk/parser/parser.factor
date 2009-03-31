! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: peg peg.ebnf smalltalk.ast sequences sequences.deep strings
math.parser kernel arrays byte-arrays math assocs accessors ;
IN: smalltalk.parser

! Based on http://chronos-st.blogspot.com/2007/12/smalltalk-in-one-page.html

ERROR: bad-number str ;

: check-number ( str -- n )
    >string dup string>number [ ] [ bad-number ] ?if ;

EBNF: parse-smalltalk

Character = .
WhitespaceCharacter = (" " | "\t" | "\n" | "\r" )
DecimalDigit = [0-9]
Letter = [A-Za-z]

CommentCharacter = [^"] | '""' => [[ CHAR: " ]]
Comment = '"' (CommentCharacter)*:s '"' => [[ s >string ast-comment boa ]]

OptionalWhiteSpace = (WhitespaceCharacter | Comment)*
Whitespace = (WhitespaceCharacter | Comment)+

LetterOrDigit = DecimalDigit | Letter
Identifier = (Letter | "_"):h (LetterOrDigit | "_")*:t => [[ { h t } flatten >string ]]
Reference = Identifier => [[ ast-name boa ]]

ConstantReference =   "nil" => [[ nil ]]
                    | "false" => [[ f ]]
                    | "true" => [[ t ]]
PseudoVariableReference =   "self" => [[ self ]]
                          | "super" => [[ super ]]
ReservedIdentifier = PseudoVariableReference | ConstantReference

BindableIdentifier = Identifier

UnaryMessageSelector = Identifier

Keyword = Identifier:i ":" => [[ i ":" append ]]

KeywordMessageSelector = Keyword+ => [[ concat ]]
BinarySelectorChar =   "~" | "!" | "@" | "%" | "&" | "*" | "-" | "+"
                     | "=" | "|" | "\" | "<" | ">" | "," | "?" | "/"
BinaryMessageSelector = BinarySelectorChar+ => [[ concat ]]

OptionalMinus = ("-" => [[ CHAR: - ]])?
IntegerLiteral = (OptionalMinus:m UnsignedIntegerLiteral:i) => [[ i m [ neg ] when ]]
UnsignedIntegerLiteral =   Radix:r "r" BaseNIntegerLiteral:b => [[ b >string r base> ]]
                         | DecimalIntegerLiteral => [[ check-number ]]
DecimalIntegerLiteral = DecimalDigit+
Radix = DecimalIntegerLiteral => [[ check-number ]]
BaseNIntegerLiteral = LetterOrDigit+
FloatingPointLiteral = (OptionalMinus
                        DecimalIntegerLiteral
                        ("." => [[ CHAR: . ]] DecimalIntegerLiteral Exponent? | Exponent))
                        => [[ flatten check-number ]]
Exponent = "e" => [[ CHAR: e ]] (OptionalMinus DecimalIntegerLiteral)?

CharacterLiteral = "$" Character:c => [[ c ]]

StringLiteral = "'" (StringLiteralCharacter | "''" => [[ CHAR: ' ]])*:s "'"
                => [[ s >string ]]
StringLiteralCharacter = [^']

SymbolInArrayLiteral =   KeywordMessageSelector
                       | UnaryMessageSelector
                       | BinaryMessageSelector
SymbolLiteral = "#" (SymbolInArrayLiteral | StringLiteral):s => [[ s intern ]]

ArrayLiteral = (ObjectArrayLiteral | ByteArrayLiteral)
ObjectArrayLiteral = "#" NestedObjectArrayLiteral:elts => [[ elts ]]
NestedObjectArrayLiteral = "(" OptionalWhiteSpace
                           (LiteralArrayElement:h
                            (Whitespace LiteralArrayElement:e => [[ e ]])*:t
                            => [[ t h prefix ]]
                           )?:elts OptionalWhiteSpace ")" => [[ elts >array ]]

LiteralArrayElement =   Literal
                      | NestedObjectArrayLiteral
                      | SymbolInArrayLiteral
                      | ConstantReference

ByteArrayLiteral = "#[" OptionalWhiteSpace
                        (UnsignedIntegerLiteral:h
                         (Whitespace UnsignedIntegerLiteral:i => [[ i ]])*:t
                         => [[ t h prefix ]]
                        )?:elts OptionalWhiteSpace "]" => [[ elts >byte-array ]]

FormalBlockArgumentDeclaration = ":" BindableIdentifier:i => [[ i ]]
FormalBlockArgumentDeclarationList =
                FormalBlockArgumentDeclaration:h
                (Whitespace FormalBlockArgumentDeclaration:v => [[ v ]])*:t
                => [[ t h prefix ]]

BlockLiteral = "["
                (OptionalWhiteSpace
                 FormalBlockArgumentDeclarationList:args
                 OptionalWhiteSpace
                 "|"
                 => [[ args ]]
                )?:args
                ExecutableCode:body OptionalWhiteSpace
                "]" => [[ args >array body ast-block boa ]]

Literal = (ConstantReference
                | FloatingPointLiteral
                | IntegerLiteral
                | CharacterLiteral
                | StringLiteral
                | ArrayLiteral
                | SymbolLiteral
                | BlockLiteral)

NestedExpression = "(" Statement:s OptionalWhiteSpace ")" => [[ s ]]
Operand =       Literal
                | PseudoVariableReference
                | Reference
                | NestedExpression

UnaryMessage = UnaryMessageSelector
UnaryMessageOperand = UnaryMessageSend | Operand
UnaryMessageSend = UnaryMessageOperand:receiver
                   OptionalWhiteSpace UnaryMessageSelector:selector !(":")
                   => [[ receiver selector { } ast-message-send boa ]]

BinaryMessage = BinaryMessageSelector OptionalWhiteSpace BinaryMessageOperand
BinaryMessageOperand = BinaryMessageSend | UnaryMessageSend | Operand
BinaryMessageSend-1 = BinaryMessageOperand:lhs
                    OptionalWhiteSpace
                    BinaryMessageSelector:selector
                    OptionalWhiteSpace
                    UnaryMessageOperand:rhs
                    => [[ lhs selector { rhs } ast-message-send boa ]]
BinaryMessageSend = (BinaryMessageSend:lhs
                    OptionalWhiteSpace
                    BinaryMessageSelector:selector
                    OptionalWhiteSpace
                    UnaryMessageOperand:rhs
                    => [[ lhs selector { rhs } ast-message-send boa ]])
                    | BinaryMessageSend-1

KeywordMessageSegment = Keyword:k OptionalWhiteSpace BinaryMessageOperand:arg => [[ { k arg } ]]
KeywordMessageSend = (BinaryMessageSend | UnaryMessageSend | Operand):receiver
                     OptionalWhiteSpace
                     KeywordMessageSegment:h
                     (OptionalWhiteSpace KeywordMessageSegment:s => [[ s ]])*:t
                     => [[ receiver t h prefix unzip [ concat ] dip ast-message-send boa ]]

Expression = OptionalWhiteSpace
             (KeywordMessageSend | BinaryMessageSend | UnaryMessageSend | Operand):e
             => [[ e ]]

AssignmentOperation = OptionalWhiteSpace BindableIdentifier:i
                      OptionalWhiteSpace ":=" OptionalWhiteSpace => [[ i ast-name boa ]]
AssignmentStatement = AssignmentOperation:a Statement:s => [[ a s ast-assignment boa ]]
Statement = AssignmentStatement | Expression

MethodReturnOperator = OptionalWhiteSpace "^"
FinalStatement = (MethodReturnOperator Statement:s => [[ s ast-return boa ]])
                 | Statement

LocalVariableDeclarationList = OptionalWhiteSpace "|" OptionalWhiteSpace
                (BindableIdentifier:h
                 (Whitespace BindableIdentifier:b => [[ b ]])*:t
                 => [[ t h prefix ]]
                )?:b OptionalWhiteSpace "|" => [[ b >array ast-local-variables boa ]]

ExecutableCode = (LocalVariableDeclarationList)?
                 ((Statement:s OptionalWhiteSpace "." => [[ s ]])*
                 FinalStatement:f (".")? => [[ f ]])?
                 => [[ sift >array ]]

UnaryMethodHeader = UnaryMessageSelector:selector
                  => [[ { selector { } } ]]
BinaryMethodHeader = BinaryMessageSelector:selector OptionalWhiteSpace BindableIdentifier:identifier
                   => [[ { selector { identifier } } ]]
KeywordMethodHeaderSegment = Keyword:keyword
                             OptionalWhiteSpace
                             BindableIdentifier:identifier => [[ { keyword identifier } ]]
KeywordMethodHeader = KeywordMethodHeaderSegment:h (Whitespace KeywordMethodHeaderSegment:s => [[ s ]])*:t
                    => [[ t h prefix unzip [ concat ] dip 2array ]]
MethodHeader =   KeywordMethodHeader
               | BinaryMethodHeader
               | UnaryMethodHeader
MethodDeclaration = OptionalWhiteSpace "method" OptionalWhiteSpace MethodHeader:header
        OptionalWhiteSpace "["
        ExecutableCode:code
        OptionalWhiteSpace "]"
        => [[ header first2 code ast-block boa ast-method boa ]]

ClassDeclaration = OptionalWhiteSpace "class" OptionalWhiteSpace Identifier:name
        OptionalWhiteSpace
        ("extends" OptionalWhiteSpace Identifier:superclass OptionalWhiteSpace => [[ superclass ]])?:superclass
        OptionalWhiteSpace "["
        (OptionalWhiteSpace LocalVariableDeclarationList:l => [[ l names>> ]])?:ivars
        (MethodDeclaration:h (OptionalWhiteSpace MethodDeclaration:m => [[ m ]])*:t => [[ t h prefix ]])?:methods
        OptionalWhiteSpace "]"
        => [[ name superclass "Object" or ivars >array methods >array ast-class boa ]]

ForeignClassDeclaration = OptionalWhiteSpace "foreign"
                          OptionalWhiteSpace Identifier:name
                          OptionalWhiteSpace Literal:class
                          => [[ class name ast-foreign boa ]]
End = !(.)

Program = (ClassDeclaration|ForeignClassDeclaration|ExecutableCode) => [[ nil or ]] End

;EBNF