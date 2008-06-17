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
                    | "with") => [[ ast-keyword boa ]]
Name              = !(Keyword) (iName):n => [[ drop n ast-name boa ]]
Number            =   Digits:ws '.' Digits:fs => [[ drop ws "." fs 3array concat >string string>number ast-number boa ]]
                    | Digits => [[ >string string>number ast-number boa ]]  

EscapeChar        =   "\\n" => [[ drop 10 ]] 
                    | "\\r" => [[ drop 13 ]]
                    | "\\t" => [[ drop 9 ]]
StringChars1       = (EscapeChar | !('"""') .)* => [[ >string ]]
StringChars2       = (EscapeChar | !('"') .)* => [[ >string ]]
StringChars3       = (EscapeChar | !("'") .)* => [[ >string ]]
Str                =   '"""' StringChars1:cs '"""' => [[ drop cs ast-string boa ]]
                     | '"' StringChars2:cs '"' => [[ drop cs ast-string boa ]]
                     | "'" StringChars3:cs "'" => [[ drop cs ast-string boa ]]
Special            =   "("   | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                     | "?"   | ":"   | "!==" | "~="  | "===" | "=="  | "="   | ">="
                     | ">"   | "<="  | "<"   | "++"  | "+="  | "+"   | "--"  | "-="
                     | "-"   | "*="  | "*"   | "/="  | "/"   | "%="  | "%"   | "&&="
                     | "&&"  | "||=" | "||"  | "."   | "!"
Tok                = Spaces (Name | Keyword | Number | Str | Special )
Toks               = (Tok)* Spaces 
SpacesNoNl         = (!("\n") Space)* => [[ drop ignore ]]

Expr               =   OrExpr:e "?" Expr:t ":" Expr:f   => [[ drop e t f ast-cond-expr boa ]]
                     | OrExpr:e "=" Expr:rhs            => [[ drop e rhs ast-set boa ]]
                     | OrExpr:e "+=" Expr:rhs           => [[ drop e rhs "+" ast-mset boa ]]
                     | OrExpr:e "-=" Expr:rhs           => [[ drop e rhs "-" ast-mset boa ]]
                     | OrExpr:e "*=" Expr:rhs           => [[ drop e rhs "*" ast-mset boa ]]
                     | OrExpr:e "/=" Expr:rhs           => [[ drop e rhs "/" ast-mset boa ]]
                     | OrExpr:e "%=" Expr:rhs           => [[ drop e rhs "%" ast-mset boa ]]
                     | OrExpr:e "&&=" Expr:rhs          => [[ drop e rhs "&&" ast-mset boa ]]
                     | OrExpr:e "||=" Expr:rhs          => [[ drop e rhs "||" ast-mset boa ]]
                     | OrExpr:e                         => [[ drop e ]]

OrExpr             =   OrExpr:x "||" AndExpr:y          => [[ drop x y "||" ast-binop boa ]]
                     | AndExpr
AndExpr            =   AndExpr:x "&&" EqExpr:y          => [[ drop x y "&&" ast-binop boa ]]
                     | EqExpr
EqExpr             =   EqExpr:x "==" RelExpr:y          => [[ drop x y "==" ast-binop boa ]]
                     | EqExpr:x "!=" RelExpr:y          => [[ drop x y "!=" ast-binop boa ]]
                     | EqExpr:x "===" RelExpr:y         => [[ drop x y "===" ast-binop boa ]]
                     | EqExpr:x "!==" RelExpr:y         => [[ drop x y "!==" ast-binop boa ]]
                     | RelExpr
RelExpr            =   RelExpr:x ">" AddExpr:y          => [[ drop x y ">" ast-binop boa ]]
                     | RelExpr:x ">=" AddExpr:y         => [[ drop x y ">=" ast-binop boa ]]
                     | RelExpr:x "<" AddExpr:y          => [[ drop x y "<" ast-binop boa ]]
                     | RelExpr:x "<=" AddExpr:y         => [[ drop x y "<=" ast-binop boa ]]
                     | RelExpr:x "instanceof" AddExpr:y => [[ drop x y "instanceof" ast-binop boa ]]
                     | AddExpr
AddExpr            =   AddExpr:x "+" MulExpr:y          => [[ drop x y "+" ast-binop boa ]]
                     | AddExpr:x "-" MulExpr:y          => [[ drop x y "-" ast-binop boa ]]
                     | MulExpr
MulExpr            =   MulExpr:x "*" MulExpr:y          => [[ drop x y "*" ast-binop boa ]]
                     | MulExpr:x "/" MulExpr:y          => [[ drop x y "/" ast-binop boa ]]
                     | MulExpr:x "%" MulExpr:y          => [[ drop x y "%" ast-binop boa ]]
                     | Unary
Unary              =   "-" Postfix:p                    => [[ drop p "-" ast-unop boa ]]
                     | "+" Postfix:p                    => [[ drop p ]]
                     | "++" Postfix:p                   => [[ drop p "++" ast-preop boa ]]
                     | "--" Postfix:p                   => [[ drop p "--" ast-preop boa ]]
                     | "!" Postfix:p                    => [[ drop p "!" ast-unop boa ]]
                     | Postfix
Postfix            =   PrimExpr:p SpacesNoNl "++"       => [[ drop p "++" ast-postop boa ]]
                     | PrimExpr:p SpacesNoNl "--"       => [[ drop p "--" ast-postop boa ]]
                     | PrimExpr
Args               =   Expr ("," Expr)*                      => [[ first2 swap prefix ]]
PrimExpr           =   PrimExpr:p "[" Expr:i "]"             => [[ drop i p ast-getp boa ]]
                     | PrimExpr:p "." Name:m "(" Args:as ")" => [[ drop m p as ast-send boa ]]
                     | PrimExpr:p "." Name:f                 => [[ drop f p ast-getp boa ]]
                     | PrimExpr:p "(" Args:as ")"            => [[ drop p as ast-call boa ]]
                     | PrimExprHd
PrimExprHd         =   "(" Expr:e ")"                        => [[ drop e ]]
                     | "this"                                => [[ drop ast-this boa ]]
                     | Name                                  => [[ ast-get boa ]]
                     | Number                                => [[ ast-number boa ]]
                     | Str                                   => [[ ast-string boa ]]
                     | "function" FuncRest:fr                => [[ drop fr ]]
                     | "new" Name:n "(" Args:as ")"          => [[ drop n as ast-new boa ]]
                     | "[" Args:es "]"                       => [[ drop es ast-array boa ]]
                     | Json
JsonBindings        = JsonBinding ("," JsonBinding)*          => [[ first2 swap prefix ]]
Json               = "{" JsonBindings:bs "}"                  => [[ drop bs ast-json boa ]]
JsonBinding        = JsonPropName:n ":" Expr:v               => [[ drop n v ast-binding boa ]]
JsonPropName       = Name | Number | Str
Formal             = Spaces Name
Formals            = Formal ("," Formal)*                    => [[ first2 swap prefix ]]
FuncRest           = "(" Formals:fs ")" "{" SrcElems:body "}" => [[ drop fs body ast-func boa ]]
Sc                 = SpacesNoNl ("\n" | "}")| ";"
Binding            =   Name:n "=" Expr:v                      => [[ drop n v ast-var boa ]]
                     | Name:n                                 => [[ drop n "undefined" ast-get boa ast-var boa ]]
Block              = "{" SrcElems:ss "}"                      => [[ drop ss ]]
Bindings           = Binding ("," Binding)*                   => [[ first2 swap prefix ]]
For1               =   "var" Binding => [[ second ]] 
                     | Expr 
                     | Spaces => [[ "undefined" ast-get boa ]] 
For2               =   Expr
                     | Spaces => [[ "true" ast-get boa ]] 
For3               =   Expr
                     | Spaces => [[ "undefined" ast-get boa ]] 
ForIn1             =   "var" Name:n => [[ drop n "undefined" ast-get boa ast-var boa ]]
                     | Expr
Switch1            =   "case" Expr:c ":" SrcElems:cs => [[ drop c cs ast-case boa ]]
                     | "default" ":" SrcElems:cs => [[ drop cs ast-default boa ]]  
SwitchBody         = (Switch1)*
Finally            =   "finally" Block:b => [[ drop b ]]
                     | Spaces => [[ drop "undefined" ast-get boa ]]
Stmt               =   Block                     
                     | "var" Bindings:bs Sc                   => [[ drop bs ast-begin boa ]]
                     | "if" "(" Expr:c ")" Stmt:t "else" Stmt:f => [[ drop c t f ast-if boa ]]
                     | "if" "(" Expr:c ")" Stmt:t               => [[ drop c t "undefined" ast-get boa ast-if boa ]]
                     | "while" "(" Expr:c ")" Stmt:s            => [[ drop c s ast-while boa ]]
                     | "do" Stmt:s "while" "(" Expr:c ")" Sc    => [[ drop s c ast-do-while boa ]]
                     | "for" "(" For1:i ";" For2:c ";" For3:u ")" Stmt:s => [[ drop i c u s ast-for boa ]]
                     | "for" "(" ForIn1:v "in" Expr:e ")" Stmt:s => [[ drop v e s ast-for-in boa ]]
                     | "switch" "(" Expr:e ")" "{" SwitchBody:cs "}" => [[ drop e cs ast-switch boa ]]
                     | "break" Sc                                    => [[ drop ast-break boa ]]
                     | "continue" Sc                                 => [[ drop ast-continue boa ]]
                     | "throw" SpacesNoNl Expr:e Sc                  => [[ drop e ast-throw boa ]]
                     | "try" Block:t "catch" "(" Name:e ")" Block:c Finally:f => [[ drop t e c f ast-try boa ]]
                     | "return" Expr:e Sc                            => [[ drop e ast-return boa ]]
                     | "return" Sc                                   => [[ drop "undefined" ast-get boa ast-return boa ]]
                     | Expr:e Sc                                     => [[ drop e ]]
                     | ";"                                           => [[ drop "undefined" ast-get boa ]]
SrcElem            =   "function" Name:n FuncRest:f                  => [[ drop n f ast-var boa ]]
                     | Stmt
SrcElems           = (SrcElem)*                                      => [[ ast-begin boa ]]
TopLevel           = SrcElems Spaces                               
;EBNF