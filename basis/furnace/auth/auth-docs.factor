USING: byte-arrays checksums.sha furnace.auth.providers
furnace.auth.providers.db help.markup help.syntax http kernel
math strings words.symbol ;
IN: furnace.auth

HELP: <protected>
{ $values
    { "responder" "a responder" }
    { "protected" "a new responder" }
}
{ $description "Wraps a responder in a protected responder. Access to the wrapped responder will be conditional upon the client authenticating with the current authentication realm." } ;

HELP: >>encoded-password
{ $values { "user" user } { "string" string } }
{ $description "Sets the user's password by combining it with a random salt and encoding it with the current authentication realm's checksum." } ;

HELP: capabilities
{ $var-description "Global variable holding all defined capabilities. New capabilities may be defined with " { $link define-capability } "." } ;

HELP: check-login
{ $values { "password" string } { "username" string } { "user/f" { $maybe user } } }
{ $description "Checks a username/password pair with the current authentication realm. Outputs a user if authentication succeeded, otherwise outputs " { $link f } "." } ;

HELP: define-capability
{ $values { "word" symbol } }
{ $description "Defines a new capability by adding it to the " { $link capabilities } " global variable." } ;

HELP: encode-password
{ $values
    { "string" string } { "salt" integer }
    { "bytes" byte-array }
}
{ $description "Encodes a password with the current authentication realm's checksum." } ;

HELP: have-capabilities?
{ $values
    { "capabilities" "a sequence of capabilities" }
    { "?" boolean }
}
{ $description "Tests if the currently logged-in user possesses the given capabilities." } ;

HELP: logged-in-user
{ $var-description "Holds the currently logged-in user." } ;

HELP: login-required
{ $values
    { "description" string } { "capabilities" "a sequence of capabilities" }
}
{ $description "Redirects the client to a login page." } ;

HELP: login-required*
{ $values
    { "description" string } { "capabilities" "a sequence of capabilities" } { "realm" "an authenticaiton realm" }
    { "response" response }
}
{ $contract "Constructs an HTTP response for redirecting the client to a login page." } ;

HELP: protected
{ $class-description "The class of protected responders. See " { $link "furnace.auth.protected" } " for a description of usage and slots." } ;

HELP: realm
{ $class-description "The class of authentication realms. See " { $link "furnace.auth.realms" } " for details." } ;

HELP: uchange
{ $values { "quot" { $quotation ( old -- new ) } } { "key" symbol } }
{ $description "Applies the quotation to the old value of the user profile variable, and assigns the resulting value back to the variable." } ;

HELP: uget
{ $values { "key" symbol } { "value" object } }
{ $description "Outputs the value of a user profile variable." } ;

HELP: uset
{ $values { "value" object } { "key" symbol } }
{ $description "Sets the value of a user profile variable." } ;

HELP: username
{ $values { "string/f" { $maybe string } }
}
{ $description "Outputs the currently logged-in username, or " { $link f } " if no user is logged in." } ;
HELP: users
{ $values { "provider" "an authentication provider" } }
{ $description "Outputs the current authentication provider." } ;

ARTICLE: "furnace.auth.capabilities" "Authentication capabilities"
"Every user in the authentication framework has a set of associated capabilities."
$nl
"Defining new capabilities:"
{ $subsections define-capability }
"Capabilities are stored in a global variable:"
{ $subsections capabilities }
"Protected resources can be restricted to users possessing certain capabilities only by storing a sequence of capabilities in the " { $slot "capabilities" } " slot of a " { $link protected } " instance." ;

ARTICLE: "furnace.auth.protected" "Protected resources"
"To restrict access to authenticated clients only, wrap a responder in a protected responder."
{ $subsections
    protected
    <protected>
}
"Protected responders have the following two slots which may be set:"
{ $slots
    { "description" "A string identifying the protected resource for user interface purposes" }
    { "capabilities" { "A sequence of capabilities; see " { $link "furnace.auth.capabilities" } } }
} ;

ARTICLE: "furnace.auth.realm-config" "Authentication realm configuration"
"Instances of subclasses of " { $link realm } " have the following slots which may be set:"
{ $slots
    { "name" "A string identifying the realm for user interface purposes" }
    { "users" { "An authentication provider (see " { $link "furnace.auth.providers" } "). By default, the " { $link users-in-db } " provider is used." } }
    { "checksum" { "An implementation of the checksum protocol used for verifying passwords (see " { $link "checksums" } "). The " { $link sha-256 } " checksum is used by default." } }
    { "secure" { "A boolean, that when set to a true value, forces the client to access the authentication realm via HTTPS. An attempt to access the realm via HTTP results in a redirect to the corresponding HTTPS URL. On by default." } }
} ;

ARTICLE: "furnace.auth.providers" "Authentication providers"
"The " { $vocab-link "furnace.auth" } " framework looks up users using an authentication provider. Different authentication providers can be swapped in to implement various authentication strategies."
$nl
"Each authentication realm has a provider stored in the " { $slot "users" } " slot. The default provider is " { $link users-in-db } "."
{ $subsections
    "furnace.auth.providers.protocol"
    "furnace.auth.providers.null"
    "furnace.auth.providers.assoc"
    "furnace.auth.providers.db"
} ;

ARTICLE: "furnace.auth.features" "Optional authentication features"
"Vocabularies having names prefixed by " { $code "furnace.auth.features" } " implement optional features which can be enabled by calling special words. These words define new actions on an authentication realm."
{ $subsections
    "furnace.auth.features.deactivate-user"
    "furnace.auth.features.edit-profile"
    "furnace.auth.features.recover-password"
    "furnace.auth.features.registration"
} ;

ARTICLE: "furnace.auth.realms" "Authentication realms"
"The superclass of authentication realms:"
{ $subsections realm }
"There are two concrete implementations:"
{ $subsections
    "furnace.auth.basic"
    "furnace.auth.login"
}
"Authentication realms need to be configured after construction."
{ $subsections "furnace.auth.realm-config" } ;

ARTICLE: "furnace.auth.users" "User profiles"
"A responder wrapped in an authentication realm may access the currently logged-in user,"
{ $subsections logged-in-user }
"as well as the logged-in username:"
{ $subsections username }
"Values can also be stored in user profile variables:"
{ $subsections
    uget
    uset
    uchange
}
"User profile variables have the same restrictions on their values as session variables; see " { $link "furnace.sessions.serialize" } " for a discussion." ;

ARTICLE: "furnace.auth.example" "Furnace authentication example"
"The " { $vocab-link "webapps.todo" } " vocabulary wraps all of its responders in a protected responder. The " { $slot "description" } " slot is set so that the login page contains the message \"You must log in to view your todo list\":"
{ $code
    "<protected>
    \"view your todo list\" >>description"
}
"The " { $vocab-link "webapps.wiki" } " vocabulary defines a mix of protected and unprotected actions. One example of a protected action is that for deleting wiki pages, an action normally reserved for administrators. This action is protected with the following code:"
{ $code
    "<protected>
    \"delete wiki articles\" >>description
    { can-delete-wiki-articles? } >>capabilities"
}
"The " { $vocab-link "websites.concatenative" } " vocabulary wraps all of its responders, including the wiki, in a login authentication realm:"
{ $code
": <login-config> ( responder -- responder' )
    \"Factor website\" <login-realm>
        allow-registration
        allow-password-recovery
        allow-edit-profile
        allow-deactivation ;"
} ;

ARTICLE: "furnace.auth" "Furnace authentication"
"The " { $vocab-link "furnace.auth" } " vocabulary implements a pluggable authentication framework."
$nl
"Usernames and passwords are verified using an " { $emphasis "authentication provider" } "."
{ $subsections "furnace.auth.providers" }
"Users have capabilities assigned to them."
{ $subsections "furnace.auth.capabilities" }
"An " { $emphasis "authentication realm" } " is a responder which manages access to protected resources."
{ $subsections "furnace.auth.realms" }
"Actions contained inside an authentication realm can be protected by wrapping them with a responder."
{ $subsections "furnace.auth.protected" }
"Actions contained inside an authentication realm can access the currently logged-in user profile."
{ $subsections "furnace.auth.users" }
"Authentication realms can be adorned with additional functionality."
{ $subsections "furnace.auth.features" }
"A concrete example."
{ $subsections "furnace.auth.example" } ;

ABOUT: "furnace.auth"
