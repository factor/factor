USING: arrays hashtables kernel parser quotations sequences splitting ;
IN: arrays.nested-syntax

: ;; ( -- * ) ";; can only be used in [[ ]] , {{ }} , or H{{ }} blocks" throw ;
DEFER: ]] delimiter
DEFER: }} delimiter

: [[ \ ]] [ { POSTPONE: ;; } split [ >quotation ] map ] parse-literal ; parsing
: {{ \ }} [ { POSTPONE: ;; } split [ >array ] map ] parse-literal ; parsing
: H{{ \ }} [ { POSTPONE: ;; } split >hashtable ] parse-literal ; parsing
