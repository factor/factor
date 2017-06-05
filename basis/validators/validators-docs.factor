USING: help.markup help.syntax kernel math quotations regexp
strings ;
IN: validators

HELP: v-checkbox
{ $values { "str" string } { "?" boolean } }
{ $description "Converts the string value of a checkbox component (either \"on\" or \"off\") to a boolean value." } ;

HELP: v-captcha
{ $values { "str" string } }
{ $description "Throws a validation error if the string is non-empty. This is used to create bait fields for spam-bots to fill in." } ;

HELP: v-credit-card
{ $values { "str" string } { "n" integer } }
{ $description "If the credit card number passes the Luhn algorithm, converts it to an integer, otherwise throws an error." }
{ $notes "See " { $url "http://en.wikipedia.org/wiki/Luhn_algorithm" } " for a description of this algorithm." } ;

HELP: v-default
{ $values { "str" string } { "def" string } { "str/def" string } }
{ $description "If the input string is not specified, replaces it with the default value." } ;

HELP: v-email
{ $values { "str" string } }
{ $description "Throws a validation error if the string is not a valid e-mail address, as determined by a regular expression." } ;

HELP: v-integer
{ $values { "str" string } { "n" integer } }
{ $description "Converts the string into an integer, throwing a validation error if the string is not a valid integer." } ;

HELP: v-min-length
{ $values { "str" string } { "n" integer } }
{ $description "Throws a validation error if the string is shorter than " { $snippet "n" } " characters." } ;

HELP: v-max-length
{ $values { "str" string } { "n" integer } }
{ $description "Throws a validation error if the string is longer than " { $snippet "n" } " characters." } ;

HELP: v-max-value
{ $values { "x" integer } { "n" integer } }
{ $description "Throws an error if " { $snippet "x" } " is larger than " { $snippet "n" } "." } ;

HELP: v-min-value
{ $values { "x" integer } { "n" integer } }
{ $description "Throws an error if " { $snippet "x" } " is smaller than " { $snippet "n" } "." } ;

HELP: v-mode
{ $values { "str" string } }
{ $description "Throws an error if " { $snippet "str" } " is not a valid XMode mode name." } ;

HELP: v-number
{ $values { "str" string } { "n" real } }
{ $description "Converts the string into a real number, throwing a validation error if the string is not a valid real number." } ;

HELP: v-one-line
{ $values { "str" string } }
{ $description "Throws a validation error if the string contains line breaks." } ;

HELP: v-one-word
{ $values { "str" string } }
{ $description "Throws a validation error if the string contains word breaks." } ;

HELP: v-optional
{ $values { "str" string } { "quot" quotation } { "result" string } }
{ $description "If the string is non-empty, applies the quotation to the string, otherwise outputs the empty string." } ;

HELP: v-password
{ $values { "str" string } }
{ $description "A reasonable default validator for passwords." } ;

HELP: v-regexp
{ $values { "str" string } { "what" string } { "regexp" regexp } }
{ $description "Throws a validation error that " { $snippet "what" } " failed if the string does not match the regular expression." } ;

HELP: v-required
{ $values { "str" string } }
{ $description "Throws a validation error if the string is empty." } ;

HELP: v-url
{ $values { "str" string } }
{ $description "Throws an error if the string is not a valid URL, as determined by a regular expression." } ;

HELP: v-username
{ $values { "str" string } }
{ $description "A reasonable default validator for usernames." } ;

ARTICLE: "validators" "Form validators"
"The " { $vocab-link "validators" } " vocabulary provides a set of words which are intended to be used with the form validation functionality offered by " { $vocab-link "furnace.actions" } ". They can also be used independently of the web framework."
$nl
"Note that validators which take numbers must be preceded by " { $link v-integer } " or " { $link v-number } " if the original input is a string."
$nl
"Higher-order validators which require additional parameters:"
{ $subsections
    v-default
    v-optional
    v-min-length
    v-max-length
    v-min-value
    v-max-value
    v-regexp
}
"Simple validators:"
{ $subsections
    v-required
    v-number
    v-integer
    v-one-line
    v-one-word
    v-captcha
    v-checkbox
}
"More complex validators:"
{ $subsections
    v-email
    v-url
    v-username
    v-password
    v-credit-card
    v-mode
} ;

ABOUT: "validators"
