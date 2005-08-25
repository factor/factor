This is the infix minilanguage created by Daniel Ehrenberg, allowing you to do infix math in Factor. The syntax is simple: all infix are right-associative and parentheses may be used. There are also unary operators and operators which take arguments in square brackets seperated by semicolons. Infix operators are the ones that are made of non-alphabetic characters. To make a word that uses infix, the syntax is MATH: functionname[firstarg;secondarg;etc]=value ; Args are one or more variables that you use in the expression. Their values come from the stack. Variables are effectively substituted in to the expression. Any alphabetic string may be used as a variable. To make a new operator, just update the functions hashtable in the infix vocabulary. For more information, see the code or contact the author of this program. To close, here's an implementation of the quadratic formula using infix math. This is included in the module.

MATH: quadratic[a;b;c] =
    plusmin[(-b)/2*a;(sqrt(b^2)-4*a*c)/2*a] ;

If you find any bugs in this or have any questions, please contact me at microdan @ gmail . com, ask LittleDan@irc.freenode.net, or ask irc.freenode.net/#concatenative
