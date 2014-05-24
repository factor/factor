USING: help.markup help.syntax kernel ;
IN: furnace.auth.features.registration

HELP: allow-registration
{ $values { "realm" "an authentication realm" } }
{ $description "Adds a " { $snippet "registration" } " action to an authentication realm." } ;

HELP: allow-registration?
{ $values { "?" boolean } }
{ $description "Outputs true if the current authentication realm allows user registration." } ;

ARTICLE: "furnace.auth.features.registration" "User registration"
"The " { $vocab-link "furnace.auth.features.registration" } " vocabulary implements an authentication feature for user registration, allowing new users to create accounts."
$nl
"To enable this feature, call the following word on an authentication realm:"
{ $subsections allow-registration }
"To check if user registration is enabled:"
{ $subsections allow-registration? }
"This feature adds a " { $snippet "register" } " action to the realm. A link to this action is inserted on the login page if the " { $vocab-link "furnace.auth.login" } " authentication realm is used. Links to this action can be inserted from other pages using the following Chloe XML snippet:"
{ $code
    "<t:if t:code=\"furnace.auth.features.registration:allow-registration?\">"
    "    <t:button t:action=\"$realm/register\">Register</t:button>"
    "</t:if>"
} ;
