! Copyright (C) 2008 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.parser multiline peg peg.ebnf
sequences strings ;
IN: peg.javascript

<PRIVATE

TUPLE: ast-keyword value ;
TUPLE: ast-name value ;
TUPLE: ast-number value ;
TUPLE: ast-string value ;
TUPLE: ast-regexp body flags ;
TUPLE: ast-cond-expr condition then else ;
TUPLE: ast-set lhs rhs ;
TUPLE: ast-get value ;
TUPLE: ast-mset lhs rhs operator ;
TUPLE: ast-binop lhs rhs operator ;
TUPLE: ast-unop expr operator ;
TUPLE: ast-postop expr operator ;
TUPLE: ast-preop expr operator ;
TUPLE: ast-getp index expr ;
TUPLE: ast-send method expr args ;
TUPLE: ast-call expr args ;
TUPLE: ast-this ;
TUPLE: ast-new name args ;
TUPLE: ast-array values ;
TUPLE: ast-json bindings ;
TUPLE: ast-binding name value ;
TUPLE: ast-func fs body ;
TUPLE: ast-var name value ;
TUPLE: ast-begin statements ;
TUPLE: ast-if condition true false ;
TUPLE: ast-while condition statements ;
TUPLE: ast-do-while statements condition ;
TUPLE: ast-for i c u statements ;
TUPLE: ast-for-in v e statements ;
TUPLE: ast-switch expr statements ;
TUPLE: ast-break ;
TUPLE: ast-continue ;
TUPLE: ast-throw e ;
TUPLE: ast-try t e c f ;
TUPLE: ast-return e ;
TUPLE: ast-with expr body ;
TUPLE: ast-case c cs ;
TUPLE: ast-default cs ;

PRIVATE>

! Grammar for JavaScript. Based on OMeta-JS example from:
! https://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler

EBNF: tokenize-javascript [=[
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
HexDigit          = [0-9a-fA-F]
OctDigit          = [0-7]
LineTerminator    = [\r\n\u002028\u002029]
WhiteSpace        = [ \t\v\f\xa0\u00feff\u001680\u002000\u002001\u002002\u002003\u002004\u002005\u002006\u002007\u002008\u002009\u00200a\u00202f\u00205f\u003000]
SingleLineComment = "//" (!(LineTerminator) .)* "\n" => [[ ignore ]]
MultiLineComment  = "/*" (!("*/") .)* "*/" => [[ ignore ]]
Comment           = SingleLineComment | MultiLineComment
Space             = WhiteSpace | LineTerminator | Comment
Spaces            = Space* => [[ ignore ]]
NameFirst         = Letter | "$" => [[ CHAR: $ ]] | "_" => [[ CHAR: _ ]]
NameRest          = NameFirst | Digit
iName             = NameFirst NameRest* => [[ first2 swap prefix >string ]]
Keyword           =  ("break"
                    | "case"
                    | "catch"
                    | "continue"
                    | "debugger"
                    | "default"
                    | "delete"
                    | "do"
                    | "else"
                    | "finally"
                    | "for"
                    | "function"
                    | "if"
                    | "in"
                    | "instanceof"
                    | "new"
                    | "return"
                    | "switch"
                    | "this"
                    | "throw"
                    | "try"
                    | "typeof"
                    | "var"
                    | "void"
                    | "while"
                    | "with") !(NameRest)
FutureReserved    =  ("class"
                    | "const"
                    | "enum"
                    | "export"
                    | "extends"
                    | "import"
                    | "super")
Name              = !(Keyword) iName  => [[ ast-name boa ]]
HexInteger        = "0"~ [xX]~ HexDigit+ => [[ hex> ]]
OctInteger        = "0"~ OctDigit+ => [[ oct> ]]
ExponentPart      = ("e"|"E") ("+"|"-")? Digits => [[ concat ]]
Decimal           =  (Digits "." Digits? ExponentPart?
                    | "." Digits ExponentPart?
                    | Digits ExponentPart?) => [[ concat string>number ]]
Number            = HexInteger | OctInteger | Decimal => [[ ast-number boa ]]

SingleEscape      =   "b"  => [[ CHAR: \b ]]
                    | "f"  => [[ CHAR: \f ]]
                    | "n"  => [[ CHAR: \n ]]
                    | "r"  => [[ CHAR: \r ]]
                    | "t"  => [[ CHAR: \t ]]
                    | "v"  => [[ CHAR: \v ]]
                    | "'"  => [[ CHAR: '  ]]
                    | "\"" => [[ CHAR: \" ]]
                    | "\\" => [[ CHAR: \\ ]]
OctEscape         =  ([0-3] OctDigit OctDigit?
                    | [4-7] OctDigit) [[ sift oct> ]]
HexEscape         = "x"~ (HexDigit HexDigit) => [[ hex> ]]
UnicodeEscape     =  ("u"~ (HexDigit HexDigit HexDigit HexDigit)
                    | "u{"~ HexDigit+ "}"~) => [[ hex> ]]
EscapeChar        = "\\" (SingleEscape | OctEscape | HexEscape | UnicodeEscape):c => [[ c ]]
LineContinuation  = "\\" LineTerminator => [[ drop f ]]
StringChars1      = (EscapeChar | LineContinuation | !('"""') .)
StringChars2      = (EscapeChar | LineContinuation | !('"') .)
StringChars3      = (EscapeChar | LineContinuation | !("'") .)
Str               = ( '"""'~ StringChars1* '"""'~
                    | '"'~ StringChars2* '"'~
                    | "'"~ StringChars3* "'"~ ) => [[ sift >string ast-string boa ]]
RegExpFlags       = NameRest* => [[ >string ]]
NonTerminator     = !(LineTerminator) .
BackslashSequence = "\\" NonTerminator => [[ second ]]
RegExpFirstChar   =   !([*\\/]) NonTerminator
                    | BackslashSequence
RegExpChar        =   !([\\/]) NonTerminator
                    | BackslashSequence
RegExpChars       = RegExpChar*
RegExpBody        = RegExpFirstChar RegExpChars => [[ first2 swap prefix >string ]]
RegExp            = "/" RegExpBody:b "/" RegExpFlags:fl => [[ b fl ast-regexp boa ]]
Special           =   "("    | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                    | "?"    | ":"   | "!==" | "!="  | "===" | "=="  | "="   | ">="
                    | ">>>=" | ">>>" | ">>=" | ">>"  | ">"   | "<="  | "<<=" | "<<"
                    | "<"    | "++"  | "+="  | "+"   | "--"  | "-="  | "-"   | "*="
                    | "*"    | "/="  | "/"   | "%="  | "%"   | "&&=" | "&&"  | "||="
                    | "||"   | "."   | "!"   | "&="  | "&"   | "|="  | "|"   | "^="
                    | "^"    | "~"
Tok               = Spaces (Name | Keyword | Number | Str | RegExp | Special )
Toks              = Tok* Spaces
]=]

! Grammar for JavaScript. Based on OMeta-JS example from:
! https://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler

! The interesting thing about this parser is the mixing of
! a default and non-default tokenizer. The JavaScript tokenizer
! removes all newlines. So when operating on tokens there is no
! need for newline and space skipping in the grammar. But JavaScript
! uses the newline in the 'automatic semicolon insertion' rule.
!
! If a statement ends in a newline, sometimes the semicolon can be
! skipped. So we define an 'nl' rule using the default tokenizer.
! This operates a character at a time. Using this 'nl' in the parser
! allows us to detect newlines when we need to for the semicolon
! insertion rule, but ignore it in all other places.

EBNF: parse-javascript [=[
tokenizer         = default
nl                = "\r\n" | "\n"

tokenizer         = <foreign tokenize-javascript Tok>
End               = !(.)
Space             = [ \t\r\n]
Spaces            = Space* => [[ ignore ]]
Name               = . ?[ ast-name?   ]?   => [[ value>> ]]
Number             = . ?[ ast-number? ]?
String             = . ?[ ast-string? ]?
RegExp             = . ?[ ast-regexp? ]?
SpacesNoNl         = (!(nl) Space)* => [[ ignore ]]

Expr               =   OrExpr:e "?" Expr:t ":" Expr:f   => [[ e t f ast-cond-expr boa ]]
                     | OrExpr:e "=" Expr:rhs            => [[ e rhs ast-set boa ]]
                     | OrExpr:e "+=" Expr:rhs           => [[ e rhs "+" ast-mset boa ]]
                     | OrExpr:e "-=" Expr:rhs           => [[ e rhs "-" ast-mset boa ]]
                     | OrExpr:e "*=" Expr:rhs           => [[ e rhs "*" ast-mset boa ]]
                     | OrExpr:e "/=" Expr:rhs           => [[ e rhs "/" ast-mset boa ]]
                     | OrExpr:e "%=" Expr:rhs           => [[ e rhs "%" ast-mset boa ]]
                     | OrExpr:e "&&=" Expr:rhs          => [[ e rhs "&&" ast-mset boa ]]
                     | OrExpr:e "||=" Expr:rhs          => [[ e rhs "||" ast-mset boa ]]
                     | OrExpr:e "^=" Expr:rhs           => [[ e rhs "^" ast-mset boa ]]
                     | OrExpr:e "&=" Expr:rhs           => [[ e rhs "&" ast-mset boa ]]
                     | OrExpr:e "|=" Expr:rhs           => [[ e rhs "|" ast-mset boa ]]
                     | OrExpr:e "<<=" Expr:rhs          => [[ e rhs "<<" ast-mset boa ]]
                     | OrExpr:e ">>=" Expr:rhs          => [[ e rhs ">>" ast-mset boa ]]
                     | OrExpr:e ">>>=" Expr:rhs         => [[ e rhs ">>>" ast-mset boa ]]
                     | OrExpr:e                         => [[ e ]]

ExprNoIn           =   OrExprNoIn:e "?" ExprNoIn:t ":" ExprNoIn:f => [[ e t f ast-cond-expr boa ]]
                     | OrExprNoIn:e "=" ExprNoIn:rhs              => [[ e rhs ast-set boa ]]
                     | OrExprNoIn:e "+=" ExprNoIn:rhs             => [[ e rhs "+" ast-mset boa ]]
                     | OrExprNoIn:e "-=" ExprNoIn:rhs             => [[ e rhs "-" ast-mset boa ]]
                     | OrExprNoIn:e "*=" ExprNoIn:rhs             => [[ e rhs "*" ast-mset boa ]]
                     | OrExprNoIn:e "/=" ExprNoIn:rhs             => [[ e rhs "/" ast-mset boa ]]
                     | OrExprNoIn:e "%=" ExprNoIn:rhs             => [[ e rhs "%" ast-mset boa ]]
                     | OrExprNoIn:e "&&=" ExprNoIn:rhs            => [[ e rhs "&&" ast-mset boa ]]
                     | OrExprNoIn:e "||=" ExprNoIn:rhs            => [[ e rhs "||" ast-mset boa ]]
                     | OrExprNoIn:e "^=" ExprNoIn:rhs             => [[ e rhs "^" ast-mset boa ]]
                     | OrExprNoIn:e "&=" ExprNoIn:rhs             => [[ e rhs "&" ast-mset boa ]]
                     | OrExprNoIn:e "|=" ExprNoIn:rhs             => [[ e rhs "|" ast-mset boa ]]
                     | OrExprNoIn:e "<<=" ExprNoIn:rhs            => [[ e rhs "<<" ast-mset boa ]]
                     | OrExprNoIn:e ">>=" ExprNoIn:rhs            => [[ e rhs ">>" ast-mset boa ]]
                     | OrExprNoIn:e ">>>=" ExprNoIn:rhs           => [[ e rhs ">>>" ast-mset boa ]]
                     | OrExprNoIn:e                               => [[ e ]]

OrExpr             =   OrExpr:x "||" AndExpr:y          => [[ x y "||" ast-binop boa ]]
                     | AndExpr
OrExprNoIn         =   OrExprNoIn:x "||" AndExprNoIn:y  => [[ x y "||" ast-binop boa ]]
                     | AndExprNoIn
AndExpr            =   AndExpr:x "&&" BitOrExpr:y       => [[ x y "&&" ast-binop boa ]]
                     | BitOrExpr
AndExprNoIn        =   AndExprNoIn:x "&&" BitOrExprNoIn:y => [[ x y "&&" ast-binop boa ]]
                     | BitOrExprNoIn
BitOrExpr          =   BitOrExpr:x "|" BitXORExpr:y     => [[ x y "|" ast-binop boa ]]
                     | BitXORExpr
BitOrExprNoIn      =   BitOrExprNoIn:x "|" BitXORExprNoIn:y => [[ x y "|" ast-binop boa ]]
                     | BitXORExprNoIn
BitXORExpr         =   BitXORExpr:x "^" BitANDExpr:y    => [[ x y "^" ast-binop boa ]]
                     | BitANDExpr
BitXORExprNoIn     =   BitXORExprNoIn:x "^" BitANDExprNoIn:y => [[ x y "^" ast-binop boa ]]
                     | BitANDExprNoIn
BitANDExpr         =   BitANDExpr:x "&" EqExpr:y        => [[ x y "&" ast-binop boa ]]
                     | EqExpr
BitANDExprNoIn     =   BitANDExprNoIn:x "&" EqExprNoIn:y => [[ x y "&" ast-binop boa ]]
                     | EqExprNoIn
EqExpr             =   EqExpr:x "==" RelExpr:y          => [[ x y "==" ast-binop boa ]]
                     | EqExpr:x "!=" RelExpr:y          => [[ x y "!=" ast-binop boa ]]
                     | EqExpr:x "===" RelExpr:y         => [[ x y "===" ast-binop boa ]]
                     | EqExpr:x "!==" RelExpr:y         => [[ x y "!==" ast-binop boa ]]
                     | RelExpr
EqExprNoIn         =   EqExprNoIn:x "==" RelExprNoIn:y    => [[ x y "==" ast-binop boa ]]
                     | EqExprNoIn:x "!=" RelExprNoIn:y    => [[ x y "!=" ast-binop boa ]]
                     | EqExprNoIn:x "===" RelExprNoIn:y   => [[ x y "===" ast-binop boa ]]
                     | EqExprNoIn:x "!==" RelExprNoIn:y   => [[ x y "!==" ast-binop boa ]]
                     | RelExprNoIn
RelExpr            =   RelExpr:x ">" ShiftExpr:y          => [[ x y ">" ast-binop boa ]]
                     | RelExpr:x ">=" ShiftExpr:y         => [[ x y ">=" ast-binop boa ]]
                     | RelExpr:x "<" ShiftExpr:y          => [[ x y "<" ast-binop boa ]]
                     | RelExpr:x "<=" ShiftExpr:y         => [[ x y "<=" ast-binop boa ]]
                     | RelExpr:x "instanceof" ShiftExpr:y => [[ x y "instanceof" ast-binop boa ]]
                     | RelExpr:x "in" ShiftExpr:y         => [[ x y "in" ast-binop boa ]]
                     | ShiftExpr
RelExprNoIn        =   RelExprNoIn:x ">" ShiftExpr:y          => [[ x y ">" ast-binop boa ]]
                     | RelExprNoIn:x ">=" ShiftExpr:y         => [[ x y ">=" ast-binop boa ]]
                     | RelExprNoIn:x "<" ShiftExpr:y          => [[ x y "<" ast-binop boa ]]
                     | RelExprNoIn:x "<=" ShiftExpr:y         => [[ x y "<=" ast-binop boa ]]
                     | RelExprNoIn:x "instanceof" ShiftExpr:y => [[ x y "instanceof" ast-binop boa ]]
                     | ShiftExpr
ShiftExpr          =   ShiftExpr:x "<<" AddExpr:y       => [[ x y "<<" ast-binop boa ]]
                     | ShiftExpr:x ">>>" AddExpr:y      => [[ x y ">>>" ast-binop boa ]]
                     | ShiftExpr:x ">>" AddExpr:y       => [[ x y ">>" ast-binop boa ]]
                     | AddExpr
AddExpr            =   AddExpr:x "+" MulExpr:y          => [[ x y "+" ast-binop boa ]]
                     | AddExpr:x "-" MulExpr:y          => [[ x y "-" ast-binop boa ]]
                     | MulExpr
MulExpr            =   MulExpr:x "*" Unary:y            => [[ x y "*" ast-binop boa ]]
                     | MulExpr:x "/" Unary:y            => [[ x y "/" ast-binop boa ]]
                     | MulExpr:x "%" Unary:y            => [[ x y "%" ast-binop boa ]]
                     | Unary
Unary              =   "-" Unary:p                      => [[ p "-" ast-unop boa ]]
                     | "+" Unary:p                      => [[ p ]]
                     | "++" Unary:p                     => [[ p "++" ast-preop boa ]]
                     | "--" Unary:p                     => [[ p "--" ast-preop boa ]]
                     | "!" Unary:p                      => [[ p "!" ast-unop boa ]]
                     | "typeof" Unary:p                 => [[ p "typeof" ast-unop boa ]]
                     | "void" Unary:p                   => [[ p "void" ast-unop boa ]]
                     | "delete" Unary:p                 => [[ p "delete" ast-unop boa ]]
                     | Postfix
Postfix            =   PrimExpr:p SpacesNoNl "++"       => [[ p "++" ast-postop boa ]]
                     | PrimExpr:p SpacesNoNl "--"       => [[ p "--" ast-postop boa ]]
                     | PrimExpr
Args               =   (Expr ("," Expr => [[ second ]])* => [[ first2 swap prefix ]])?
PrimExpr           =   PrimExpr:p "[" Expr:i "]"             => [[ i p ast-getp boa ]]
                     | PrimExpr:p "." Name:m "(" Args:as ")" => [[ m p as ast-send boa ]]
                     | PrimExpr:p "." Name:f                 => [[ f p ast-getp boa ]]
                     | PrimExpr:p "(" Args:as ")"            => [[ p as ast-call boa ]]
                     | PrimExprHd
PrimExprHd         =   "(" Expr:e ")"                        => [[ e ]]
                     | "this"                                => [[ ast-this boa ]]
                     | Name                                  => [[ ast-get boa ]]
                     | Number
                     | String
                     | RegExp
                     | "function" FuncRest:fr                => [[ fr ]]
                     | "new" PrimExpr:n "(" Args:as ")"      => [[ n as ast-new boa ]]
                     | "new" PrimExpr:n                      => [[ n f  ast-new boa ]]
                     | "[" Args:es "]"                       => [[ es ast-array boa ]]
                     | Json
JsonBindings       = (JsonBinding ("," JsonBinding => [[ second ]])* => [[ first2 swap prefix ]])?
Json               = "{" JsonBindings:bs "}"                  => [[ bs ast-json boa ]]
JsonBinding        = JsonPropName:n ":" Expr:v               => [[ n v ast-binding boa ]]
JsonPropName       = Name | Number | String | RegExp
Formal             = Spaces Name
Formals            = (Formal ("," Formal => [[ second ]])*  => [[ first2 swap prefix ]])?
FuncRest           = "(" Formals:fs ")" "{" SrcElems:body "}" => [[ fs body ast-func boa ]]
Sc                 = SpacesNoNl (nl | &("}") | End)| ";"
Binding            =   Name:n "=" Expr:v                      => [[ n v ast-var boa ]]
                     | Name:n                                 => [[ n "undefined" ast-get boa ast-var boa ]]
Block              = "{" SrcElems:ss "}"                      => [[ ss ]]
Bindings           = (Binding (","~ Binding)* => [[ first2 swap prefix ]])?
For1               =   "var" Bindings => [[ second ]] 
                     | ExprNoIn 
                     | Spaces => [[ "undefined" ast-get boa ]] 
For2               =   Expr
                     | Spaces => [[ "true" ast-get boa ]] 
For3               =   Expr
                     | Spaces => [[ "undefined" ast-get boa ]] 
ForIn1             =   "var" Name:n => [[ n "undefined" ast-get boa ast-var boa ]]
                     | PrimExprHd
Switch1            =   "case" Expr:c ":" SrcElems:cs => [[ c cs ast-case boa ]]
                     | "default" ":" SrcElems:cs => [[ cs ast-default boa ]]  
SwitchBody         = Switch1*
Finally            =   "finally" Block:b => [[ b ]]
                     | Spaces => [[ "undefined" ast-get boa ]]
Stmt               =   Block
                     | "var" Bindings:bs Sc                   => [[ bs ast-begin boa ]]
                     | "if" "(" Expr:c ")" Stmt:t "else" Stmt:f => [[ c t f ast-if boa ]]
                     | "if" "(" Expr:c ")" Stmt:t               => [[ c t "undefined" ast-get boa ast-if boa ]]
                     | "while" "(" Expr:c ")" Stmt:s            => [[ c s ast-while boa ]]
                     | "do" Stmt:s "while" "(" Expr:c ")" Sc    => [[ s c ast-do-while boa ]]
                     | "for" "(" For1:i ";" For2:c ";" For3:u ")" Stmt:s => [[ i c u s ast-for boa ]]
                     | "for" "(" ForIn1:v "in" Expr:e ")" Stmt:s => [[ v e s ast-for-in boa ]]
                     | "switch" "(" Expr:e ")" "{" SwitchBody:cs "}" => [[ e cs ast-switch boa ]]
                     | "break" Sc                                    => [[ ast-break boa ]]
                     | "continue" Sc                                 => [[ ast-continue boa ]]
                     | "throw" SpacesNoNl Expr:e Sc                  => [[ e ast-throw boa ]]
                     | "try" Block:t "catch" "(" Name:e ")" Block:c Finally:f => [[ t e c f ast-try boa ]]
                     | "return" Expr:e Sc                            => [[ e ast-return boa ]]
                     | "return" Sc                                   => [[ "undefined" ast-get boa ast-return boa ]]
                     | "with" "(" Expr:e ")" Stmt:b                  => [[ e b ast-with boa ]]
                     | Expr:e Sc                                     => [[ e ]]
                     | ";"                                           => [[ "undefined" ast-get boa ]]
SrcElem            =   "function" Name:n FuncRest:f                  => [[ n f ast-var boa ]]
                     | Stmt
SrcElems           = SrcElem*                                      => [[ ast-begin boa ]]
TopLevel           = SrcElems Spaces
]=]
