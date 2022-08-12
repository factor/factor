! Copyright (C) 2007 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: assocs delegate deques io sequences sequences.private
sets ui.theme ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
like new-sequence new-resizable nth nth-unsafe
set-nth set-nth-unsafe length set-length
lengthen ;

PROTOCOL: assoc-protocol
at* assoc-size >alist set-at assoc-clone-like
delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: deque-protocol
push-front* push-back* peek-front* peek-back* pop-front*
pop-back* delete-node deque-member?  clear-deque deque-empty? ;

PROTOCOL: set-protocol
adjoin ?adjoin in? delete ?delete set-like fast-set members
union intersect intersects? diff subset? set= duplicates
all-unique? null? cardinality clear-set ;

PROTOCOL: input-stream-protocol
stream-read1 stream-read-unsafe stream-read-partial-unsafe
stream-readln stream-read-until stream-contents* ;

PROTOCOL: output-stream-protocol
stream-flush stream-write1 stream-write stream-nl ;

PROTOCOL: theme-protocol
toolbar-background toolbar-button-pressed-background
menu-background menu-border-color status-bar-background
status-bar-foreground button-text-color
button-clicked-text-color line-color column-title-background
roll-button-rollover-border roll-button-selected-background
source-files-color errors-color details-color debugger-color
completion-color data-stack-color retain-stack-color
call-stack-color title-bar-gradient popup-color object-color
contents-color help-header-background
thread-status-stopped-background
thread-status-suspended-background
thread-status-running-background
thread-status-stopped-foreground
thread-status-suspended-foreground
thread-status-running-foreground error-summary-background
content-background text-color link-color title-color
heading-color snippet-color output-color
deprecated-background-color deprecated-border-color
warning-background-color warning-border-color
code-background-color code-border-color help-path-border-color
tip-background-color prompt-background-color dim-color
highlighted-word-color string-color stack-effect-color
vocab-background-color vocab-border-color field-border-color
editor-caret-color selection-color panel-background-color
focus-border-color labeled-border-color table-border-color ;
