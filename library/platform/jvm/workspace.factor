!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

!!! A "store" is a flat-file database that identifies byte
!!! arrays with 8-byte keys. Several implementations are
!!! available. There are several low-level words for creating
!!! and working with your own stores, but usually these words
!!! are only used for testing.
!!!
!!! A "workspace" sits on top of a store and implements
!!! picking/unpickling of persistent objects in the store.
!!!
!!! Each persistent object has an 8-byte ID; this is the same
!!! ID used to save/load the object in the store.
!!!
!!! Additinally, each persistent object knows how to
!!! pickle/unpickle itself.

IN: workspace
USE: combinators
USE: namespaces
USE: stack
USE: streams

: workspace ( -- workspace )
    #! Push the current workspace.
    interpreter [ "workspace" get ] bind ;

: <btree-store> ( filename order readonly -- store )
    #! Create a B-tree store. The B-tree store puts all records
    #! inside a single file, using an auxiliary file holding a
    #! B-tree to implement fast searches.
    [ <file> ] 2dip
    [ "java.io.File" "byte" "boolean" ]
    "factor.db.BTreeStore" jnew ;

: <file-store> ( filename -- store )
    #! Create a file store. The file store puts all records
    #! inside individual files in a directory.
    [ "java.lang.String" ] "factor.db.FileStore" jnew ;

: store-get ( id store -- )
    #! Retreive a value from the store.
    [ "long" ] "factor.db.Store" "loadFromStore"
    jinvoke ;

: store-set ( id value store -- )
    #! Put a value in the store.
    [ "long" [ "byte" ] ] "factor.db.Store" "saveToStore"
    jinvoke ;

: in-store? ( id store -- ? )
    #! Check if a value is in the store.
    [ "long" ] "factor.db.Store" "exists" jinvoke ;

: close-store ( store -- )
    #! Close a store, completing all pending transactions.
    [ ] "factor.db.Store" "close" jinvoke ;

: save-workspace ( -- )
    #! Complete all pending transactions in the workspace.
    workspace [ ] "factor.db.Workspace" "flush" jinvoke ;

IN: namespaces

: <table> ( -- table )
    #! A table is a persistent namespace.
    workspace
    [ "factor.db.Workspace" ] "factor.db.Table" jnew ;

: alist>table ( alist -- table )
    <table> tuck alist> ;
