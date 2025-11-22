USING: accessors arrays assocs effects kernel math reverse
math.functions sequences stack-checker quotations variants
classes.maybe
help help.syntax help.markup ;
IN: monadics

ARTICLE: "functor" "Functors" 
   "Functors are data structures that support lazy mapping through an instance of " { $link fmap } "."
   { $examples 
      { $example "USING: math monadics prettyprint quotations ;" "6 just [ 1 + ] fmap ." "T{ Just { value 7 } }" }
   $nl "Values that cannot return a single value immediately are \"thunked\" as curried quotations:"
      { $example "USING: combinators math monadics sequences prettyprint quotations ; "
                 "{ 1 2 3 } [ + ] fmap ." 
                 "{ [ 1 + ] [ 2 + ] [ 3 + ] }" }
   "For details on this vocabulary's implementation of lazyness: " { $link "monad-implementation" } "."
   } ;

ARTICLE: "applicative" "Applicative Functors"
   { $link fmap } "'ping a function over a structure can alternatively be thought of as raising a unary function" { $snippet " ( a -- b ) " } " to a higher level of abstraction" { $snippet " ( M-a -- M-b )" } ". " $nl Applicative functors extend this notion to functions of any arity. The { $link lift } "/" { $link <$> } "words perform the same lazy \"raising\" as " { $link fmap } " while preserving function input order. This lifted, partially applied function can then be collapsed to a value by applying inputs through the " { $link reify } "/" { $link <*> } " words."
   { $examples 
      { $example "USING: arrays monadics quotations prettyprint ;"
                     "[ 3array ] { 1 4 7 } <$> { 2 5 8 } <*> { 3 6 9 } <*> ." 
                     "{ { 1 2 3 } { 4 5 6 } { 7 8 9 } }" }
   }
      { $example "USING: math monadics quotations prettyprint ;"
                     "[ + ] 6 right <$> 1 right <*> ." 
                     "T{ Right { value 7 } }" 
   }
   { $curious "\"Lifted partially applied function\" actually means \"A datastructure of incomplete quotations\":"
      { $example "USING: arrays monadics ;"
                 "{ 1 4 7 } [ 3array ] fmap ." 
                 "{ [ 1 3array ] [ 4 3array ] [ 7 3array ] }" }
   "Unlike in e.g. Haskell, " { $link <$> } " is not a direct alias of " { $link fmap } ", as Factor's stack based nature means that using fmap directly for applicative style code would result in inputs being reversed." } ;

ARTICLE: "monad" "Monads"
   "Monads are datastructures for which there exists a notion of sequential operation, composed by the " { $link and-then } "/" { $link >>= } combinator:
   { $code "( M-x quot: ( x -- M-y ) -- M-y )" }
   $nl "For the " { $link Maybe } " and " { $link Either } " types this encompasses the concept of validation, or short circuiting: "
   { $unchecked-example "USING: strings monadics quotations prettyprint unicode ;"
   ": trivial-password-validator ( string -- Maybe-string )"
   "    just [  [ lower? not ] guard-maybe ] >>=  "
   "         [  [ upper? not ] guard-maybe ] >>= ;"
   "\"hello\" trivial-password-validator ."
   "Nothing" 
   } 
   $nl "In a " { $link sequence } " context, the quotation permutes over each element: "
   ! TODO: Surely there has to be a more useful example...
   { $example "USING: ranges math monadics quotations prettyprint ; "
   "{ 1 2 3 4 } [ [ 0 ] dip (a..b] ] >>= ."
   "V{ 1 1 2 1 2 3 1 2 3 4 }"
   } ;


ARTICLE: "monad-implementation" "Monadic Implementation Quirks"
  "Implementations of " { $link fmap } ", " { $link reify } ", and " { $link and-then } " are all built around the " { $link lazy-call } " combinator. This combinator emulates the behavior of lazily evaluated languages like Haskell by currying input over a quotation until it's type signature matches " { $snippet "( -- x )" } " . As such, any input functions to these functions must eventually resolve to a single output."
   { $example "USING: arrays math.quadratic monadics quotations prettyprint ; "
     "! Unevaluated ( -- x x ) quotation will remain thunked. "
     "[ quadratic ] 1 just <$> 0 just <*> -1 just <*> . "
     "T{ Just { value [ -1 0 1 3 nreverse quadratic ] } }"
    }

"This is easy to fix using a word like " { $link 2array } "."
   { $example "USING: arrays math.quadratic monadics quotations prettyprint ; "
     "! Computes result into Maybe value as expected. "
     "[ quadratic 2array ] 1 just <$> 0 just <*> -1 just <*> . "
     "T{ Just { value { 1.0 -1.0 } } }"
   }
   ;

ARTICLE: "monadics" "Monadics"
"The " { $vocab-link "monadics" } " vocabulary is an alternative implementation of Haskell-styled Functors, Applicatives, and Monads to that found in the old " { $vocab-link "monads" } " vocabulary. This vocabulary implements Monad instances for: "
{ $subsections Maybe
               Either
               sequence }
"Functors represent data structures which can be lazily mapped over: "
{ $subsections "functor" }
"The notion of \"mapping\" is equivalent to raising a unary function to a more abstract sturcture. Applicatives extend this notion to functions with any number of inputs: "
{ $subsections "applicative" }
"Monads are the class of data structures for which there exists a notion of sequential (\"And then...\") operation:"
{ $subsections "monad" }

{ $subsections "monad-implementation" } 
   ;

ABOUT: "monadics"

HELP: Maybe 
   { $description "A Maybe either holds " { $snippet "Just" } " a value or is Nothing. Operations done on Nothing will return Nothing:"
      { $example "USING: math monadics prettyprint ;" "5 just [ 1 + ] fmap ." "T{ Just { value 6 } }" }
      { $example "USING: math monadics prettyprint ;" "[ + ] 5 just <$> Nothing <*> ." "Nothing" }
   "Just values are constructed with the " { $link just } " word, or turned from a generalized boolean by " { $link >maybe } ". "
   $nl "Not to be confused with the all-lowercase " { $link maybe } "."
   } ;

HELP: Either
   { $description "An Either value holds either a \"correct\" " { $snippet "Right" } " value or a " { $snippet "Left" } " value, usually signifying an error of some kind. Any action over a Left value preserves the Left value instead."
      { $example "USING: math monadics prettyprint ;" "[ + ] 5 right <$> \"Bad Input\" left <*> . " "T{ Left { value \"Bad Input\" } }" }
   { $see-also ?either validate }
   } ;

HELP: ?either
   { $values  { "x" "an object" } { "left" "a fallback value" } { "pred" "a quotation of type " { $snippet "( x -- bool )" } }
              { "Either-x" "an " { $link Either } }
   }
   { $description "Calls " { $snippet "pred" } " on " { $snippet "x" } " and either raises the original value to a " { $snippet "Right" } " or replaces it with the fallback value as a " { $snippet "Left" } "." }
   { $examples
      { $example "USING: math monadics prettyprint ;" "90125 \"Not a number.\" [ number? ] ?either ." "T{ Right { value 90125 } }" }
      { $example "USING: math monadics prettyprint ;" "\"Hello!\" \"Not a number.\" [ number? ] ?either ." "T{ Left { value \"Not a number.\" } }" }
   }
   ;
HELP: validate
   { $values { "x" "an object" } { "pairs" "Array of pairs of form: " { $snippet "{ error-value [ predicate? ] }" } } 
   { "Either-x" "an " { $link Either } }
   }
   { $description "Applies each predicate to " { $snippet "x" } " in turn. If the result of any is " { $link f } ", " { $snippet "x" } " is replaced with " { $snippet "Left error-value" } " according to the predicate which it failed, otherwise, raises " { $snippet "x" } " to a " { $snippet "Right" } " value." }
   { $examples
      { $unchecked-example "USING: kernel math monadics sequences sets prettyprint ;"
   ": trivial-validate-username ( string -- Either-string )"
   "    { { \"Name is too long.\""
   "      [ length 32 < ] }"
   "    { \"Forbidden Characters.\""
   "      [ \"(){}<>\\\"\" intersect { } = ] }"
   "    } validate ;"
   "\"EvilUsername\\\"\" trivial-validate-username . "
   "T{ Left { value \"Forbidden Characters.\" } }"
      }
   } ;
