! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors peg peg.ebnf peg.javascript.ast peg.javascript.tokenizer ;
IN: peg.javascript.parser

#! Grammar for JavaScript. Based on OMeta-JS example from:
#! http://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler 

#! The interesting thing about this parser is the mixing of
#! a default and non-default tokenizer. The JavaScript tokenizer
#! removes all newlines. So when operating on tokens there is no
#! need for newline and space skipping in the grammar. But JavaScript
#! uses the newline in the 'automatic semicolon insertion' rule. 
#!
#! If a statement ends in a newline, sometimes the semicolon can be
#! skipped. So we define an 'nl' rule using the default tokenizer. 
#! This operates a character at a time. Using this 'nl' in the parser
#! allows us to detect newlines when we need to for the semicolon
#! insertion rule, but ignore it in all other places.
EBNF: javascript
tokenizer         = default 
nl                = "\n"

tokenizer         = <foreign tokenize-javascript Tok>
End               = !(.)
Space             = " " | "\t" | "\n" 
Spaces            = Space* => [[ ignore ]]
Name               = . ?[ ast-name?   ]?   => [[ value>> ]] 
Number             = . ?[ ast-number? ]?   => [[ value>> ]]
String             = . ?[ ast-string? ]?   => [[ value>> ]]
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
                     | OrExpr:e                         => [[ e ]]

OrExpr             =   OrExpr:x "||" AndExpr:y          => [[ x y "||" ast-binop boa ]]
                     | AndExpr
AndExpr            =   AndExpr:x "&&" EqExpr:y          => [[ x y "&&" ast-binop boa ]]
                     | EqExpr
EqExpr             =   EqExpr:x "==" RelExpr:y          => [[ x y "==" ast-binop boa ]]
                     | EqExpr:x "!=" RelExpr:y          => [[ x y "!=" ast-binop boa ]]
                     | EqExpr:x "===" RelExpr:y         => [[ x y "===" ast-binop boa ]]
                     | EqExpr:x "!==" RelExpr:y         => [[ x y "!==" ast-binop boa ]]
                     | RelExpr
RelExpr            =   RelExpr:x ">" AddExpr:y          => [[ x y ">" ast-binop boa ]]
                     | RelExpr:x ">=" AddExpr:y         => [[ x y ">=" ast-binop boa ]]
                     | RelExpr:x "<" AddExpr:y          => [[ x y "<" ast-binop boa ]]
                     | RelExpr:x "<=" AddExpr:y         => [[ x y "<=" ast-binop boa ]]
                     | RelExpr:x "instanceof" AddExpr:y => [[ x y "instanceof" ast-binop boa ]]
                     | AddExpr
AddExpr            =   AddExpr:x "+" MulExpr:y          => [[ x y "+" ast-binop boa ]]
                     | AddExpr:x "-" MulExpr:y          => [[ x y "-" ast-binop boa ]]
                     | MulExpr
MulExpr            =   MulExpr:x "*" MulExpr:y          => [[ x y "*" ast-binop boa ]]
                     | MulExpr:x "/" MulExpr:y          => [[ x y "/" ast-binop boa ]]
                     | MulExpr:x "%" MulExpr:y          => [[ x y "%" ast-binop boa ]]
                     | Unary
Unary              =   "-" Postfix:p                    => [[ p "-" ast-unop boa ]]
                     | "+" Postfix:p                    => [[ p ]]
                     | "++" Postfix:p                   => [[ p "++" ast-preop boa ]]
                     | "--" Postfix:p                   => [[ p "--" ast-preop boa ]]
                     | "!" Postfix:p                    => [[ p "!" ast-unop boa ]]
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
                     | Number                                => [[ ast-number boa ]]
                     | String                                => [[ ast-string boa ]]
                     | "function" FuncRest:fr                => [[ fr ]]
                     | "new" Name:n "(" Args:as ")"          => [[ n as ast-new boa ]]
                     | "[" Args:es "]"                       => [[ es ast-array boa ]]
                     | Json
JsonBindings        = (JsonBinding ("," JsonBinding => [[ second ]])* => [[ first2 swap prefix ]])?
Json               = "{" JsonBindings:bs "}"                  => [[ bs ast-json boa ]]
JsonBinding        = JsonPropName:n ":" Expr:v               => [[ n v ast-binding boa ]]
JsonPropName       = Name | Number | String
Formal             = Spaces Name
Formals            = (Formal ("," Formal => [[ second ]])*  => [[ first2 swap prefix ]])?
FuncRest           = "(" Formals:fs ")" "{" SrcElems:body "}" => [[ fs body ast-func boa ]]
Sc                 = SpacesNoNl (nl | &("}") | End)| ";"
Binding            =   Name:n "=" Expr:v                      => [[ n v ast-var boa ]]
                     | Name:n                                 => [[ n "undefined" ast-get boa ast-var boa ]]
Block              = "{" SrcElems:ss "}"                      => [[ ss ]]
Bindings           = (Binding ("," Binding => [[ second ]])* => [[ first2 swap prefix ]])?
For1               =   "var" Binding => [[ second ]] 
                     | Expr 
                     | Spaces => [[ "undefined" ast-get boa ]] 
For2               =   Expr
                     | Spaces => [[ "true" ast-get boa ]] 
For3               =   Expr
                     | Spaces => [[ "undefined" ast-get boa ]] 
ForIn1             =   "var" Name:n => [[ n "undefined" ast-get boa ast-var boa ]]
                     | Expr
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
                     | Expr:e Sc                                     => [[ e ]]
                     | ";"                                           => [[ "undefined" ast-get boa ]]
SrcElem            =   "function" Name:n FuncRest:f                  => [[ n f ast-var boa ]]
                     | Stmt
SrcElems           = SrcElem*                                      => [[ ast-begin boa ]]
TopLevel           = SrcElems Spaces                               
;EBNF