USING: accessors furnace.auth.providers furnace.auth.providers.assoc
kernel locals tools.test ;
IN: furnace.auth.providers.tests

! add-user must keep the provider on success and reject duplicates.
{ t t } [
    <users-in-memory> dup
    "alice" <user> add-user
    [ = ] [ nip "alice" swap get-user username>> "alice" = ] 2bi
] unit-test

[
    <users-in-memory> dup "alice" <user> swap new-user drop
    "alice" <user> add-user
] [ "User exists" = ] must-fail-with

! No outstanding recovery ticket is never a valid recovery credential.
{ f f } [ [let
    <users-in-memory> :> provider
    "alice" <user> provider new-user drop
    f "alice" provider claim-ticket
    "alice" provider get-user "" >>ticket drop
    "" "alice" provider claim-ticket
] ] unit-test

! A real ticket can be claimed once, and a wrong ticket cannot clear it.
{ f "alice" f f } [ [let
    <users-in-memory> :> provider
    "alice" <user> "test-ticket" >>ticket provider new-user drop
    "wrong" "alice" provider claim-ticket
    "test-ticket" "alice" provider claim-ticket username>>
    "alice" provider get-user ticket>>
    "test-ticket" "alice" provider claim-ticket
] ] unit-test
