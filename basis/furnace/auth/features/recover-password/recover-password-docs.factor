USING: help.markup help.syntax kernel ;
IN: furnace.auth.features.recover-password

HELP: allow-password-recovery
{ $values { "realm" "an authentication realm" } }
{ $description "Adds a " { $snippet "recover-password" } " action to an authentication realm." } ;

HELP: allow-password-recovery?
{ $values { "?" boolean } }
{ $description "Outputs true if the current authentication realm allows user password recovery." } ;

HELP: lost-password-from
{ $var-description "A variable with the source e-mail address of password recovery e-mails." } ;

ARTICLE: "furnace.auth.features.recover-password" "User password recovery"
"The " { $vocab-link "furnace.auth.features.recover-password" }
" vocabulary implements an authentication feature for user password recovery, allowing users to get a new password e-mailed to them in the event they forget their current one."
$nl
"To enable this feature, first call the following word on an authentication realm,"
{ $subsections allow-password-recovery }
"Then set a global configuration variable:"
{ $subsections lost-password-from }
"In addition, the " { $link "smtp" } " may need to be configured as well."
$nl
"To check if password recovery is enabled:"
{ $subsections allow-password-recovery? }
"This feature adds a " { $snippet "recover-password" } " action to the realm, and a link to this action can be inserted in Chloe templates using the following XML snippet:"
{ $code
    "<t:if t:code=\"furnace.auth.features.recover-password:allow-password-recovery?\">"
    "    <t:button t:action=\"$realm/recover-password\">Recover password</t:button>"
    "</t:if>"
} ;

ABOUT: "furnace.auth.features.recover-password"
