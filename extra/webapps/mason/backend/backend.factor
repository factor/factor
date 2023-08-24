! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar db db.sqlite db.tuples db.types kernel
math math.order sequences combinators.short-circuit
io.pathnames ;
IN: webapps.mason.backend

CONSTANT: +idle+ "idle"
CONSTANT: +starting+ "starting"
CONSTANT: +make-vm+ "make-vm"
CONSTANT: +boot+ "boot"
CONSTANT: +test+ "test"
CONSTANT: +upload+ "upload"
CONSTANT: +finish+ "finish"

CONSTANT: +dirty+ "status-dirty"
CONSTANT: +error+ "status-error"
CONSTANT: +clean+ "status-clean"

TUPLE: builder
host-name os cpu heartbeat-timestamp
clean-git-id clean-timestamp
last-release release-git-id
last-git-id last-timestamp last-report
current-git-id current-timestamp
status ;

builder "BUILDERS" {
    { "host-name" "HOST_NAME" TEXT +user-assigned-id+ }
    { "os" "OS" TEXT +user-assigned-id+ }
    { "cpu" "CPU" TEXT +user-assigned-id+ }
    { "heartbeat-timestamp" "HEARTBEAT_TIMESTAMP" TIMESTAMP }

    { "clean-git-id" "CLEAN_GIT_ID" TEXT }
    { "clean-timestamp" "CLEAN_TIMESTAMP" TIMESTAMP }

    { "last-release" "LAST_RELEASE" TEXT }
    { "release-git-id" "RELEASE_GIT_ID" TEXT }

    { "last-git-id" "LAST_GIT_ID" TEXT }
    { "last-timestamp" "LAST_TIMESTAMP" TIMESTAMP }
    { "last-report" "LAST_REPORT" TEXT }

    { "current-git-id" "CURRENT_GIT_ID" TEXT }
    ! Can't name it CURRENT_TIMESTAMP because of bug in db library
    { "current-timestamp" "CURR_TIMESTAMP" TIMESTAMP }
    { "status" "STATUS" TEXT }
} define-persistent

TUPLE: counter id value ;

counter "COUNTER" {
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "value" "VALUE" INTEGER }
} define-persistent

: counter-tuple ( -- counter )
    counter new select-tuple
    [ counter new dup insert-tuple ] unless* ;

: counter-value ( -- n )
    counter-tuple value>> 0 or ;

: increment-counter-value ( -- n )
    counter-tuple [ 0 or 1 + dup ] change-value update-tuple ;

: all-builders ( -- builders )
    builder new select-tuples ; inline

: offline? ( builder -- ? )
    heartbeat-timestamp>> 30 minutes ago before? ;

: broken? ( builder -- ? )
    [ clean-git-id>> ] [ last-git-id>> ] bi = not ;

: funny-builders ( -- offline broken )
    all-builders
    [ [ offline? ] filter ]
    [ [ broken? ] filter ]
    bi ;

: os/cpu ( builder -- string )
    [ os>> ] [ cpu>> ] bi "/" glue ;

: mason-db ( -- db ) "~/mason.db" <sqlite-db> ;

: with-mason-db ( quot -- )
    mason-db [ with-transaction ] with-db ; inline

: init-mason-db ( -- )
    { builder counter } ensure-tables ;
