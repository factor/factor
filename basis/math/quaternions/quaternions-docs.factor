USING: help.markup help.syntax math math.vectors vectors ;
IN: math.quaternions

HELP: q+
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u+v" "a quaternion" } }
{ $description "Add quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ C{ 0 1 } 0 } { 0 1 } q+ ." "{ C{ 0 1 } 1 }" } } ;

HELP: q-
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u-v" "a quaternion" } }
{ $description "Subtract quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ C{ 0 1 } 0 } { 0 1 } q- ." "{ C{ 0 1 } -1 }" } } ;

HELP: q*
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u*v" "a quaternion" } }
{ $description "Multiply quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ C{ 0 1 } 0 } { 0 1 } q* ." "{ 0 C{ 0 1 } }" } } ;

HELP: qconjugate
{ $values { "u" "a quaternion" } { "u'" "a quaternion" } }
{ $description "Quaternion conjugate." } ;

HELP: qrecip
{ $values { "u" "a quaternion" } { "1/u" "a quaternion" } }
{ $description "Quaternion inverse." } ;

HELP: q/
{ $values { "u" "a quaternion" } { "v" "a quaternion" } { "u/v" "a quaternion" } }
{ $description "Divide quaternions." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 0 C{ 0 1 } } { 0 1 } q/ ." "{ C{ 0 1 } 0 }" } } ;

HELP: q*n
{ $values { "q" "a quaternion" } { "n" number } { "q" "a quaternion" } }
{ $description "Multiplies each element of " { $snippet "q" } " by " { $snippet "n" } "." }
{ $notes "You will get the wrong result if you try to multiply a quaternion by a complex number on the right using " { $link v*n } ". Use this word instead."
    $nl "Note that " { $link v*n } " with a quaternion and a real is okay." } ;

HELP: c>q
{ $values { "c" number } { "q" "a quaternion" } }
{ $description "Turn a complex number into a quaternion." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "C{ 0 1 } c>q ." "{ C{ 0 1 } 0 }" } } ;

HELP: v>q
{ $values { "v" vector } { "q" "a quaternion" } }
{ $description "Turn a 3-vector into a quaternion with real part 0." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ 1 0 0 } v>q ." "{ C{ 0 1 } 0 }" } } ;

HELP: q>v
{ $values { "q" "a quaternion" } { "v" vector } }
{ $description "Get the vector part of a quaternion, discarding the real part." }
{ $examples { $example "USING: math.quaternions prettyprint ;" "{ C{ 0 1 } 0 } q>v ." "{ 1 0 0 }" } } ;

HELP: euler
{ $values { "phi" number } { "theta" number } { "psi" number } { "q" "a quaternion" } }
{ $description "Convert a rotation given by Euler angles (phi, theta, and psi) to a quaternion." } ;

