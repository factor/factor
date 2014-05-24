USING: help.markup help.syntax kernel ;
IN: furnace.auth.features.deactivate-user

HELP: allow-deactivation
{ $values { "realm" "an authentication realm" } }
{ $description "Adds a " { $snippet "deactivate-user" } " action to an authentication realm." } ;

HELP: allow-deactivation?
{ $values { "?" boolean } }
{ $description "Outputs true if the current authentication realm allows user profile deactivation." } ;

ARTICLE: "furnace.auth.features.deactivate-user" "User profile deactivation"
"The " { $vocab-link "furnace.auth.features.deactivate-user" } " vocabulary implements an authentication feature for user profile deactivation, allowing users to voluntarily deactivate their account."
$nl
"To enable this feature, call the following word on an authentication realm:"
{ $subsections allow-deactivation }
"To check if deactivation is enabled:"
{ $subsections allow-deactivation? }
"This feature adds a " { $snippet "deactivate-user" } " action to the realm, and a link to this action can be inserted in Chloe templates using the following XML snippet:"
{ $code
    "<t:if t:code=\"furnace.auth.features.deactivate-user:allow-deactivation?\">"
    "    <t:button t:action=\"$realm/deactivate-user\">Deactivate user</t:button>"
    "</t:if>"
} ;

ABOUT: "furnace.auth.features.deactivate-user"
