IN: http.server.sessions.storage.db
USING: http.server.sessions.storage
http.server.sessions.storage.db namespaces io.files
db.sqlite db accessors math tools.test kernel assocs
sequences ;

sessions-in-db "storage" set

"auth-test.db" temp-file sqlite-db [
    [ ] [ init-sessions-table ] unit-test

    [ f ] [ H{ } "storage" get new-session empty? ] unit-test

    H{ } "storage" get new-session "id" set

    "id" get "storage" get get-session "session" set
    "a" "b" "session" get set-at

    "session" get "id" get "storage" get update-session

    [ H{ { "b" "a" } } ] [
        "id" get "storage" get get-session
    ] unit-test
] with-db
