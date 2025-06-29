USING: help.markup help.syntax kernel math sequences ;
IN: math.runge-kutta 

HELP: <runge-kutta>
{ $values { "initial-delta" number } { "dxn..n/dt" sequence } { "initial-x..nt" sequence } { "t-limit" number } { "seq" sequence } }
{ $description "Simple runge-kutta implementation for generating approximated solutions for a set of first order differential equations" }
{ $examples
    "A lorenz attractor is a popular system to model with this: "
    { $code "USING: math.runge-kutta math.runge-kutta.examples ;" "lorenz." }
    "note that the produced chart is a 2 dimensional representation of a 3 dimensional solution. "
    "Similarly, the rabinovich-fabrikant system (stable alpha-gamma limit cycle): "
    { $code "USING: math.runge-kutta math.runge-kutta.examples ;" "rabinovich-fabrikant." }
} ;

