USING: help.markup help.syntax kernel ;
IN: furnace.auth.features.edit-profile

HELP: allow-edit-profile
{ $values { "realm" "an authentication realm" } }
{ $description "Adds an " { $snippet "edit-profile" } " action to an authentication realm." } ;

HELP: allow-edit-profile?
{ $values { "?" boolean } }
{ $description "Outputs true if the current authentication realm allows user profile editing." } ;

ARTICLE: "furnace.auth.features.edit-profile" "User profile editing"
"The " { $vocab-link "furnace.auth.features.edit-profile" } " vocabulary implements an authentication feature for user profile editing, allowing users to change some details of their account."
$nl
"To enable this feature, call the following word on an authentication realm:"
{ $subsections allow-edit-profile }
"To check if profile editing is enabled:"
{ $subsections allow-edit-profile? }
"This feature adds an " { $snippet "edit-profile" } " action to the realm, and a link to this action can be inserted in Chloe templates using the following XML snippet:"
{ $code
    "<t:if t:code=\"furnace.auth.features.edit-profile:allow-edit-profile?\">"
    "    <t:button t:action=\"$realm/edit-profile\">Edit profile</t:button>"
    "</t:if>"
} ;
