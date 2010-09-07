! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators db.tuples furnace.actions
furnace.redirection html.forms http.server.responses io kernel
mason.server namespaces validators webapps.mason.utils ;
IN: webapps.mason.status-update

: find-builder ( -- builder )
    builder new
        "host-name" value >>host-name
        "target-os" value >>os
        "target-cpu" value >>cpu
    dup select-tuple [ ] [ dup insert-tuple ] ?if ;

: git-id ( builder id -- ) >>current-git-id +starting+ >>status drop ;

: make-vm ( builder -- ) +make-vm+ >>status drop ;

: boot ( builder -- ) +boot+ >>status drop ;

: test ( builder -- ) +test+ >>status drop ;

: report ( builder status content -- )
    [ >>status ] [ >>last-report ] bi*
    dup status>> +clean+ = [
        dup current-git-id>> >>clean-git-id
        dup current-timestamp>> >>clean-timestamp
    ] when
    dup current-git-id>> >>last-git-id
    dup current-timestamp>> >>last-timestamp
    drop ;

: release ( builder name -- )
    >>last-release
    dup clean-git-id>> >>release-git-id
    drop ;

: update-builder ( builder -- )
    "message" value {
        { "heartbeat" [ drop ] }
        { "git-id" [ "arg" value git-id ] }
        { "make-vm" [ make-vm ] }
        { "boot" [ boot ] }
        { "test" [ test ] }
        { "report" [ "arg" value "report" value report ] }
        { "release" [ "arg" value release ] }
    } case ;

: <status-update-action> ( -- action )
    <action>
    [
        {
            { "host-name" [ v-one-line ] }
            { "target-cpu" [ v-one-line ] }
            { "target-os" [ v-one-line ] }
            { "message" [ v-one-line ] }
            { "arg" [ [ v-one-line ] v-optional ] }
            { "report" [ ] }
        } validate-params

        validate-secret
    ] >>validate

    [
        [
            find-builder
            now >>current-timestamp
            [ update-builder ] [ update-tuple ] bi
        ] with-mason-db
        "OK" "text/plain" <content>
    ] >>submit ;
