! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs help.markup help.syntax kernel logic.private
make quotations ;
IN: logic

HELP: !!
{ $var-description "The cut operator.\nUse the cut operator to suppress backtracking." }
{ $examples
  "In the following example, it is used to define that cats generally eat mice, but Tom does not."
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: is-ao consumeso ;"
    "LOGIC-VARS: X Y ;"
    "SYMBOLS: Tom Jerry Nibbles"
    "         mouse cat milk cheese fresh-milk Emmentaler ;"
    ""
    "{"
    "    { is-ao Tom cat }"
    "    { is-ao Jerry mouse }"
    "    { is-ao Nibbles mouse }"
    "    { is-ao fresh-milk milk }"
    "    { is-ao Emmentaler cheese }"
    "} facts"
    ""
    "{ consumeso X milk } {"
    "    { is-ao X mouse } ;;"
    "    { is-ao X cat }"
    "} rule"
    ""
    "{ consumeso X cheese } { is-ao X mouse } rule"
    "{ consumeso Tom mouse } { !! f } rule"
    "{ consumeso X mouse } { is-ao X cat } rule"
    ""
    "{ { consumeso Tom X } { is-ao Y X } } query ."
    "{ H{ { X milk } { Y fresh-milk } } }"
  }
} ;

HELP: (<)
{ $var-description "A logic predicate. It takes two arguments. It is true if both arguments are evaluated numerically and the first argument is less than the second, otherwise, it is false." }
{ $syntax "{ (<) X Y }" }
{ $see-also (>) (>=) (==) (=<) } ;

HELP: (=)
{ $var-description "A logic predicate. It unifies two arguments." }
{ $syntax "{ (=) X Y }" }
{ $see-also (\=) is } ;

HELP: (=<)
{ $var-description "A logic predicate. It takes two arguments. It is true if both arguments are evaluated numerically and the first argument equals or is less than the second, otherwise, it is false." }
{ $syntax "{ (=<) X Y }" }
{ $see-also (>) (>=) (==) (<) } ;

HELP: (==)
{ $var-description "A logic predicate. It tests for equality of two arguments. Evaluating two arguments, true if they are the same, false if they are different." }
{ $syntax "{ (==) X Y }" }
{ $see-also (>) (>=) (=<) (<) =:= =\= } ;

HELP: (>)
{ $var-description "A logic predicate. It is true if both arguments are evaluated numerically and the first argument is greater than the second, otherwise, it is false." }
{ $syntax "{ (>) X Y }" }
{ $see-also (>=) (==) (=<) (<) } ;

HELP: (>=)
{ $var-description "A logic predicate. It is true if both arguments are evaluated numerically and the first argument equals or is greater than the second, otherwise, it is false." }
{ $syntax "{ (>=) X Y }" }
{ $see-also (>) (==) (=<) (<) } ;

HELP: (\=)
{ $var-description "A logic predicate. It will be true when such a unification fails. Note that " { $snippet "(\\=)" } " does not actually do the unification." }
{ $syntax "{ (\\=) X Y }" }
{ $see-also (=) } ;

HELP: (\==)
{ $var-description "A logic predicate. It tests for inequality of two arguments. Evaluating two arguments, true if they are different, false if they are the same." }
{ $syntax "{ (\\==) X Y }" }
;

HELP: ;;
{ $var-description "Is used to represent disjunction. The code below it has the same meaning as the code below it.
"
{ $code
  "Gh { Gb1 Gb2 Gb3 ;; Gb4 Gb5 ;; Gb6 } rule" }
""
{ $code
  "Gh { Gb1 Gb2 Gb3 } rule"
  "Gh { Gb4 Gb5 } rule:
Gh { Gb6 } rule" }
} ;

HELP: =:=
{ $values
    { "quot" quotation }
    { "goal" logic-goal }
}
{ $description "The quotations takes an environment and returns two values. " { $snippet "=:=" } " returns the internal representation of the goal which returns t if values returned by the quotation are same numbers.\n" { $snippet "=:=" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." }
{ $see-also (==) =\= } ;

HELP: =\=
{ $values
    { "quot" quotation }
    { "goal" logic-goal }
}
{ $description "The quotations takes an environment and returns two values. " { $snippet "=\\=" } " returns the internal representation of the goal which returns t if values returned by the quotation are numbers and are not same.\n" { $snippet "=\\=" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." }
{ $see-also (==) =:= } ;

HELP: LOGIC-PRED:
{ $description "Creates a new logic predicate." }
{ $syntax "LOGIC-PRED: pred" }
{ $examples
  { $code
    "USE: logic"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: cato"
    "SYMBOL: Tom"
    ""
    "{ cato Tom } fact"
  }
}
{ $see-also \ LOGIC-PREDS: } ;

HELP: LOGIC-PREDS:
{ $description "Creates a new logic predicate for every token until the ;." }
{ $syntax "LOGIC-PREDS: preds... ;" }
{ $examples
  { $code
    "USE: logic"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: cato mouseo ;"
    "SYMBOLS: Tom Jerry ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
  }
}
{ $see-also \ LOGIC-PRED: } ;

HELP: LOGIC-VAR:
{ $description "Creates a new logic variable." }
{ $syntax "LOGIC-VAR: var" }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: mouseo"
    "LOGIC-VAR: X"
    "SYMBOL: Jerry"
    "{ mouseo Jerry } fact"
    "{ mouseo X } query ."
    "{ H{ { X Jerry } } }"
  }
}
{ $see-also \ LOGIC-VARS: } ;

HELP: LOGIC-VARS:
{ $description "Creates a new logic variable for every token until the ;." }
{ $syntax "LOGIC-VARS: vars... ;" }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: mouseo"
    "LOGIC-VARS: X ;"
    "SYMBOL: Jerry"
    "{ mouseo Jerry } fact"
    "{ mouseo X } query ."
    "{ H{ { X Jerry } } }"
  }
}
{ $see-also \ LOGIC-VAR: } ;

HELP: %!
{ $description "A multiline comment. Despite being a Prolog single-line comment, " { $link % } " is already well-known in Factor, so this variant is given instead." }
{ $syntax "%! comment !%" }
{ $examples
    { $example
        "USE: logic"
        "%! I think that I shall never see"
        "   A proof lovely as a factlog. !%"
        ""
    }
} ;

HELP: \+
{ $var-description "Express negation. \\+ acts on the goal immediately following it.\n" }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: cato mouseo creatureo ;"
    "LOGIC-VARS: X Y ;"
    "SYMBOLS: Tom Jerry Nibbles ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    "{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule"
    ""
    "LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;"
    ""
    "{ likes-cheeseo X } { mouseo X } rule"
    "{ dislikes-cheeseo Y } {
    { creatureo Y }
    \\+ { likes-cheeseo Y }
    } rule"
    "{ dislikes-cheeseo Jerry } query ."
    "{ dislikes-cheeseo Tom } query ."
    "f\nt"
  }
} ;

HELP: __
{ $var-description "An anonymous logic variable.\nUse in place of a regular logic variable when you do not need its name and value." }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "SYMBOLS: Tom Jerry Nibbles ;"
    "TUPLE: house living dining kitchen in-the-wall ;"
    "LOGIC-PRED: houseo"
    "LOGIC-VAR: X"

    ""
    "{ houseo T{ house"
    "             { living Tom }"
    "             { dining f }"
    "             { kitchen Nibbles }"
    "             { in-the-wall Jerry }"
    "         }"
    "} fact"
    ""
    "{ houseo T{ house"
    "             { living __ }"
    "             { dining __ }"
    "             { kitchen X }"
    "             { in-the-wall __ }"
    "         }"
    "} query ."
    "{ H{ { X Nibbles } } }"
  }
} ;

HELP: appendo
{ $var-description "A logic predicate. Concatenate two lists." }
{ $syntax "{ appendo List1 List2 List1+List2 }" }
{ $examples
  { $example
    "USING: logic lists prettyprint ;"
    "IN: scratchpad"
    ""
    "SYMBOLS: Tom Jerry Nibbles ;"
    "LOGIC-VARS: X Y ;"
    ""
    "{ appendo L{ Tom } L{ Jerry Nibbles } X } query ."
    "{ appendo L{ Tom } L{ Jerry Nibbles } L{ Jerry Nibbles Tom } } query ."
    "{ appendo X Y L{ Tom Jerry Nibbles } } query ."
    "{ H{ { X L{ Tom Jerry Nibbles } } } }\nf\n{\n    H{ { X L{ } } { Y L{ Tom Jerry Nibbles } } }\n    H{ { X L{ Tom } } { Y L{ Jerry Nibbles } } }\n    H{ { X L{ Tom Jerry } } { Y L{ Nibbles } } }\n    H{ { X L{ Tom Jerry Nibbles } } { Y L{ } } }\n}"
  }
} ;

HELP: callback
{ $values
    { "head" array } { "quot" quotation }
}
{ $description "Set the quotation to be called. Such quotations take an environment which holds the binding of logic variables, and returns t or " { $link f } " as a result of execution. To retrieve the values of logic variables in the environment, use " { $link of } " or " { $link at } "." }
{ $examples
  { $code
    "LOGIC-PRED: N_>_0"
    "{ N_>_0 N } [ N of 0 > ] callback"
  }
}
{ $see-also callbacks } ;

HELP: callbacks
{ $values
    { "defs" array }
}
{ $description "To collectively register a plurality of " { $link callback } "s." }
{ $examples
  { $code "LOGIC-PREDS: N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
{
    { { N_>_0 N } [ N of 0 > ] }
    { N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] }
    { F_is_F2_*_N F F2 N } [ dup [ F2 of ] [ N of ] bi * F unify ] }
} callbacks" }
}
{ $see-also callback } ;

HELP: clear-pred
{ $values
    { "pred" "a logic predicate" }
}
{ $description "Clears all the definition information for the given logic predicate." }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: mouseo"
    "SYMBOLS: Jerry Nibbles ;"
    "LOGIC-VAR: X"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ mouseo X } query ."
    "mouseo clear-pred"
    "{ mouseo X } query ."
    "{ H{ { X Jerry } } H{ { X Nibbles } } }\nf"
  }
}
{ $see-also retract retract-all } ;

HELP: fact
{ $values
    { "head" "an array representing a goal" }
}
{ $description "Registers the fact to the end of the logic predicate that is in the head." }
{ $examples
  { $code
    "USE: logic"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: cato mouseo ;"
    "SYMBOLS: Tom Jerry ;"
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
  }
}
{ $see-also fact* facts } ;

HELP: fact*
{ $values
    { "head" "an array representing a goal" }
}
{ $description "Registers the fact to the beginning of the logic predicate that is in the head." }
{ $see-also fact facts } ;

HELP: facts
{ $values
    { "defs" array }
}
{ $description "Registers these facts to the end of the logic predicate that is in the head." }
{ $examples
  { $code
    "USE: logic"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: cato mouseo ;"
    ""
    "{ { cato Tom } { mouseo Jerry } } facts"
  }
}
{ $see-also fact fact* } ;

HELP: failo
{ $var-description "A built-in logic predicate. { " { $snippet "failo" } " } is a goal that is always " { $link f } "." }
{ $syntax "{ failo }" }
{ $see-also trueo } ;

HELP: is
{ $values
    { "quot" quotation } { "dist" "a logic predicate" }
    { "goal" logic-goal }
}
{ $description "Takes a quotation and a logic variable to be unified. Each of the two quotations takes an environment and returns a value. " { $snippet "is" } " returns the internal representation of the goal.\n" { $snippet "is" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." } ;

HELP: invoke
{ $values
    { "quot" quotation }
    { "goal" logic-goal }
}
{ $description "Creates a goal which uses the values of obtained logic variables. It can be used to add new rules to or drop rules from the database while a " { $link query } " is running.\nThe argument " { $snippet "quot" } " must not return any values, the created goal always return " { $link t } ".\n" { $snippet "invoke" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." }
{ $examples
  "In this example, the calculated values are memorized to eliminate recalculation."
  { $example
    "USING: logic kernel lists assocs locals math prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: fibo"
    "LOGIC-VARS: F F1 F2 N N1 N2 ;"
    ""
    "{ fibo 1 1 } fact"
    "{ fibo 2 1 } fact"
    "{ fibo N F } {"
    "    { (>) N 2 }"
    "    [ [ N of 1 - ] N1 is ] { fibo N1 F1 }"
    "    [ [ N of 2 - ] N2 is ] { fibo N2 F2 }"
    "    [ [ [ F1 of ] [ F2 of ] bi + ] F is ]"
    "    ["
    "        ["
    "            [ N of ] [ F of ] bi"
    "            [let :> ( nv fv ) { fibo nv fv } !! rule* ]"
    "        ] invoke ]"
    "} rule"
    ""
    "{ fibo 10 F } query ."
    "{ H{ { F 55 } } }"
  }
}
{ $see-also invoke* } ;

HELP: invoke*
{ $values
    { "quot" quotation }
    { "goal" logic-goal }
}
{ $description "Creates a goal which uses the values of obtained logic variables. The difference with " { $link invoke } " is that " { $snippet "quot" } " returns " { $link t } " or " { $link f } ", and the created goal returns it.\n" { $snippet "invoke*" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." }
{ $see-also invoke } ;

HELP: lengtho
{ $var-description "A logic predicate. Instantiate the length of the list." }
{ $syntax "{ lengtho List X }" }
{ $examples
  { $example
    "USING: logic lists prettyprint ;"
    "IN: scratchpad"
    ""
    "SYMBOLS: Tom Jerry Nibbles ;"
    "LOGIC-VAR: X"
    ""
    "{ lengtho L{ Tom Jerry Nibbles } 3 } query ."
    "{ lengtho L{ Tom Jerry Nibbles } X } query ."
    "t\n{ H{ { X 3 } } }"
  }
} ;

HELP: listo
{ $var-description "A logic predicate. Takes a single argument and checks to see if it is a list." }
{ $syntax "{ listo X }" }
{ $examples
  { $example
    "USING: logic lists prettyprint ;"
    "IN: scratchpad"
    ""
    "SYMBOLS: Tom Jerry Nibbles ;"
    ""
    "{ listo L{ Jerry Nibbles } } query ."
    "{ listo Tom } query ."
    "t\nf"
  }
} ;

HELP: membero
{ $var-description "A logic predicate for the relationship an element is in a list." }
{ $syntax "{ membero X List }" }
{ $examples
  { $example
    "USING: logic lists prettyprint ;"
    "IN: scratchpad"
    ""
    "SYMBOLS: Tom Jerry Nibbles Spike ;"
    ""
    "{ membero Jerry L{ Tom Jerry Nibbles } } query ."
    "{ membero Spike L{ Tom Jerry Nibbles } } query ."
    "t\nf"
  }
} ;

HELP: nlo
{ $var-description "A logic predicate. Print line breaks." }
{ $syntax "{ nlo }" }
{ $see-also writeo writenlo } ;

HELP: nonvaro
{ $var-description "A logic predicate. " { $snippet "nonvaro" } " takes a single argument and is true if its argument is not a logic variable or is a concrete logic variable." }
{ $syntax "{ nonvaro X }" }
{ $see-also varo } ;

HELP: notrace
{ $description "Stop tracing." }
{ $see-also trace } ;

HELP: query
{ $values
    { "goal-def/defs"  "a goal def or an array of goal defs" }
    { "bindings-array/success?" "anser" }
}
{ $description
  "Inquire about the order of goals. The general form of a query is:

    { G1 G2 ... Gn } query

This G1, G2, ... Gn is a conjunction. When all of them are satisfied, it becomes " { $link t } ".

If there is only one goal, you can use its abbreviation.

    G1 query

When you query with logic variable(s), you will get the answer for the logic variable(s). For such queries, an array of hashtables with logic variables as keys is returned.
"
}
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: cato mouseo creatureo ;"
    "LOGIC-VARS: X Y ;"
    "SYMBOLS: Tom Jerry Nibbles ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ cato Tom } query ."
    "{ { cato Tom } { cato Jerry } } query ."
    "{ mouseo X } query ."
    "t\nf\n{ H{ { X Jerry } } H{ { X Nibbles } } }"
  }
}
{ $see-also nquery } ;

HELP: nquery
{ $values
    { "goal-def/defs" "a goal def or an array of goal defs" } { "n/f" "the highest number of responses" }
    { "bindings-array/success?" "anser" }
}
{ $description "The version of " { $link query } " that limits the number of responses. Specify a number greater than or equal to 1.
If " { $link f } " is given instead of a number as " { $snippet "n/f" } ", there is no limit to the number of answers. That is, the behavior is the same as " { $link query } "." }
{ $see-also query } ;

HELP: retract
{ $values
    { "head-def" "a logic predicate" }
}
{ $description "Removes the first definition that matches the given head information." }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: mouseo"
    "SYMBOLS: Jerry Nibbles ;"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ mouseo X } query ."
    "{ mouseo Jerry } retract"
    "{ mouseo X } query ."
    "{ H{ { X Jerry } } H{ { X Nibbles } } }\n{ H{ { X Nibbles } } }"
  }
}
{ $see-also retract-all clear-pred } ;

HELP: retract-all
{ $values
    { "head-def" "a logic predicate" }
}
{ $description "Removes all definitions that match a given head goal definition." }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PRED: mouseo"
    "SYMBOLS: Jerry Nibbles ;"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ mouseo X } query ."
    "{ mouseo __ } retract-all"
    "{ mouseo X } query ."
    "{ H{ { X Jerry } } H{ { X Nibbles } } }\nf"
  }
}
{ $see-also retract clear-pred } ;

HELP: rule
{ $values
    { "head" "an array representing a goal" } { "body" "an array of goals or a goal" }
}
{ $description "Registers the rule to the end of the logic predicate that is in the head.
The general form of rule is:

    Gh { Gb1 Gb2 ... Gbn } rule

This means Gh when all goals of Gb1, Gb2, ..., Gbn are met. This Gb1 Gb2 ... Gbn is a conjunction.
If the body array contains only one goal definition, you can write it instead of the body array. That is, they are equivalent.

    Gh { Gb } rule
    Gh Gb rule" }
{ $examples
  { $example
    "USING: logic prettyprint ;"
    "IN: scratchpad"
    ""
    "LOGIC-PREDS: mouseo youngo young-mouseo ;"
    "SYMBOLS: Jerry Nibbles ;"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    "{ youngo Nibbles } fact"
    ""
    "{ young-mouseo X } {"
    "    { mouseo X }"
    "    { youngo X }"
    "} rule"
    ""
    "{ young-mouseo X } query ."
    "{ H{ { X Nibbles } } }"
  }
}
{ $see-also rule* rules } ;

HELP: rule*
{ $values
    { "head" "an array representing a goal" } { "body" "an array of goals or a goal" }
}
{ $description "Registers the rule to the beginnung of the logic predicate that is in the head." }
{ $see-also rule rules } ;

HELP: rules
{ $values
  { "defs" "an array of rules" }
}
{ $description "Registers these rules to the end of the logic predicate that is in these heads." }
{ $examples
  { $code
    "LOGIC-PREDS: is-ao consumeso ;"
    "SYMBOLS: Tom Jerry Nibbles ;"
    "SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;"
    ""
    "{"
    "    { is-ao Tom cat }"
    "    { is-ao Jerry mouse }"
    "    { is-ao Nibbles mouse }"
    "    { is-ao fresh-milk milk }"
    "    { is-ao Emmentaler cheese }"
    "} facts"
    ""
    "{"
    "    {"
    "        { consumeso X milk } {"
    "            { is-ao X mouse } ;;"
    "            { is-ao X cat }"
    "        }"
    "    }"
    "    { { consumeso X cheese } { is-ao X mouse } }"
    "    { { consumeso X mouse } { is-ao X cat } }"
    "} rules"
  }
}
{ $see-also rule rule* } ;

HELP: trace
{ $description "Start tracing." }
{ $see-also notrace } ;

HELP: trueo
{ $var-description "A logic predicate. { " { $snippet "trueo" } " } is a goal that is always " { $link t } "." }
{ $syntax "{ trueo }" }
{ $see-also failo } ;

HELP: unify
{ $values
    { "cb-env" callback-env } { "x" object } { "y" object }
    { "success?" boolean }
}
{ $description "Unifies the two following the environment in that environment." } ;

HELP: varo
{ $var-description "A logic predicate. " { $snippet "varo" } " takes a argument and is true if it is a logic variable with no value." }
{ $syntax "{ varo X }" }
{ $see-also nonvaro } ;

HELP: writenlo
{ $var-description "A logic predicate. print a single sequence or string and return a new line." }
{ $syntax "{ writenlo X }" }
{ $see-also writeo nlo } ;

HELP: writeo
{ $var-description "A logic predicate. print a single sequence or string of characters." }
{ $syntax "{ writeo X }" }
{ $see-also writenlo nlo } ;

ARTICLE: "logic" "Logic"
{ $vocab-link "logic" }
" is a vocab for an embedded language that runs on " { $url "https://github.com/factor/factor" "Factor" } " with the capabilities of a subset of Prolog." $nl
"It is an extended port from tiny_prolog and its descendants, " { $url "https://github.com/preston/ruby-prolog" "ruby-prolog" } "." $nl
{ $code
"USE: logic

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;"
} $nl
"In the DSL, words that represent relationships are called " { $strong "logic predicates" } ". Use " { $link \ LOGIC-PRED: } " or " { $link \ LOGIC-PREDS: } " to declare the predicates you want to use. " { $strong "Logic variables" } " are used to represent relationships. use " { $link \ LOGIC-VAR: } " or " { $link \ LOGIC-VARS: } " to declare the logic variables you want to use." $nl
"In the above code, logic predicates end with the character 'o', which is a convention borrowed from miniKanren and so on, and means relation. This is not necessary, but it is useful for reducing conflicts with the words of, the parent language, Factor. We really want to write them as: " { $snippet "cat°" } ", " { $snippet "mouse°" } " and " { $snippet "creature°" } ", but we use 'o' because it's easy to type." $nl
{ $strong "Goals" } " are questions that " { $snippet "logic" } " tries to meet to be true. To represent a goal, write an array with a logic predicate followed by zero or more arguments. " { $snippet "logic" } " converts such definitions to internal representations." $nl
{ $code "{ LOGIC-PREDICATE ARG1 ARG2 ... }" }
{ $code "{ LOGIC-PREDICATE }" } $nl
"We will write logic programs using these goals." $nl
{ $code
"{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact"
} $nl
"The above code means that Tom is a cat and Jerry and Nibbles are mice. Use " { $link fact } " to describe the " { $strong "facts" } "." $nl
{ $unchecked-example
"{ cato Tom } query ."
"t"
} $nl
"The above code asks, \"Is Tom a cat?\". We said,\"Tom is a cat.\", so the answer is " { $link t } ". The general form of a query is:" $nl
{ $code "{ G1 G2 ... Gn } query" } $nl
"The parentheses are omitted because there was only one goal to be satisfied earlier, but here is an example of two goals:" $nl
{ $unchecked-example
"{ { cato Tom } { cato Jerry } } query ."
"f"
} $nl
"Tom is a cat, but Jerry is not declared a cat, so " { $link f } " is returned in response to this query." $nl
"If you query with logic variable(s), you will get the answer for the logic variable(s). For such queries, an array of hashtables with logic variables as keys is returned." $nl
{ $unchecked-example
"{ mouseo X } query ."
"{ H{ { X Jerry } } H{ { X Nibbles } } }"
} $nl
"The following code shows that if something is a cat, it's a creature. Use " { $link rule } " to write " { $strong "rules" } "." $nl
{ $code
  "{ creatureo X } { cato X } rule"
} $nl
"According to the rules above, \"Tom is a creature.\" is answered to the following questions:" $nl
{ $unchecked-example
"{ creatureo Y } query ."
"{ H{ { Y Tom } } }"
} $nl
"The general form of " { $link rule } " is:" $nl
{ $code "Gh { Gb1 Gb2 ... Gbn } rule" } $nl
"This means " { $snippet "Gh" } " when all goals of " { $snippet "Gb1" } ", " { $snippet "Gb2" } ", ..., " { $snippet "Gbn" } " are met. This " { $snippet "Gb1 Gb2 ... Gbn" } " is a " { $strong "conjunction" } "." $nl
{ $unchecked-example
"LOGIC-PREDS: youngo young-mouseo ;

{ youngo Nibbles } fact

{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} rule

{ young-mouseo X } query ."
"{ H{ { X Nibbles } } }"
} $nl
"This " { $snippet "Gh" } " is called " { $strong "head" } " and the " { $snippet "{ Gb 1Gb 2... Gbn }" } " is called " { $strong "body" } "." $nl
"Facts are rules where its body is an empty array. So, the form of " { $link fact } " is:" $nl
{ $code "Gh fact" } $nl
"Let's describe that mice are also creatures." $nl
{ $unchecked-example
"{ creatureo X } { mouseo X } rule

{ creatureo X } query ."
"{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }"
} $nl
"To tell the truth, we were able to describe at once that cats and mice were creatures by doing the following." $nl
{ $code
"LOGIC-PRED: creatureo

{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule"
} $nl
{ $link ;; } " is used to represent " { $strong "disjunction" } ". The following two forms are equivalent:" $nl
{ $code "Gh { Gb1 Gb2 Gb3 ;; Gb4 Gb5 ;; Gb6 } rule" }
$nl
{ $code
  "Gh { Gb1 Gb2 Gb3 } rule"
  "Gh { Gb4 Gb5 } rule"
  "Gh { Gb6 } rule"
} $nl
{ $snippet "logic" } " actually converts the disjunction in that way. You may need to be careful about that when deleting definitions that you registered using " { $link rule } ", etc." $nl
"You can use " { $link nquery } " to limit the number of answers to a query. Specify a number greater than or equal to 1." $nl
{ $unchecked-example
"{ creatureo Y } 2 nquery ."
"{ H{ { Y Tom } } H{ { Y Jerry } } }"
} $nl
"Use " { $link \+ } " to express " { $strong "negation" } ". " { $link \+ } " acts on the goal immediately following it." $nl
{ $unchecked-example
"LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;

{ likes-cheeseo X } { mouseo X } rule

{ dislikes-cheeseo Y } {
    { creatureo Y }
    \\+ { likes-cheeseo Y }
} rule"
"{ dislikes-cheeseo Jerry } query ."
"{ dislikes-cheeseo Tom } query ."
"f\nt"
} $nl
"Other creatures might also like cheese..." $nl
"You can also use sequences, lists, and tuples as goal definition arguments." $nl
"The syntax of list descriptions allows you to describe \"head\" and \"tail\" of a list." $nl
{ $code "L{ HEAD . TAIL }" }
{ $code "L{ ITEM1 ITEM2 ITEM3 . OTHERS }" } $nl
"You can also write a quotation that returns an argument as a goal definition argument." $nl
{ $code "[ Tom Jerry Nibbles L{ } cons cons cons ]" } $nl
"When written as an argument to a goal definition, the following lines have the same meaning as above:" $nl
{ $code "L{ Tom Jerry Nibbles }" }
{ $code "L{ Tom Jerry Nibbles . L{ } }" }
{ $code "[ { Tom Jerry Nibbles } >list } ]" } $nl
"Such quotations are called only once when converting the goal definitions to internal representations." $nl
{ $link membero } " is a built-in logic predicate for the relationship an element is in a list." $nl
{ $unchecked-example
  "USE: lists
SYMBOL: Spike

{ membero Jerry L{ Tom Jerry Nibbles } } query .
{ membero Spike [ Tom Jerry Nibbles L{ } cons cons cons ] } query ."
"t\nf"
} $nl
"Recently, they moved into a small house. The house has a living room, a dining room and a kitchen. Well, humans feel that way. Each of them seems to be in their favorite room." $nl
{ $code
"TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PRED: houseo

{ houseo T{ house { living Tom } { dining f } { kitchen Nibbles } { in-the-wall Jerry } } } fact"
} $nl
"Don't worry about not mentioning the bathroom." $nl
"Let's ask who is in the kitchen." $nl
{ $unchecked-example
"{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query ."
"{ H{ { X Nibbles } } }"
} $nl
"These two consecutive underbars are called " { $strong "anonymous logic variables" } ". Use in place of a regular logic variable when you do not need its name and value." $nl
"It seems to be meal time. What do they eat?" $nl
{ $code
"LOGIC-PREDS: is-ao consumeso ;
SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;

{
    { is-ao Tom cat }
    { is-ao Jerry mouse }
    { is-ao Nibbles mouse }
    { is-ao fresh-milk milk }
    { is-ao Emmentaler cheese }
} facts

{
    {
        { consumeso X milk } {
            { is-ao X mouse } ;;
            { is-ao X cat }
        }
    }
    { { consumeso X cheese } { is-ao X mouse } }
    { { consumeso X mouse } { is-ao X cat } }
} rules"
} $nl
"Here, " { $link facts } " and " { $link rules } " are used. They can be used for successive facts or rules." $nl
"Let's ask what Jerry consumes." $nl
{ $unchecked-example
"{ { consumeso Jerry X } { is-ao Y X } } query ."
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X cheese } { Y Emmentaler } }
}"
} $nl
"Well, what about Tom?" $nl
{ $unchecked-example
"{ { consumeso Tom X } { is-ao Y X } } query ."
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X mouse } { Y Jerry } }
    H{ { X mouse } { Y Nibbles } }
}"
} $nl
"This is a problematical answer. We have to redefine " { $snippet "consumeso" } "." $nl
{ $code
"LOGIC-PRED: consumeso

{ consumeso X milk } {
    { is-ao X mouse } ;;
    { is-ao X cat }
} rule

{ consumeso X cheese } { is-ao X mouse } rule
{ consumeso Tom mouse } { !! f } rule
{ consumeso X mouse } { is-ao X cat } rule"
} $nl
"We wrote about Tom before about common cats. What two consecutive exclamation marks represent is called a " { $strong "cut" } " operator. Use the cut operator to suppress " { $strong "backtracking" } "." $nl
"The next letter " { $link f } " is an abbreviation for goal { " { $link failo } " } using the built-in logic predicate " { $link failo } ". { " { $link failo } " } is a goal that is always " { $link f } ". Similarly, there is a goal { " { $link trueo } " } that is always " { $link t } ", and its abbreviation is " { $link t } "." $nl
"By these actions, \"Tom consumes mice.\" becomes false and suppresses the examination of general eating habits of cats." $nl
{ $unchecked-example
"{ { consumeso Tom X } { is-ao Y X } } query ."
"{ H{ { X milk } { Y fresh-milk } } }"
} $nl
"It's OK. Let's check a cat that is not Tom." $nl
{ $unchecked-example
"SYMBOL: a-cat
{ is-ao a-cat cat } fact

{ { consumeso a-cat X } { is-ao Y X } } query ."
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X mouse } { Y Jerry } }
    H{ { X mouse } { Y Nibbles } }
}"
} $nl
"Jerry, watch out for the other cats." $nl
"So far, we've seen how to define a logic predicate with " { $link fact } ", " { $link rule } ", " { $link facts } ", and " { $link rules } ". Each time you use those words for a logic predicate, information is added to it." $nl
"You can clear these definitions with " { $link clear-pred } " for a logic predicate." $nl
{ $unchecked-example
"cato clear-pred
mouseo clear-pred
{ creatureo X } query ."
"f"
} $nl
{ $link fact } " and " { $link rule } " add a new definition to the end of a logic predicate, while " { $link fact* } " and " { $link rule* } " add them first. The order of the information can affect the results of a query." $nl
{ $unchecked-example
"{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact*

{ mouseo Y } query .

{ creatureo Y } 2 nquery ."
"{ H{ { Y Nibbles } } H{ { Y Jerry } } }\n{ H{ { Y Tom } } H{ { Y Nibbles } } }"
} $nl
"While " { $link clear-pred } " clears all the definition information for a given logic predicate, " { $link retract } " and " { $link retract-all } " provide selective clearing." $nl
{ $link retract } " removes the first definition that matches the given head information." $nl
{ $unchecked-example
"{ mouseo Jerry } retract
{ mouseo X } query ."
"{ H{ { X Nibbles } } }"
} $nl
"On the other hand, " { $link retract-all } " removes all definitions that match a given head goal definition. Logic variables, including anonymous logic variables, can be used as goal definition arguments in " { $link retract } " and " { $link retract-all } ". A logic variable match any argument." $nl
{ $unchecked-example
"{ mouseo Jerry } fact
{ mouseo X } query .

{ mouseo __ } retract-all
{ mouseo X } query ."
"{ H{ { X Nibbles } } H{ { X Jerry } } }\nf"
} $nl
"let's have them come back." $nl
{ $unchecked-example
"{ { mouseo Jerry } { mouseo Nibbles } } facts
{ creatureo X } query ."
"{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }"
} $nl
"Logic predicates that take different numbers of arguments are treated separately. The previously used " { $snippet "cato" } " took one argument. Let's define " { $snippet "cato" } " that takes two arguments." $nl
{ $unchecked-example
"SYMBOLS: big small a-big-cat a-small-cat ;

{ cato big a-big-cat } fact
{ cato small a-small-cat } fact

{ cato X } query .
{ cato X Y } query .
{ creatureo X } query ."
"{ H{ { X Tom } } }\n{ H{ { X big } { Y a-big-cat } } H{ { X small } { Y a-small-cat } } }\n{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } }"
} $nl
"If you need to identify a logic predicate that has a different " { $strong "arity" } ", that is numbers of arguments, express it with a slash and an arity number. For example, " { $snippet "cato" } " with arity 1 is " { $snippet "cato/1" } ", " { $snippet "cato" } " with arity 2 is " { $snippet "cato/2" } ". But, note that " { $snippet "logic" } " does not recognize these names." $nl
{ $link clear-pred } " will clear all definitions of any arity. If you only want to remove the definition of a certain arity, you should use " { $link retract-all } " with logic variables." $nl
{ $unchecked-example
"{ cato __ __ } retract-all
{ cato X Y } query ."
"{ cato X } query ."
"f\n{ H{ { X Tom } } }"
} $nl
"You can " { $strong "trace" } " " { $snippet "logic" } "'s execution. The word to do this is " { $link trace } "." $nl
"The word to stop tracing is " { $link notrace } "." $nl
"Here is a Prolog definition for the factorial predicate " { $snippet "factorial" } "." $nl
"factorial(0, 1)." $nl
"factorial(N, F) :- N > 0, N2 is N - 1, factorial(N2, F2), F is F2 * N." $nl
"Let's think about how to do the same thing. It is mostly the following code, but is surrounded by backquotes where it has not been explained." $nl
{ $code
"USE: logic

LOGIC-PRED: factorialo
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    `N > 0`
    `N2 is N - 1`
    { factorialo N2 F2 }
    `F is F2 * N`
} rule"
} $nl
"Within these backquotes are comparisons, calculations, and assignments (to be precise, " { $strong "unifications" } "). " { $snippet "logic" } " has a mechanism to call Factor code to do these things. Here are some example." $nl
{ $code "LOGIC-PREDS: N_>_0  N2_is_N_-_1  F_is_F2_*_N ;" }
{ $code "{ N_>_0 N } [ N of 0 > ] callback" }
{ $code "{ N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] callback" }
{ $code "{ F_is_F2_*_N F F2 N } [ dup [ F2 of ] [ N of ] bi * F unify ] callback" } $nl
"Use " { $link callback } " to set the quotation to be called. Such quotations take an " { $strong "environment" } " which holds the binding of logic variables, and returns " { $link t } " or " { $link f } " as a result of execution. To retrieve the values of logic variables in the environment, use " { $link of } " or " { $link at } "." $nl
"The word " { $link unify } " unifies the two following the environment in that environment." $nl
"Now we can rewrite the definition of factorialo to use them." $nl
{ $code
"USE: logic

LOGIC-PREDS: factorialo N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    { N_>_0 N }
    { N2_is_N_-_1 N2 N }
    { factorialo N2 F2 }
    { F_is_F2_*_N F F2 N }
} rule

{ N_>_0 N } [ N of 0 > ] callback

{ N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] callback

{ F_is_F2_*_N F F2 N } [ dup [ N of ] [ F2 of ] bi * F unify ] callback"
} $nl
"Let's try " { $snippet "factorialo" } "." $nl
{ $unchecked-example
"{ factorialo 0 F } query ."
"{ H{ { F 1 } } }"
}
{ $unchecked-example
"{ factorialo 1 F } query ."
"{ H{ { F 1 } } }"
}
{ $unchecked-example
"{ factorialo 10 F } query ."
"{ H{ { F 3628800 } } }"
} $nl
{ $snippet "logic" } " has features that make it easier to meet the typical requirements shown here." $nl
"There are the built-in logic predicates " { $link (<) } ", " { $link (>) } ", " { $link (>=) } ", and " { $link (=<) } " to compare numbers. There are also " { $link (==) } " and " { $link (\==) } " to test for equality and inequality of two arguments." $nl
"The word " { $link is } " takes a quotation and a logic variable to be unified. The quotation takes an environment and returns a value. And " { $link is } " returns the internal representation of the goal. " { $link is } " is intended to be used in a quotation. If there is a quotation in the definition of " { $link rule } ", " { $snippet "logic" } " uses the internal definition of the goal obtained by calling it." $nl
"If you use these features to rewrite the definition of " { $snippet "factorialo" } ":" $nl
{ $code
"USE: logic

LOGIC-PRED: factorialo
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorialo N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ]
} rule"
} $nl
"Use the built-in logic predicate " { $link (=) } " for unification that does not require processing with a quotation. " { $link (\=) } " will be true when such a unification fails. Note that " { $link (\=) } " does not actually do the unification." $nl
{ $link varo } " takes a argument and is true if it is a logic variable with no value. On the other hand, " { $link nonvaro } " is true if its argument is not a logic variable or is a concrete logic variable." $nl
"Now almost everything about " { $snippet "logic" } " is explained."
;

ABOUT: "logic"
