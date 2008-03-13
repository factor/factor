" Vim syntax file
" Language:	factor
" Maintainer:	Alex Chapman <chapman.alex@gmail.com>
" Last Change:	2007 Jan 18

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" factor is case sensitive.
syn case match

" make all of these characters part of a word (useful for skipping over words with w, e, and b)
if version >= 600
    setlocal iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
else
    set iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
endif

syn cluster factorCluster contains=factorComment,factorKeyword,factorRepeat,factorConditional,factorBoolean,factorCompileDirective,factorString,factorSbuf,@factorNumber,@factorNumErr,factorDelimiter,factorChar,factorCharErr,factorBackslash,@factorWordOps,factorAlien,factorTuple

syn match factorTodo /\(TODO\|FIXME\|XXX\):\=/ contained
syn match factorComment /\<#! .*/ contains=factorTodo
syn match factorComment /\<! .*/ contains=factorTodo

syn cluster factorDefnContents contains=@factorCluster,factorStackEffect,factorArray0,factorQuotation0

syn region factorDefn matchgroup=factorDefnDelims start=/\<\(MACRO\|MEMO\|:\)\?:\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorMethod matchgroup=factorMethodDelims start=/\<M:\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorGeneric matchgroup=factorGenericDelims start=/\<GENERIC:\s\+\S\+\>/ end=/$/ contains=factorStackEffect
syn region factorGenericN matchgroup=factorGenericNDelims start=/\<GENERIC#\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect

syn region factorPrivateDefn matchgroup=factorPrivateDefnDelims start=/\<\(MACRO\|MEMO\|:\)\?:\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPrivateMethod matchgroup=factorPrivateMethodDelims start=/\<M:\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPGeneric matchgroup=factorPGenericDelims start=/\<GENERIC:\s\+\S\+\>/ end=/$/ contains=factorStackEffect contained
syn region factorPGenericN matchgroup=factorPGenericNDelims start=/\<GENERIC#\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect

syn region None matchgroup=factorPrivate start=/\<<PRIVATE\>/ end=/\<PRIVATE>\>/ contains=@factorDefnContents,factorPrivateDefn,factorPrivateMethod,factorPGeneric,factorPGenericN


syn keyword factorBoolean boolean f general-t t
syn keyword factorCompileDirective inline foldable parsing



" kernel vocab keywords
syn keyword factorKeyword or construct-delegate set-slots tuck while wrapper nip hashcode wrapper? both? callstack>array die dupd set-delegate callstack callstack? 3dup pick curry build >boolean ?if clone eq? = ? swapd call-clear 2over 2keep 3keep construct general-t clear 2dup when not tuple? 3compose dup call object wrapped unless* if* 2apply >r curry-quot drop when* retainstack -rot delegate with 3slip construct-boa slip compose-first compose-second 3drop construct-empty either? curry? datastack compare curry-obj over 3curry roll throw swap and 2nip set-retainstack (clone) hashcode* get-slots compose spin if <=> unless compose? tuple keep 2curry object? equal? set-datastack 2slip 2drop most <wrapper> null r> set-callstack dip xor rot -roll 
syn keyword factorKeyword assoc? assoc-clone-like delete-any assoc= delete-at* new-assoc subassoc? assoc-size map>assoc union search-alist assoc-like key? update at* assoc-empty? at+ set-at assoc-all? assoc-hashcode intersect change-at assoc-each assoc-subset values rename-at value-at (assoc-stack) at cache assoc>map assoc-contains? assoc assoc-map assoc-pusher diff (assoc>map) assoc-push-if remove-all >alist (substitute) substitute-here clear-assoc assoc-stack substitute delete-at assoc-find keys 
syn keyword factorKeyword case dispatch-case-quot with-datastack alist>quot dispatch-case hash-case-table <buckets> hash-case-quot no-cond no-case? cond distribute-buckets (distribute-buckets) contiguous-range? cond>quot no-cond? no-case recursive-hashcode linear-case-quot hash-dispatch-quot case>quot 
syn keyword factorKeyword byte-array>bignum sgn >bignum number= each-integer next-power-of-2 before? imaginary-part mod recip float>bits rational >float number? 2^ bignum? integer fixnum? after? fixnum before=? bignum sq neg denominator [-] (all-integers?) times find-last-integer (each-integer) bit? * + - / >= bitand find-integer complex < real > log2 integer? max number bits>double double>bits bitor 2/ zero? rem all-integers? (find-integer) real-part align bits>float float? shift between? float 1+ 1- min fp-nan? ratio? bitxor even? ratio <= /mod >integer odd? rational? bitnot real? >fixnum complex? (next-power-of-2) /i numerator after=? /f 
syn keyword factorKeyword slice-to append left-trim clone-like 3sequence set-column-seq map-as reversed pad-left cut* nth sequence slice? <slice> tail-slice empty? tail* member? unclip virtual-sequence? set-length last-index* <column> drop-prefix bounds-error? set-slice-seq set-column-col seq-diff map start open-slice midpoint@ add* set-immutable-seq move-forward fourth delete set-slice-to all-eq? monotonic? set-reversed-seq like delete-nth first4 repetition-len (open-slice) column? reverse slice padding virtual@ repetition? index 4sequence max-length set-second first2 first3 (3append) supremum unclip-slice index* move-backward tail 3append sequence-hashcode-step right-trim reversed-seq pad-right concat find* set-slice-from flip sum find-last* immutable? 2sequence delete-all start* immutable-sequence? (append) check-slice column-seq sequence? head set-slice-error-reason reduce set-bounds-error-index reverse-here sequence= halves collapse-slice interleave 2map binary-reduce virtual-seq slice-error? product bounds-check? bounds-check immutable find column remove ((append)) set-fourth peek contains? reversed? shorter? push-new find-last head-slice pop* immutable-seq tail-slice* accumulate each pusher all-equal? new-resizable cut-slice head-slice* 2reverse-each pop memq? set-nth ?nth <flat-slice> second change-each join set-repetition-len <reversed> all? virtual-sequence set-repetition-elt subseq? immutable-sequence slice-error-reason new-like length last-index seq-intersect push-if 2all? lengthen column-col joined-length copy set-bounds-error-seq cache-nth move third first slice-from repetition-elt tail? set-first bounds-error add bounds-error-seq bounds-error-index <repetition> unfold exchange slice-seq cut 2reduce change-nth min-length set-third (delete) push-all head? delete-slice sum-lengths new 2each head* infimum subset slice-error subseq replace-slice repetition push trim sequence-hashcode mismatch 
syn keyword factorKeyword global +@ set-namestack with-variable on set bind dec namestack get get-global change init-namespaces with-scope off set-global namespace % make , inc counter building make-assoc 
syn keyword factorKeyword <array> 3array >array 4array pair? array pair 2array 1array resize-array array? 
syn keyword factorKeyword readln stream-read-until stream-read-partial stderr with-stream read with-stream* print contents make-span-stream write1 stream-write1 stream-format make-block-stream stream-copy with-cell stream-write format with-row stream-print stream-read with-nesting (stream-copy) bl write-object nl stream-nl write stdio flush read-until tabular-output make-cell-stream write-cell stream-flush read1 lines stream-read1 stream-write-table with-style stream-readln 
syn keyword factorKeyword resize-string >string <string> 1string string string? 
syn keyword factorKeyword vector? <vector> ?push vector >vector 1vector 
syn keyword factorKeyword rethrow-restarts restarts recover set-restart-name set-continuation-name condition-continuation <restart> ifcc continuation-name set-restart-continuation ignore-errors continuation-retain continue <continuation> restart-continuation with-disposal set-continuation-catch restart-obj error thread-error-hook set-continuation-retain continuation rethrow callcc1 callcc0 condition continuation? continuation-call continuation-data set-condition-restarts set-catchstack >continuation< error-continuation cleanup restart? compute-restarts condition? error-thread set-continuation-call set-condition-continuation <condition> set-restart-obj dispose set-continuation-data throw-restarts catchstack continue-with attempt-all restart restart-name continuation-catch condition-restarts 


syn cluster factorReal   contains=factorInt,factorFloat,factorRatio,factorBinary,factorHex,factorOctal
syn cluster factorNumber contains=@factorReal,factorComplex
syn cluster factorNumErr contains=factorBinErr,factorHexErr,factorOctErr
syn match   factorInt 		/\<-\=\d\+\>/
syn match   factorFloat		/\<-\=\d*\.\d\+\>/
syn match   factorRatio		/\<-\=\d*\.*\d\+\/-\=\d*\.*\d\+\>/
syn region  factorComplex	start=/\<C{\>/ end=/\<}\>/ contains=@factorReal
syn match   factorBinErr        /\<BIN:\s\+[01]*[^\s01]\S*\>/
syn match   factorBinary        /\<BIN:\s\+[01]\+\>/
syn match   factorHexErr        /\<HEX:\s\+\x*[^\x\s]\S*\>/
syn match   factorHex           /\<HEX:\s\+\x\+\>/
syn match   factorOctErr        /\<OCT:\s\+\o*[^\o\s]\S*\>/
syn match   factorOctal         /\<OCT:\s\+\o\+\>/

syn match factorIn /\<IN:\s\+\S\+\>/
syn match factorUse /\<USE:\s\+\S\+\>/

syn match factorCharErr /\<CHAR:\s\+\S\+/
syn match factorChar /\<CHAR:\s\+\\\=\S\>/

syn match factorBackslash /\<\\\>\s\+\S\+\>/

syn region factorUsing start=/\<USING:\>/ end=/;/
syn region factorRequires start=/\<REQUIRES:\>/ end=/;/

syn cluster factorWordOps contains=factorSymbol,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain,factorConstructor
syn match factorSymbol /\<SYMBOL:\s\+\S\+\>/
syn match factorPostpone /\<POSTPONE:\s\+\S\+\>/
syn match factorDefer /\<DEFER:\s\+\S\+\>/
syn match factorForget /\<FORGET:\s\+\S\+\>/
syn match factorMixin /\<MIXIN:\s\+\S\+\>/
syn match factorInstance /\<INSTANCE:\s\+\S\+\s\+\S\+\>/
syn match factorHook /\<HOOK:\s\+\S\+\s\+\S\+\>/
syn match factorMain /\<MAIN:\s\+\S\+\>/
syn match factorConstructor /\<C:\s\+\S\+\s\+\S\+\>/

syn match factorAlien /\<ALIEN:\s\+\d\+\>/

syn region factorTuple start=/\<TUPLE:\>/ end=/\<;\>/

"TODO:
"misc:
" HELP:
" ARTICLE:
"literals:
" PRIMITIVE:

"C interface:
" FIELD:
" BEGIN-STRUCT:
" C-ENUM:
" FUNCTION:
" END-STRUCT
" DLL"
" TYPEDEF:
" LIBRARY:
" C-UNION:

syn region factorString start=/"/ skip=/\\"/ end=/"/ oneline
syn region factorSbuf start=/SBUF" / skip=/\\"/ end=/"/ oneline

syn region factorMultiString matchgroup=factorMultiStringDelims start=/\<STRING:\s\+\S\+\>/ end=/^;$/ contains=factorMultiStringContents
syn match factorMultiStringContents /.*/ contained

"syn match factorStackEffectErr /\<)\>/
"syn region factorStackEffectErr start=/\<(\>/ end=/\<)\>/
syn region factorStackEffect start=/\<(\>/ end=/\<)\>/ contained

"adapted from lisp.vim
if exists("g:factor_norainbow") 
    syn region factorQuotation matchgroup=factorDelimiter start=/\<\[\>/ matchgroup=factorDelimiter end=/\<\]\>/ contains=ALL
else
    syn region factorQuotation0           matchgroup=hlLevel0 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation1,factorArray1
    syn region factorQuotation1 contained matchgroup=hlLevel1 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation2,factorArray2
    syn region factorQuotation2 contained matchgroup=hlLevel2 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation3,factorArray3
    syn region factorQuotation3 contained matchgroup=hlLevel3 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation4,factorArray4
    syn region factorQuotation4 contained matchgroup=hlLevel4 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation5,factorArray5
    syn region factorQuotation5 contained matchgroup=hlLevel5 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation6,factorArray6
    syn region factorQuotation6 contained matchgroup=hlLevel6 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation7,factorArray7
    syn region factorQuotation7 contained matchgroup=hlLevel7 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation8,factorArray8
    syn region factorQuotation8 contained matchgroup=hlLevel8 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation9,factorArray9
    syn region factorQuotation9 contained matchgroup=hlLevel9 start=/\<\[\>/ end=/\<\]\>/ contains=@factorCluster,factorQuotation0,factorArray0
endif

if exists("g:factor_norainbow") 
    syn region factorArray    matchgroup=factorDelimiter start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/  matchgroup=factorDelimiter end=/\<}\>/ contains=ALL
else
    syn region factorArray0           matchgroup=hlLevel0 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray1,factorQuotation1
    syn region factorArray1 contained matchgroup=hlLevel1 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray2,factorQuotation2
    syn region factorArray2 contained matchgroup=hlLevel2 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray3,factorQuotation3
    syn region factorArray3 contained matchgroup=hlLevel3 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray4,factorQuotation4
    syn region factorArray4 contained matchgroup=hlLevel4 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray5,factorQuotation5
    syn region factorArray5 contained matchgroup=hlLevel5 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray6,factorQuotation6
    syn region factorArray6 contained matchgroup=hlLevel6 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray7,factorQuotation7
    syn region factorArray7 contained matchgroup=hlLevel7 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray8,factorQuotation8
    syn region factorArray8 contained matchgroup=hlLevel8 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray9,factorQuotation9
    syn region factorArray9 contained matchgroup=hlLevel9 start=/\<\(V\|H\|T\|W\|F\|B\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray0,factorQuotation0
endif

syn match factorBracketErr /\<\]\>/
syn match factorBracketErr /\<}\>/

syn sync lines=100

if version >= 508 || !exists("did_factor_syn_inits")
    if version <= 508
	let did_factor_syn_inits = 1
	command -nargs=+ HiLink hi link <args>
    else
	command -nargs=+ HiLink hi def link <args>
    endif

    HiLink factorComment	Comment
    HiLink factorStackEffect	Typedef
    HiLink factorTodo		Todo
    HiLink factorInclude	Include
    HiLink factorRepeat		Repeat
    HiLink factorConditional	Conditional
    HiLink factorKeyword	Keyword
    HiLink factorOperator	Operator
    HiLink factorBoolean	Boolean
    HiLink factorDefnDelims	Typedef
    HiLink factorMethodDelims	Typedef
    HiLink factorGenericDelims        Typedef
    HiLink factorGenericNDelims        Typedef
    HiLink factorConstructor	Typedef
    HiLink factorPrivate	Special
    HiLink factorPrivateDefnDelims	Special
    HiLink factorPrivateMethodDelims	Special
    HiLink factorPGenericDelims        Special
    HiLink factorPGenericNDelims        Special
    HiLink factorString		String
    HiLink factorSbuf		String
    HiLink factorMultiStringContents		String
    HiLink factorMultiStringDelims Typedef
    HiLink factorBracketErr     Error
    HiLink factorComplex	Number
    HiLink factorRatio          Number
    HiLink factorBinary         Number
    HiLink factorBinErr         Error
    HiLink factorHex            Number
    HiLink factorHexErr         Error
    HiLink factorOctal          Number
    HiLink factorOctErr         Error
    HiLink factorFloat		Float
    HiLink factorInt		Number
    HiLink factorUsing          Include
    HiLink factorUse            Include
    HiLink factorRequires       Include
    HiLink factorIn             Define
    HiLink factorChar           Character
    HiLink factorCharErr        Error
    HiLink factorDelimiter      Delimiter
    HiLink factorBackslash      Special
    HiLink factorCompileDirective Typedef
    HiLink factorSymbol         Define
    HiLink factorMixin         Typedef
    HiLink factorInstance         Typedef
    HiLink factorHook         Typedef
    HiLink factorMain         Define
    HiLink factorPostpone       Define
    HiLink factorDefer          Define
    HiLink factorForget         Define
    HiLink factorAlien          Define
    HiLink factorTuple          Typedef

    if &bg == "dark"
	hi   hlLevel0 ctermfg=red         guifg=red1
	hi   hlLevel1 ctermfg=yellow      guifg=orange1
	hi   hlLevel2 ctermfg=green       guifg=yellow1
	hi   hlLevel3 ctermfg=cyan        guifg=greenyellow
	hi   hlLevel4 ctermfg=magenta     guifg=green1
	hi   hlLevel5 ctermfg=red         guifg=springgreen1
	hi   hlLevel6 ctermfg=yellow      guifg=cyan1
	hi   hlLevel7 ctermfg=green       guifg=slateblue1
	hi   hlLevel8 ctermfg=cyan        guifg=magenta1
	hi   hlLevel9 ctermfg=magenta     guifg=purple1
    else
	hi   hlLevel0 ctermfg=red         guifg=red3
	hi   hlLevel1 ctermfg=darkyellow  guifg=orangered3
	hi   hlLevel2 ctermfg=darkgreen   guifg=orange2
	hi   hlLevel3 ctermfg=blue        guifg=yellow3
	hi   hlLevel4 ctermfg=darkmagenta guifg=olivedrab4
	hi   hlLevel5 ctermfg=red         guifg=green4
	hi   hlLevel6 ctermfg=darkyellow  guifg=paleturquoise3
	hi   hlLevel7 ctermfg=darkgreen   guifg=deepskyblue4
	hi   hlLevel8 ctermfg=blue        guifg=darkslateblue
	hi   hlLevel9 ctermfg=darkmagenta guifg=darkviolet
    endif

    delcommand HiLink
endif

let b:current_syntax = "factor"

set sw=4
set ts=4
set expandtab
set autoindent " annoying?

" vim: syntax=vim

