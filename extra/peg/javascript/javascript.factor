! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences sequences.deep
peg peg.ebnf peg.parsers memoize namespaces math ;
IN: peg.javascript

#! Grammar for JavaScript. Based on OMeta-JS example from:
#! http://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler 

USE: prettyprint

TUPLE: ast-keyword value ;
TUPLE: ast-name value ;
TUPLE: ast-number value ;
TUPLE: ast-string value ;
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
TUPLE: ast-case c cs ;
TUPLE: ast-default cs ;
C: <ast-name> ast-name
C: <ast-keyword> ast-keyword
C: <ast-number> ast-number
C: <ast-string> ast-string
C: <ast-cond-expr> ast-cond-expr
C: <ast-set> ast-set
C: <ast-get> ast-get
C: <ast-mset> ast-mset
C: <ast-binop> ast-binop
C: <ast-unop> ast-unop
C: <ast-preop> ast-preop
C: <ast-postop> ast-postop
C: <ast-getp> ast-getp
C: <ast-send> ast-send
C: <ast-call> ast-call
C: <ast-this> ast-this
C: <ast-new> ast-new
C: <ast-array> ast-array
C: <ast-json> ast-json
C: <ast-binding> ast-binding
C: <ast-func> ast-func
C: <ast-var> ast-var
C: <ast-begin> ast-begin
C: <ast-if> ast-if
C: <ast-while> ast-while
C: <ast-do-while> ast-do-while
C: <ast-for> ast-for
C: <ast-for-in> ast-for-in
C: <ast-switch> ast-switch
C: <ast-break> ast-break
C: <ast-continue> ast-continue
C: <ast-throw> ast-throw
C: <ast-try> ast-try
C: <ast-return> ast-return
C: <ast-case> ast-case
C: <ast-default> ast-default

EBNF: javascript
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = (Digit)+
SingleLineComment = "//" (!("\n") .)* "\n" => [[ drop ignore ]]
MultiLineComment  = "/*" (!("*/") .)* "*/" => [[ drop ignore ]]
Space             = " " | "\t" | "\n" | SingleLineComment | MultiLineComment
Spaces            = (Space)* => [[ drop ignore ]]
NameFirst         = Letter | "$" | "_"
NameRest          = NameFirst | Digit
iName             = NameFirst (NameRest)* => [[ first2 swap prefix >string ]]
Keyword           =  ("break"
                    | "case"
                    | "catch"
                    | "continue"
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
                    | "with") => [[ <ast-keyword> ]]
Name              = !(Keyword) (iName):n => [[ drop n <ast-name> ]]
Number            =   Digits:ws '.' Digits:fs => [[ drop ws "." fs 3array concat >string string>number <ast-number> ]]
                    | Digits => [[ >string string>number <ast-number> ]]  

EscapeChar        =   "\\n" => [[ drop 10 ]] 
                    | "\\r" => [[ drop 13 ]]
                    | "\\t" => [[ drop 9 ]]
StringChars1       = (EscapeChar | !('"""') .)* => [[ >string ]]
StringChars2       = (EscapeChar | !('"') .)* => [[ >string ]]
StringChars3       = (EscapeChar | !("'") .)* => [[ >string ]]
Str                =   '"""' StringChars1:cs '"""' => [[ drop cs <ast-string> ]]
                     | '"' StringChars2:cs '"' => [[ drop cs <ast-string> ]]
                     | "'" StringChars3:cs "'" => [[ drop cs <ast-string> ]]
Special            =   "("   | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                     | "?"   | ":"   | "!==" | "~="  | "===" | "=="  | "="   | ">="
                     | ">"   | "<="  | "<"   | "++"  | "+="  | "+"   | "--"  | "-="
                     | "-"   | "*="  | "*"   | "/="  | "/"   | "%="  | "%"   | "&&="
                     | "&&"  | "||=" | "||"  | "."   | "!"
Tok                = Spaces (Name | Keyword | Number | Str | Special )
Toks               = (Tok)* Spaces 
SpacesNoNl         = (!("\n") Space)* => [[ drop ignore ]]

Expr               =   OrExpr:e "?" Expr:t ":" Expr:f   => [[ drop e t f <ast-cond-expr> ]]
                     | OrExpr:e "=" Expr:rhs            => [[ drop e rhs <ast-set> ]]
                     | OrExpr:e "+=" Expr:rhs           => [[ drop e rhs "+" <ast-mset> ]]
                     | OrExpr:e "-=" Expr:rhs           => [[ drop e rhs "-" <ast-mset> ]]
                     | OrExpr:e "*=" Expr:rhs           => [[ drop e rhs "*" <ast-mset> ]]
                     | OrExpr:e "/=" Expr:rhs           => [[ drop e rhs "/" <ast-mset> ]]
                     | OrExpr:e "%=" Expr:rhs           => [[ drop e rhs "%" <ast-mset> ]]
                     | OrExpr:e "&&=" Expr:rhs          => [[ drop e rhs "&&" <ast-mset> ]]
                     | OrExpr:e "||=" Expr:rhs          => [[ drop e rhs "||" <ast-mset> ]]
                     | OrExpr:e                         => [[ drop e ]]

OrExpr             =   OrExpr:x "||" AndExpr:y          => [[ drop x y "||" <ast-binop> ]]
                     | AndExpr
AndExpr            =   AndExpr:x "&&" EqExpr:y          => [[ drop x y "&&" <ast-binop> ]]
                     | EqExpr
EqExpr             =   EqExpr:x "==" RelExpr:y          => [[ drop x y "==" <ast-binop> ]]
                     | EqExpr:x "!=" RelExpr:y          => [[ drop x y "!=" <ast-binop> ]]
                     | EqExpr:x "===" RelExpr:y         => [[ drop x y "===" <ast-binop> ]]
                     | EqExpr:x "!==" RelExpr:y         => [[ drop x y "!==" <ast-binop> ]]
                     | RelExpr
RelExpr            =   RelExpr:x ">" AddExpr:y          => [[ drop x y ">" <ast-binop> ]]
                     | RelExpr:x ">=" AddExpr:y         => [[ drop x y ">=" <ast-binop> ]]
                     | RelExpr:x "<" AddExpr:y          => [[ drop x y "<" <ast-binop> ]]
                     | RelExpr:x "<=" AddExpr:y         => [[ drop x y "<=" <ast-binop> ]]
                     | RelExpr:x "instanceof" AddExpr:y => [[ drop x y "instanceof" <ast-binop> ]]
                     | AddExpr
AddExpr            =   AddExpr:x "+" MulExpr:y          => [[ drop x y "+" <ast-binop> ]]
                     | AddExpr:x "-" MulExpr:y          => [[ drop x y "-" <ast-binop> ]]
                     | MulExpr
MulExpr            =   MulExpr:x "*" MulExpr:y          => [[ drop x y "*" <ast-binop> ]]
                     | MulExpr:x "/" MulExpr:y          => [[ drop x y "/" <ast-binop> ]]
                     | MulExpr:x "%" MulExpr:y          => [[ drop x y "%" <ast-binop> ]]
                     | Unary
Unary              =   "-" Postfix:p                    => [[ drop p "-" <ast-unop> ]]
                     | "+" Postfix:p                    => [[ drop p ]]
                     | "++" Postfix:p                   => [[ drop p "++" <ast-preop> ]]
                     | "--" Postfix:p                   => [[ drop p "--" <ast-preop> ]]
                     | "!" Postfix:p                    => [[ drop p "!" <ast-unop> ]]
                     | Postfix
Postfix            =   PrimExpr:p SpacesNoNl "++"       => [[ drop p "++" <ast-postop> ]]
                     | PrimExpr:p SpacesNoNl "--"       => [[ drop p "--" <ast-postop> ]]
                     | PrimExpr
Args               =   Expr ("," Expr)*                      => [[ first2 swap prefix ]]
PrimExpr           =   PrimExpr:p "[" Expr:i "]"             => [[ drop i p <ast-getp> ]]
                     | PrimExpr:p "." Name:m "(" Args:as ")" => [[ drop m p as <ast-send> ]]
                     | PrimExpr:p "." Name:f                 => [[ drop f p <ast-getp> ]]
                     | PrimExpr:p "(" Args:as ")"            => [[ drop p as <ast-call> ]]
                     | PrimExprHd
PrimExprHd         =   "(" Expr:e ")"                        => [[ drop e ]]
                     | "this"                                => [[ drop <ast-this> ]]
                     | Name                                  => [[ <ast-get> ]]
                     | Number                                => [[ <ast-number> ]]
                     | Str                                   => [[ <ast-string> ]]
                     | "function" FuncRest:fr                => [[ drop fr ]]
                     | "new" Name:n "(" Args:as ")"          => [[ drop n as <ast-new> ]]
                     | "[" Args:es "]"                       => [[ drop es <ast-array> ]]
                     | Json
JsonBindings        = JsonBinding ("," JsonBinding)*          => [[ first2 swap prefix ]]
Json               = "{" JsonBindings:bs "}"                  => [[ drop bs <ast-json> ]]
JsonBinding        = JsonPropName:n ":" Expr:v               => [[ drop n v <ast-binding> ]]
JsonPropName       = Name | Number | Str
Formal             = Spaces Name
Formals            = Formal ("," Formal)*                    => [[ first2 swap prefix ]]
FuncRest           = "(" Formals:fs ")" "{" SrcElems:body "}" => [[ drop fs body <ast-func> ]]
Sc                 = SpacesNoNl ("\n" | "}")| ";"
Binding            =   Name:n "=" Expr:v                      => [[ drop n v <ast-var> ]]
                     | Name:n                                 => [[ drop n "undefined" <ast-get> <ast-var> ]]
Block              = "{" SrcElems:ss "}"                      => [[ drop ss ]]
Bindings           = Binding ("," Binding)*                   => [[ first2 swap prefix ]]
For1               =   "var" Binding => [[ second ]] 
                     | Expr 
                     | Spaces => [[ "undefined" <ast-get> ]] 
For2               =   Expr
                     | Spaces => [[ "true" <ast-get> ]] 
For3               =   Expr
                     | Spaces => [[ "undefined" <ast-get> ]] 
ForIn1             =   "var" Name:n => [[ drop n "undefined" <ast-get> <ast-var> ]]
                     | Expr
Switch1            =   "case" Expr:c ":" SrcElems:cs => [[ drop c cs <ast-case> ]]
                     | "default" ":" SrcElems:cs => [[ drop cs <ast-default> ]]  
SwitchBody         = (Switch1)*
Finally            =   "finally" Block:b => [[ drop b ]]
                     | Spaces => [[ drop "undefined" <ast-get> ]]
Stmt               =   Block                     
                     | "var" Bindings:bs Sc                   => [[ drop bs <ast-begin> ]]
                     | "if" "(" Expr:c ")" Stmt:t "else" Stmt:f => [[ drop c t f <ast-if> ]]
                     | "if" "(" Expr:c ")" Stmt:t               => [[ drop c t "undefined" <ast-get> <ast-if> ]]
                     | "while" "(" Expr:c ")" Stmt:s            => [[ drop c s <ast-while> ]]
                     | "do" Stmt:s "while" "(" Expr:c ")" Sc    => [[ drop s c <ast-do-while> ]]
                     | "for" "(" For1:i ";" For2:c ";" For3:u ")" Stmt:s => [[ drop i c u s <ast-for> ]]
                     | "for" "(" ForIn1:v "in" Expr:e ")" Stmt:s => [[ drop v e s <ast-for-in> ]]
                     | "switch" "(" Expr:e ")" "{" SwitchBody:cs "}" => [[ drop e cs <ast-switch> ]]
                     | "break" Sc                                    => [[ drop <ast-break> ]]
                     | "continue" Sc                                 => [[ drop <ast-continue> ]]
                     | "throw" SpacesNoNl Expr:e Sc                  => [[ drop e <ast-throw> ]]
                     | "try" Block:t "catch" "(" Name:e ")" Block:c Finally:f => [[ drop t e c f <ast-try> ]]
                     | "return" Expr:e Sc                            => [[ drop e <ast-return> ]]
                     | "return" Sc                                   => [[ drop "undefined" <ast-get> <ast-return> ]]
                     | Expr:e Sc                                     => [[ drop e ]]
                     | ";"                                           => [[ drop "undefined" <ast-get> ]]
SrcElem            =   "function" Name:n FuncRest:f                  => [[ drop n f <ast-var> ]]
                     | Stmt
SrcElems           = (SrcElem)*                                      => [[ <ast-begin> ]]
TopLevel           = SrcElems Spaces                               
;EBNF