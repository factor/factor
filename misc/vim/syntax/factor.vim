" Vim syntax file
" Language: factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: 2009 May 19
" To run: USE: html.templates.fhtml "resource:misc/factor.vim.fgen" <fhtml> call-template

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

syn keyword factorKeyword or tuck 2bi 2tri while wrapper nip 4dip wrapper? bi* callstack>array both? hashcode die dupd callstack callstack? 3dup tri@ pick curry build ?execute 3bi prepose >boolean ?if clone eq? tri* ? = swapd call-clear 2over 2keep 3keep clear 2dup when not tuple? dup 2bi* 2tri* call tri-curry object bi@ do unless* if* loop bi-curry* drop when* assert= retainstack assert? -rot execute 2bi@ 2tri@ boa with either? 3drop bi curry? datastack until 3dip over 3curry roll tri-curry* swap tri-curry@ 2nip and throw set-retainstack bi-curry (clone) hashcode* compose spin 2dip if 3tri unless compose? tuple keep 2curry equal? set-datastack assert tri 2drop most <wrapper> boolean? identity-tuple? null new set-callstack dip bi-curry@ rot -roll xor identity-tuple boolean
syn keyword factorKeyword ?at assoc? assoc-clone-like assoc= delete-at* assoc-partition extract-keys new-assoc value? assoc-size map>assoc push-at assoc-like key? assoc-intersect update assoc-union assoc-combine at* assoc-empty? at+ set-at assoc-all? assoc-subset? assoc-hashcode change-at assoc-each assoc-diff zip values value-at rename-at inc-at enum? at cache assoc>map <enum> assoc assoc-map enum value-at* remove-all assoc-map-as >alist assoc-filter-as substitute-here clear-assoc assoc-stack substitute assoc-filter 2cache delete-at assoc-find keys assoc-any? at-default unzip
syn keyword factorKeyword case execute-effect dispatch-case-quot <buckets> no-cond no-case? 3cleave>quot contiguous-range? 2cleave cond>quot wrong-values? no-cond? cleave>quot no-case hash-dispatch-quot case>quot 3cleave wrong-values alist>quot hash-case-table hash-case-quot case-find (distribute-buckets) cond cleave distribute-buckets call-effect 2cleave>quot recursive-hashcode linear-case-quot spread spread>quot
syn keyword factorKeyword byte-array>bignum sgn >bignum next-float number= each-integer next-power-of-2 ?1+ fp-special? imaginary-part mod recip float>bits rational >float number? 2^ bignum? integer fixnum? neg fixnum sq bignum fp-snan? fp-infinity? denominator (all-integers?) times find-last-integer (each-integer) bit? * + fp-bitwise= - fp-qnan? / power-of-2? >= bitand find-integer complex <fp-nan> < log2 > integer? real number bits>double double>bits bitor 2/ zero? rem fp-nan-payload all-integers? (find-integer) real-part prev-float align bits>float float? shift float 1+ 1- fp-nan? abs bitxor ratio? even? <= /mod odd? >integer ratio rational? bitnot real? >fixnum complex? /i numerator /f
syn keyword factorKeyword append assert-sequence= find-last-from trim-head-slice clone-like 3sequence assert-sequence? map-as filter-here last-index-from prepare-index reversed index-from cut* pad-tail (indices) concat-as remq but-last snip trim-tail nths nth 2pusher sequence slice? <slice> partition remove-nth tail-slice empty? tail* if-empty find-from virtual-sequence? member? set-length delq drop-prefix unclip iota unclip-last-slice bounds-error? sequence-hashcode-step map start midpoint@ rest-slice prepend fourth sift delete sigma new-sequence follow like delete-nth first4 1sequence reverse slice unless-empty padding virtual@ repetition? index 4sequence max-length set-second immutable-sequence first2 first3 replicate-as reduce-index unclip-slice supremum insert-nth trim-tail-slice tail 3append short count suffix concat flip filter sum immutable? 2sequence delete-all start* indices snip-slice check-slice sequence? head map-find reduce append-as reverse-here sequence= halves collapse-slice interleave 2map binary-reduce virtual-seq slice-error? product bounds-check? bounds-check harvest immutable find produce remove pad-head replicate set-fourth peek shorten reversed? map-find-last 3map-as 2unclip-slice shorter? 3map find-last head-slice pop* 2map-as tail-slice* but-last-slice 2map-reduce iota? accumulate each pusher cut-slice new-resizable each-index head-slice* 2reverse-each sequence-hashcode memq? pop set-nth ?nth <flat-slice> second change-each join when-empty accumulator immutable-sequence? <reversed> all? 3append-as virtual-sequence subseq? push-either new-like length last-index push-if 2all? lengthen assert-sequence copy map-reduce move third first 3each tail? set-first prefix bounds-error any? <repetition> trim-slice exchange surround 2reduce cut change-nth min-length set-third produce-as push-all head? delete-slice rest sum-lengths 2each head* infimum glue slice-error subseq replace-slice push repetition map-index trim-head unclip-last mismatch trim
syn keyword factorKeyword global +@ change set-namestack change-global init-namespaces on off set-global namespace set with-scope bind with-variable inc dec counter initialize namestack get get-global make-assoc
syn keyword factorKeyword <array> 2array 3array pair >array 1array 4array pair? array resize-array array?
syn keyword factorKeyword +character+ bad-seek-type? readln stream-seek read print with-output-stream contents write1 stream-write1 stream-copy stream-element-type with-input-stream stream-print stream-read stream-contents bl seek-output bad-seek-type nl stream-nl write flush stream-lines +byte+ stream-flush read1 seek-absolute? stream-read1 lines stream-readln stream-read-until each-line seek-end with-output-stream* seek-absolute with-streams seek-input seek-relative? input-stream stream-write read-partial seek-end? seek-relative error-stream read-until with-input-stream* with-streams* each-block output-stream stream-read-partial
syn keyword factorKeyword resize-string >string <string> 1string string string?
syn keyword factorKeyword vector? <vector> ?push vector >vector 1vector
syn keyword factorKeyword with-return restarts return-continuation with-datastack recover rethrow-restarts <restart> ifcc set-catchstack >continuation< cleanup ignore-errors restart? compute-restarts attempt-all-error error-thread continue <continuation> attempt-all-error? condition? <condition> throw-restarts error catchstack continue-with thread-error-hook continuation rethrow callcc1 error-continuation callcc0 attempt-all condition continuation? restart return


syn cluster factorReal          contains=factorInt,factorFloat,factorRatio,factorBinary,factorHex,factorOctal
syn cluster factorNumber        contains=@factorReal,factorComplex
syn cluster factorNumErr        contains=factorBinErr,factorHexErr,factorOctErr
syn match   factorInt           /\<-\=\d\+\>/
syn match   factorFloat         /\<-\=\d*\.\d\+\>/
syn match   factorRatio         /\<-\=\d*\.*\d\+\/-\=\d*\.*\d\+\>/
syn region  factorComplex       start=/\<C{\>/ end=/\<}\>/ contains=@factorReal
syn match   factorBinErr        /\<BIN:\s\+[01]*[^\s01]\S*\>/
syn match   factorBinary        /\<BIN:\s\+[01]\+\>/
syn match   factorHexErr        /\<HEX:\s\+\x*[^\x\s]\S*\>/
syn match   factorHex           /\<HEX:\s\+\x\+\>/
syn match   factorOctErr        /\<OCT:\s\+\o*[^\o\s]\S*\>/
syn match   factorOctal         /\<OCT:\s\+\o\+\>/

syn match   factorIn            /\<IN:\s\+\S\+\>/
syn match   factorUse           /\<USE:\s\+\S\+\>/
syn match   factorUnuse         /\<UNUSE:\s\+\S\+\>/

syn match   factorCharErr       /\<CHAR:\s\+\S\+/
syn match   factorChar          /\<CHAR:\s\+\\\=\S\>/

syn match   factorBackslash     /\<\\\>\s\+\S\+\>/

syn region  factorUsing         start=/\<USING:\>/       end=/;/
syn region  factorSingletons    start=/\<SINGLETONS:\>/  end=/;/
syn match   factorSymbol        /\<SYMBOL:\s\+\S\+\>/
syn region  factorSymbols       start=/\<SYMBOLS:\>/     end=/;/
syn region  factorConstructor2  start=/\<CONSTRUCTOR:\?/ end=/;/
syn region  factorTuple         start=/\<TUPLE:\>/ end=/\<;\>/

syn match   factorConstant      /\<CONSTANT:\s\+\S\+\>/
syn match   factorSingleton     /\<SINGLETON:\s\+\S\+\>/
syn match   factorPostpone      /\<POSTPONE:\s\+\S\+\>/
syn match   factorDefer         /\<DEFER:\s\+\S\+\>/
syn match   factorForget        /\<FORGET:\s\+\S\+\>/
syn match   factorMixin         /\<MIXIN:\s\+\S\+\>/
syn match   factorInstance      /\<INSTANCE:\s\+\S\+\s\+\S\+\>/
syn match   factorHook          /\<HOOK:\s\+\S\+\s\+\S\+\>/
syn match   factorMain          /\<MAIN:\s\+\S\+\>/
syn match   factorConstructor   /\<C:\s\+\S\+\s\+\S\+\>/
syn match   factorAlien         /\<ALIEN:\s\+\d\+\>/

syn cluster factorWordOps       contains=factorSymbol,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain,factorConstructor


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
"QUALIFIED:
"QUALIFIED-WITH:
"FROM:
"ALIAS:
"! POSTPONE: "
"#\ "

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

    HiLink factorComment                Comment
    HiLink factorStackEffect            Typedef
    HiLink factorTodo                   Todo
    HiLink factorInclude                Include
    HiLink factorRepeat                 Repeat
    HiLink factorConditional            Conditional
    HiLink factorKeyword                Keyword
    HiLink factorOperator               Operator
    HiLink factorBoolean                Boolean
    HiLink factorDefnDelims             Typedef
    HiLink factorMethodDelims           Typedef
    HiLink factorGenericDelims          Typedef
    HiLink factorGenericNDelims         Typedef
    HiLink factorConstructor            Typedef
    HiLink factorConstructor2           Typedef
    HiLink factorPrivate                Special
    HiLink factorPrivateDefnDelims      Special
    HiLink factorPrivateMethodDelims    Special
    HiLink factorPGenericDelims         Special
    HiLink factorPGenericNDelims        Special
    HiLink factorString                 String
    HiLink factorSbuf                   String
    HiLink factorMultiStringContents    String
    HiLink factorMultiStringDelims      Typedef
    HiLink factorBracketErr             Error
    HiLink factorComplex                Number
    HiLink factorRatio                  Number
    HiLink factorBinary                 Number
    HiLink factorBinErr                 Error
    HiLink factorHex                    Number
    HiLink factorHexErr                 Error
    HiLink factorOctal                  Number
    HiLink factorOctErr                 Error
    HiLink factorFloat                  Float
    HiLink factorInt                    Number
    HiLink factorUsing                  Include
    HiLink factorUse                    Include
    HiLink factorUnuse                  Include
    HiLink factorIn                     Define
    HiLink factorChar                   Character
    HiLink factorCharErr                Error
    HiLink factorDelimiter              Delimiter
    HiLink factorBackslash              Special
    HiLink factorCompileDirective       Typedef
    HiLink factorSymbol                 Define
    HiLink factorConstant               Define
    HiLink factorSingleton              Define
    HiLink factorSingletons             Define
    HiLink factorMixin                  Typedef
    HiLink factorInstance               Typedef
    HiLink factorHook                   Typedef
    HiLink factorMain                   Define
    HiLink factorPostpone               Define
    HiLink factorDefer                  Define
    HiLink factorForget                 Define
    HiLink factorAlien                  Define
    HiLink factorTuple                  Typedef

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
