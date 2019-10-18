
" Vim syntax file
" Language: Factor
" Maintainer: Alex Chapman <chapman.alex@gmail.com>
" Last Change: 2012 Jul 11
" To run: USING: html.templates html.templates.fhtml ; "resource:misc/factor.vim.fgen" <fhtml> call-template

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" Factor is case sensitive.
syn case match

" Make all of these characters part of a word (useful for skipping over words with w, e, and b)
if version >= 600
    setlocal iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
else
    set iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
endif

syn cluster factorCluster contains=factorComment,factorFrySpecifier,factorKeyword,factorRepeat,factorConditional,factorBoolean,factorBreakpoint,factorDeclaration,factorCallQuotation,factorExecute,factorCallNextMethod,factorString,factorTriString,factorSbuf,@factorNumber,@factorNumErr,factorDelimiter,factorChar,factorBackslash,factorMBackslash,factorLiteral,factorLiteralBlock,@factorWordOps,factorAlien,factorSlot,factorTuple,factorError,factorStruct

syn match factorTodo /\(TODO\|FIXME\|XXX\):\=/ contained
syn match factorComment /\<#\?!\>.*/ contains=factorTodo,@Spell
syn match factorShebang /\%\^#!.*/ display
syn match factorShebangErr /\%\^#!\S\+/

syn cluster factorDefnContents contains=@factorCluster,factorStackEffect,factorLiteralStackEffect,factorArray0,factorQuotation0

syn region factorDefn matchgroup=factorDefnDelims start=/\<\(SYNTAX\|\(MACRO\|MEMO\|TYPED\)\?:\?\):\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorMethod matchgroup=factorMethodDelims start=/\<M::\?\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents
syn region factorGeneric matchgroup=factorGenericDelims start=/\<\(GENERIC\|MATH\):\s\+\S\+\>/ end=/$/ contains=factorStackEffect
syn region factorGenericN matchgroup=factorGenericNDelims start=/\<GENERIC#\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect

syn region factorPrivateDefn matchgroup=factorPrivateDefnDelims start=/\<\(SYNTAX\|\(MACRO\|MEMO\|TYPED\)\?:\?\):\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPrivateMethod matchgroup=factorPrivateMethodDelims start=/\<M::\?\s\+\S\+\s\+\S\+\>/ end=/\<;\>/ contains=@factorDefnContents contained
syn region factorPGeneric matchgroup=factorPGenericDelims start=/\<\(GENERIC\|MATH\):\s\+\S\+\>/ end=/$/ contains=factorStackEffect contained
syn region factorPGenericN matchgroup=factorPGenericNDelims start=/\<GENERIC#\s\+\S\+\s\+\d\+\>/ end=/$/ contains=factorStackEffect

syn region None matchgroup=factorPrivate start=/\<<PRIVATE\>/ end=/\<PRIVATE>\>/ contains=@factorDefnContents,factorPrivateDefn,factorPrivateMethod,factorPGeneric,factorPGenericN


syn keyword factorBoolean f t
syn keyword factorBreakpoint B
syn keyword factorFrySpecifier @ _ contained
syn keyword factorDeclaration delimiter deprecated final flushable foldable inline recursive
syn match factorCallQuotation /\<call(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackEffect
syn match factorExecute /\<execute(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackEffect
syn keyword factorCallNextMethod call-next-method

syn keyword factorKeyword or 4drop 2bi 2tri while wrapper nip bi* wrapper? callstack>array 4dip die dupd both? callstack callstack? 3dup hashcode same? tri@ pick curry build ?execute 3bi prepose ?if clone >boolean eq? tri* ? = swapd 2over 2keep 3keep clear 2dup when not tuple? dup 2bi* 2tri* call 4keep tri-curry object bi@ do unless* if* loop bi-curry* drop when* assert= retainstack assert? -rot execute 2bi@ 2tri@ with boa either? 3drop bi curry? datastack until 3dip over 3curry tri-curry* tri-curry@ swap and 2nip throw bi-curry (clone) hashcode* compose 2dip if 3tri unless compose? tuple 2curry keep 4dup equal? assert tri 2drop most <wrapper> boolean? identity-hashcode identity-tuple? null new dip bi-curry@ rot identity-tuple xor boolean
syn keyword factorKeyword ?at assoc? assoc-clone-like assoc= delete-at* assoc-partition extract-keys new-assoc value? assoc-size map>assoc push-at assoc-differ assoc-like key? assoc-intersect assoc-refine assoc-union! assoc-union assoc-combine at* assoc-filter! assoc-empty? at+ assoc-subset? set-at assoc-hashcode sift-values assoc-all? change-at assoc-each assoc-diff sift-keys zip values value-at rename-at inc-at enum? at cache assoc>map assoc-diff! <enum> assoc assoc-map enum value-at* assoc-map-as >alist assoc-filter-as clear-assoc assoc-stack maybe-set-at assoc-filter 2cache delete-at assoc-find substitute keys assoc-any? unzip
syn keyword factorKeyword case execute-effect no-cond no-case? 3cleave>quot 2cleave cond>quot wrong-values? 4cleave no-cond? cleave>quot no-case shallow-spread>quot case>quot 3cleave wrong-values to-fixed-point alist>quot case-find cond cleave call-effect 2cleave>quot recursive-hashcode linear-case-quot spread deep-spread>quot 4cleave>quot
syn keyword factorKeyword number= if-zero next-power-of-2 each-integer ?1+ fp-special? imaginary-part unless-zero float>bits number? fp-infinity? bignum? fp-snan? denominator fp-bitwise= * + power-of-2? - u>= / >= bitand log2-expects-positive neg? < log2 > out-of-fixnum-range integer? number bits>double 2/ zero? (find-integer) out-of-fixnum-range? bits>float float? shift ratio? even? ratio fp-sign bitnot >fixnum complex? /i integer>fixnum /f when-zero sgn >bignum next-float u< u> mod recip rational find-last-integer >float (all-integers?) 2^ times integer fixnum? neg fixnum sq bignum (each-integer) bit? fp-qnan? find-integer complex <fp-nan> real double>bits bitor rem fp-nan-payload all-integers? real-part log2-expects-positive? prev-float align unordered? float fp-nan? abs bitxor integer>fixnum-strict u<= odd? <= /mod >integer real? rational? numerator
syn keyword factorKeyword member-eq? append assert-sequence= find-last-from selector-for clone-like 3sequence assert-sequence? map-as trim-head-slice last-index-from reversed index-from cut* pad-tail remove-eq! concat-as but-last snip trim-tail nths nth sequence slice? <slice> partition remove-nth tail-slice empty? tail* if-empty member? virtual-sequence? find-from set-length drop-prefix unclip-last-slice iota unclip bounds-error? map-sum accumulate-as map start midpoint@ ?first rest-slice prepend-as prepend fourth sift accumulate! new-sequence ?last follow map! like first4 1sequence reverse slice unless-empty collector padding virtual@ repetition? set-last index 4sequence max-length set-second immutable-sequence first2 first3 supremum reduce-index replicate-as unclip-slice suffix! insert-nth trim-tail-slice tail 3append short count suffix concat flip find-index filter immutable? reverse! sum 2sequence map-integers delete-all start* indices snip-slice check-slice sequence? head map-find filter! append-as halves selector sequence= collapse-slice interleave 2map reduce filter-as binary-reduce ?second slice-error? product bounds-check? bounds-check harvest immutable virtual-exemplar find produce remove pad-head last replicate set-fourth cartesian-product remove-eq shorten cartesian-map cartesian-each reversed? find-index-from map-find-last 3map-as shorter? 3map find-last head-slice pop* 2map-as tail-slice* but-last-slice 2map-reduce iota? accumulate each append! cut-slice new-resizable each-index head-slice* sequence-hashcode pop set-nth ?nth second join when-empty immutable-sequence? <reversed> all? 3append-as virtual-sequence subseq? remove-nth! push-either new-like length last-index collector-for 2selector push-if 2all? lengthen assert-sequence copy map-reduce move third first 3each tail? set-first prefix bounds-error any? <repetition> trim-slice exchange surround 2reduce cut change-nth min-length set-third produce-as push-all head? delete-slice rest sum-lengths 2each head* infimum remove! glue slice-error subseq trim replace-slice trim-head push map-index unclip-last mismatch repetition
syn keyword factorKeyword global +@ set-namestack change-global with-variable on toggle set dec initialize namestack get get-global change init-namespaces with-scope off set-global namespace with-variables inc counter is-global make-assoc with-global
syn keyword factorKeyword <array> 2array 3array pair >array 1array 4array pair? array resize-array array?
syn keyword factorKeyword +character+ bad-seek-type? each-morsel readln stream-seek read print with-output-stream with-output>error each-stream-block-slice contents input-stream? stream-read-partial-unsafe write1 stream-write1 (stream-contents-by-length-or-block) stream-copy stream-element-type with-input-stream with-error-stream* stream-print stream-contents stream-read with-output+error-stream* stream-tell tell-output bl seek-output with-input-output+error-streams* bad-seek-type nl stream-nl stream-length write flush with-error>output +byte+ with-input-output+error-streams stream-read-into with-output+error-stream stream-flush read1 seek-absolute? stream-read1 read-into read-partial-into each-block-size lines stream-readln stream-read-until invalid-read-buffer seek-end each-block-slice with-output-stream* stream-lines stream-read-unsafe seek-absolute output-stream? each-line (stream-contents-by-element) stream-seekable? invalid-read-buffer? (stream-contents-by-block) with-streams seek-input seek-relative? stream-read-partial-into input-stream stream-write with-error-stream read-partial stream-copy* seek-end? seek-relative with-input-stream* error-stream read-until stream-contents* tell-input each-block with-streams* output-stream (stream-contents-by-length) stream-read-partial each-stream-block each-stream-line
syn keyword factorKeyword resize-string >string <string> 1string string string?
syn keyword factorKeyword vector? <vector> ?push vector >vector 1vector
syn keyword factorKeyword with-return restarts return-continuation with-datastack recover in-callback? rethrow-restarts throw-continue <restart> ifcc original-error error-in-thread cleanup restart? ignore-errors compute-restarts attempt-all-error error-thread continue <continuation> attempt-all-error? condition? <condition> throw-restarts error restart thread-error-hook continue-with current-continuation continuation callcc1 rethrow error-continuation condition callcc0 callback-error-hook continuation? attempt-all return


syn cluster factorReal          contains=factorInt,factorFloat,factorPosRatio,factorNegRatio,factorBinary,factorHex,factorOctal
syn cluster factorNumber        contains=@factorReal,factorComplex
syn cluster factorNumErr        contains=factorBinErr,factorHexErr,factorOctErr
syn match   factorInt           /\<[+-]\=[0-9]\([0-9,]*[0-9]\)\?\([eE]\([+-]\)\?[0-9]\+\)\?\>/
syn match   factorFloat         /\<[+-]\=\([0-9,]*[0-9]\)\?\(\.\(\([0-9,]*[0-9]\+\)\?\([eE]\([+-]\)\?[0-9]\+\)\?\)\?\)\?\>/
syn match   factorPosRatio      /\<+\=[0-9]\([0-9,]*[0-9]\)\?\(+[0-9]\([0-9,]*[0-9]\+\)\?\)\?\/-\=[0-9]\([0-9,]*[0-9]\+\)\?\.\?\>/
syn match   factorNegRatio      /\<\-[0-9]\([0-9,]*[0-9]\)\?\(\-[0-9]\([0-9,]*[0-9]\+\)\?\)\?\/-\=[0-9]\([0-9,]*[0-9]\+\)\?\.\?\>/
syn region  factorComplex       start=/\<C{\>/ end=/\<}\>/ contains=@factorReal
syn match   factorBinErr        /\<[+-]\=0b[01,]*[^01 ]\S*\>/
syn match   factorBinary        /\<[+-]\=0b[01,]\+\>/
syn match   factorHexErr        /\<[+-]\=0x\(,\S*\|\S*,\|[-0-9a-fA-Fp,]*[^-0-9a-fA-Fp, ]\S*\)\>/
syn match   factorHex           /\<[+-]\=0x[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\(\.[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\)\?\(p-\=[0-9]\([0-9,]*[0-9]\)\?\)\?\>/
syn match   factorOctErr        /\<[+-]\=0o\(,\S*\|\S*,\|[0-7,]*[^0-7, ]\S*\)\>/
syn match   factorOctal         /\<[+-]\=0o[0-7,]\+\>/
syn match   factorNan           /\<NAN:\s\+[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\>/

syn match   factorIn            /\<IN:\s\+\S\+\>/
syn match   factorUse           /\<USE:\s\+\S\+\>/
syn match   factorUnuse         /\<UNUSE:\s\+\S\+\>/

syn match   factorChar          /\<CHAR:\s\+\S\+\>/

syn match   factorBackslash     /\<\\\>\s\+\S\+\>/
syn match   factorMBackslash    /\<M\\\>\s\+\S\+\s\+\S\+\>/
syn match   factorLiteral       /\<\$\>\s\+\S\+\>/
syn region  factorLiteralBlock  start=/\<\$\[\>/ end=/\<\]\>/

syn region  factorUsing         start=/\<USING:\>/       end=/;/
syn match   factorQualified     /\<QUALIFIED:\s\+\S\+\>/
syn match   factorQualifiedWith /\<QUALIFIED-WITH:\s\+\S\+\s\+\S\+\>/
syn region  factorExclude       start=/\<EXCLUDE:\>/     end=/;/
syn region  factorFrom          start=/\<FROM:\>/        end=/;/
syn match   factorRename        /\<RENAME:\s\+\S\+\s\+\S\+\s=>\s\+\S\+\>/
syn region  factorSingletons    start=/\<SINGLETONS:\>/  end=/;/
syn match   factorSymbol        /\<SYMBOL:\s\+\S\+\>/
syn region  factorSymbols       start=/\<SYMBOLS:\>/     end=/;/
syn region  factorConstructor2  start=/\<CONSTRUCTOR:\?/ end=/;/
syn region  factorIntersection  start=/\<INTERSECTION:\>/ end=/\<;\>/
syn region  factorTuple         start=/\<TUPLE:\>/ end=/\<;\>/
syn region  factorError         start=/\<ERROR:\>/ end=/\<;\>/
syn region  factorUnion         start=/\<UNION:\>/ end=/\<;\>/
syn region  factorStruct        start=/\<\(UNION-STRUCT:\|STRUCT:\)\>/ end=/\<;\>/

syn match   factorConstant      /\<CONSTANT:\s\+\S\+\>/
syn match   factorAlias         /\<ALIAS:\s\+\S\+\s\+\S\+\>/
syn match   factorSingleton     /\<SINGLETON:\s\+\S\+\>/
syn match   factorPostpone      /\<POSTPONE:\s\+\S\+\>/
syn match   factorDefer         /\<DEFER:\s\+\S\+\>/
syn match   factorForget        /\<FORGET:\s\+\S\+\>/
syn match   factorMixin         /\<MIXIN:\s\+\S\+\>/
syn match   factorInstance      /\<INSTANCE:\s\+\S\+\s\+\S\+\>/
syn match   factorHook          /\<HOOK:\s\+\S\+\s\+\S\+\>/ nextgroup=factorStackEffect skipwhite skipempty
syn match   factorMain          /\<MAIN:\s\+\S\+\>/
syn match   factorConstructor   /\<C:\s\+\S\+\s\+\S\+\>/
syn match   factorAlien         /\<ALIEN:\s\+[0-9a-fA-F]\([0-9a-fA-F,]*[0-9a-fA-F]\)\?\>/
syn match   factorSlot          /\<SLOT:\s\+\S\+\>/

syn cluster factorWordOps       contains=factorConstant,factorAlias,factorSingleton,factorSingletons,factorSymbol,factorSymbols,factorPostpone,factorDefer,factorForget,factorMixin,factorInstance,factorHook,factorMain,factorConstructor

"TODO:
"misc:
" HELP:
" ARTICLE:
"literals:
" PRIMITIVE:

"C interface:
" C-ENUM:
" FUNCTION:
" TYPEDEF:
" LIBRARY:
"#\ "

syn match factorEscape /\\\([\\astnr0e\"]\|u\x\{6}\|u{\S\+}\|x\x\{2}\)/ contained display
syn region factorString start=/\<"/ skip=/\\"/ end=/"/ contains=factorEscape
syn region factorTriString start=/\<"""/ skip=/\\"/ end=/"""/ contains=factorEscape
syn region factorSbuf start=/\<[-a-zA-Z0-9]\+"\>/ skip=/\\"/ end=/"/

syn region factorMultiString matchgroup=factorMultiStringDelims start=/\<STRING:\s\+\S\+\>/ end=/^;$/ contains=factorMultiStringContents
syn match factorMultiStringContents /.*/ contained

"syn match factorStackEffectErr /\<)\>/
"syn region factorStackEffectErr start=/\<(\>/ end=/\<)\>/
"syn region factorStackEffect start=/\<(\>/ end=/\<)\>/ contained
syn match factorStackEffect /(\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+)\>/ contained contains=factorStackDelims,factorStackItems,factorStackVariables,factorCallExecuteDelim
syn match factorLiteralStackEffect /((\s\+\(\S*\s\+\)*--\(\s\+\S*\)*\s\+))\>/ contained contains=factorStackDelims,factorStackItems,factorStackVariables,factorCallExecuteDelim
syn match factorStackVariables contained "\<\.\.\S\+\>"
syn match factorStackItems contained "\<\(\.\.\)\@!\S\+\>"
syn keyword factorStackDelims contained ( ) (( )) --
syn match factorCallExecuteDelim contained /(\s/

"adapted from lisp.vim
if exists("g:factor_norainbow")
    syn region factorQuotation matchgroup=factorDelimiter start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/ matchgroup=factorDelimiter end=/\<\]\>/ contains=ALL
else
    syn region factorQuotation0           matchgroup=hlLevel0 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation1,factorArray1
    syn region factorQuotation1 contained matchgroup=hlLevel1 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation2,factorArray2
    syn region factorQuotation2 contained matchgroup=hlLevel2 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation3,factorArray3
    syn region factorQuotation3 contained matchgroup=hlLevel3 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation4,factorArray4
    syn region factorQuotation4 contained matchgroup=hlLevel4 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation5,factorArray5
    syn region factorQuotation5 contained matchgroup=hlLevel5 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation6,factorArray6
    syn region factorQuotation6 contained matchgroup=hlLevel6 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation7,factorArray7
    syn region factorQuotation7 contained matchgroup=hlLevel7 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation8,factorArray8
    syn region factorQuotation8 contained matchgroup=hlLevel8 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation9,factorArray9
    syn region factorQuotation9 contained matchgroup=hlLevel9 start=/\<\(\(\('\|\$\|\)\[\)\|\[\(let\||\)\)\>/  end=/\<\]\>/ contains=@factorCluster,factorQuotation0,factorArray0
endif

if exists("g:factor_norainbow")
    syn region factorArray    matchgroup=factorDelimiter start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/  matchgroup=factorDelimiter end=/\<}\>/ contains=ALL
else
    syn region factorArray0           matchgroup=hlLevel0 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray1,factorQuotation1
    syn region factorArray1 contained matchgroup=hlLevel1 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray2,factorQuotation2
    syn region factorArray2 contained matchgroup=hlLevel2 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray3,factorQuotation3
    syn region factorArray3 contained matchgroup=hlLevel3 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray4,factorQuotation4
    syn region factorArray4 contained matchgroup=hlLevel4 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray5,factorQuotation5
    syn region factorArray5 contained matchgroup=hlLevel5 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray6,factorQuotation6
    syn region factorArray6 contained matchgroup=hlLevel6 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray7,factorQuotation7
    syn region factorArray7 contained matchgroup=hlLevel7 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray8,factorQuotation8
    syn region factorArray8 contained matchgroup=hlLevel8 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray9,factorQuotation9
    syn region factorArray9 contained matchgroup=hlLevel9 start=/\<\(\$\|[-a-zA-Z0-9]\+\)\?{\>/ end=/\<}\>/ contains=@factorCluster,factorArray0,factorQuotation0
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
    HiLink factorShebang                PreProc
    HiLink factorShebangErr             Error
    HiLink factorStackEffect            Typedef
    HiLink factorStackDelims            Delimiter
    HiLink factorCallExecuteDelim       Delimiter
    HiLink factorStackVariables         Special
    HiLink factorStackItems             Identifier
    HiLink factorLiteralStackEffect     Typedef
    HiLink factorTodo                   Todo
    HiLink factorInclude                Include
    HiLink factorRepeat                 Repeat
    HiLink factorConditional            Conditional
    HiLink factorKeyword                Keyword
    HiLink factorCallQuotation          Keyword
    HiLink factorExecute                Keyword
    HiLink factorCallNextMethod         Keyword
    HiLink factorOperator               Operator
    HiLink factorFrySpecifier           Operator
    HiLink factorBoolean                Boolean
    HiLink factorBreakpoint             Debug
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
    HiLink factorEscape                 SpecialChar
    HiLink factorString                 String
    HiLink factorTriString              String
    HiLink factorSbuf                   String
    HiLink factorMultiStringContents    String
    HiLink factorMultiStringDelims      Typedef
    HiLink factorBracketErr             Error
    HiLink factorComplex                Number
    HiLink factorPosRatio               Number
    HiLink factorNegRatio               Number
    HiLink factorBinary                 Number
    HiLink factorBinErr                 Error
    HiLink factorHex                    Number
    HiLink factorHexErr                 Error
    HiLink factorNan                    Number
    HiLink factorOctal                  Number
    HiLink factorOctErr                 Error
    HiLink factorFloat                  Float
    HiLink factorInt                    Number
    HiLink factorUsing                  Include
    HiLink factorQualified              Include
    HiLink factorQualifiedWith          Include
    HiLink factorExclude                Include
    HiLink factorFrom                   Include
    HiLink factorRename                 Include
    HiLink factorUse                    Include
    HiLink factorUnuse                  Include
    HiLink factorIn                     Define
    HiLink factorChar                   Character
    HiLink factorDelimiter              Delimiter
    HiLink factorBackslash              Special
    HiLink factorMBackslash             Special
    HiLink factorLiteral                Special
    HiLink factorLiteralBlock           Special
    HiLink factorDeclaration            Typedef
    HiLink factorSymbol                 Define
    HiLink factorSymbols                Define
    HiLink factorConstant               Define
    HiLink factorAlias                  Define
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
    HiLink factorSlot                   Define
    HiLink factorIntersection           Typedef
    HiLink factorTuple                  Typedef
    HiLink factorError                  Typedef
    HiLink factorUnion                  Typedef
    HiLink factorStruct                 Typedef

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

" vim:set ft=vim sw=4:

