! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences multiline
peg peg.ebnf peg.javascript.ast peg.javascript.tokenizer ;
IN: peg.javascript.parser

! Grammar for JavaScript. Based on OMeta-JS example from:
! http://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler

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
EBNF: javascript [=[
tokenizer         = default
nl                = "\r\n" | "\n"

tokenizer         = <foreign tokenize-javascript Tok>
End               = !(.)
Space             = [ \t\n]
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
Bindings           = (Binding ("," Binding => [[ second ]])* => [[ first2 swap prefix ]])?
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
