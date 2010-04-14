! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db db.sqlite db.tuples db.types kernel ;
IN: mason.server

CONSTANT: +starting+ "starting"
CONSTANT: +make-vm+ "make-vm"
CONSTANT: +boot+ "boot"
CONSTANT: +test+ "test"
CONSTANT: +clean+ "status-clean"
CONSTANT: +dirty+ "status-dirty"
CONSTANT: +error+ "status-error"

TUPLE: builder
host-name os cpu
clean-git-id clean-timestamp
last-release release-git-id
last-git-id last-timestamp last-report
current-git-id current-timestamp
status
heartbeat-timestamp ;

builder "BUILDERS" {
    { "host-name" "HOST_NAME" TEXT +user-assigned-id+ }
    { "os" "OS" TEXT +user-assigned-id+ }
    { "cpu" "CPU" TEXT +user-assigned-id+ }
    
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

    { "heartbeat-timestamp" "HEARTBEAT_TIMESTAMP" TIMESTAMP }
} define-persistent

: mason-db ( -- db ) "resource:mason.db" <sqlite-db> ;

: with-mason-db ( quot -- )
    [ mason-db ] dip with-db ; inline
