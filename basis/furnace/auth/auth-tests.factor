USING: accessors concurrency.messaging destructors furnace.auth
furnace.auth.login furnace.auth.providers furnace.auth.providers.assoc
kernel logging namespaces sequences threads tools.test ;
IN: furnace.auth.tests

! Deactivation must reject password login and pre-existing login permits,
! including responders that inspect logged-in? without <protected>.
{ t f f f } [
    [
        f "Test realm" <login-realm> <users-in-memory> >>users realm set
        "alice" <user> "password" >>encoded-password users new-user drop
        "password" "alice" check-login >boolean
        "password" "unknown-user" check-login
        "alice" users get-user 1 >>deleted users update-user
        "password" "alice" check-login
        logged-in-user off
        [ "alice" users get-user init-user logged-in? ] with-destructors
    ] with-scope
] unit-test

! Authentication diagnostics must not serialize the user tuple (which
! contains password hashes, password-reset tickets, and profile data).
{ { "called" } } [
    self "log-server" [
        "furnace-auth-test" [
            [
                "alice" <user>
                    B{ 1 2 3 } >>password
                    "private-reset-ticket" >>ticket
                init-user
            ] with-destructors
        ] with-logging
        receive second
    ] with-variable
] unit-test
