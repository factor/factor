;;; factor-mode.el --- Major mode for editing Factor programs.

;; Copyright (C) 2013 Erik Charlebois
;; Copyright (C) 2008, 2009, 2010 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Maintainer: Erik Charlebois <erikcharlebois@gmail.com>
;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, factor
;; Start date: Tue Dec 02, 2008 21:32

;;; Commentary:

;; A major mode for editing Factor programs. It provides indenting and
;; font-lock support.


;;; Code:

(require 'thingatpt)
(require 'font-lock)
(require 'ring)
(require 'fuel-base)

;;; Customization:

;;;###autoload
(defgroup factor nil
  "Major mode for Factor source code."
  :group 'languages)

(defcustom factor-cycling-no-ask nil
  "Whether to never create source/doc/tests file when cycling."
  :type 'boolean
  :group 'factor)

(defcustom factor-cycle-always-ask-p t
  "Whether to always ask for file creation when cycling to a
source/docs/tests file. When set to false, you'll be asked only once."
  :type 'boolean
  :group 'factor)

(defcustom factor-indent-level 4
  "Indentation of Factor statements."
  :type 'integer
  :safe 'integerp
  :group 'factor)

(defcustom factor-comment-column 32
  "Indentation column of comments."
  :type 'integer
  :safe 'integerp
  :group 'factor)


;;; Faces:

;;;###autoload
(defgroup factor-faces nil
  "Faces used by factor-mode."
  :group 'factor
  :group 'faces)

(defface factor-font-lock-constructor '((t (:inherit font-lock-type-face)))
  "Factor for constructor words."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-constant '((t (:inherit font-lock-constant-face)))
  "Face for constant and literal values."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-number '((t (:inherit font-lock-constant-face)))
  "Face for integer and floating-point constants."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-ratio '((t (:inherit font-lock-constant-face)))
  "Face for ratio constants."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-declaration '((t (:inherit font-lock-keyword-face)))
  "declaration words"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-ebnf-form '((t (:inherit font-lock-constant-face)))
  "EBNF: ... ;EBNF form"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-error-form '((t (:inherit font-lock-warning-face)))
  "ERROR: ... ; form"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-parsing-word '((t (:inherit font-lock-keyword-face)))
  "parsing words"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-postpone-body '((t (:inherit font-lock-comment-face)))
  "postponed form"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-setter-word
  '((t (:inherit font-lock-function-name-face)))
  "setter words (>>foo)"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-getter-word
  '((t (:inherit font-lock-function-name-face)))
  "getter words (foo>>)"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-string '((t (:inherit font-lock-string-face)))
  "strings"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-symbol '((t (:inherit font-lock-variable-name-face)))
  "name of symbol being defined"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-type-name '((t (:inherit font-lock-type-face)))
  "type names"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-vocabulary-name
  '((t (:inherit font-lock-constant-face)))
  "vocabulary names"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-word
  '((t (:inherit font-lock-function-name-face)))
  "Face for the word, generic or method being defined."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-invalid-syntax
  '((t (:inherit font-lock-warning-face)))
  "syntactically invalid constructs"
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-comment '((t (:inherit font-lock-comment-face)))
  "Face for Factor comments."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-stack-effect '((t :inherit font-lock-comment-face))
  "Face for Factor stack effect declarations."
  :group 'factor-faces
  :group 'faces)

(defface factor-font-lock-type-in-stack-effect '((t :inherit font-lock-comment-face
                                                    :bold t))
  "Face for Factor types in stack effect declarations."
  :group 'factor-faces
  :group 'faces)


;;; Thing-at-point:

(defun factor-beginning-of-symbol ()
  "Move point to the beginning of the current symbol."
  (skip-syntax-backward "w_()"))

(defun factor-end-of-symbol ()
  "Move point to the end of the current symbol."
  (skip-syntax-forward "w_()"))

(put 'factor-symbol 'end-op 'factor-end-of-symbol)
(put 'factor-symbol 'beginning-op 'factor-beginning-of-symbol)

(defsubst factor-symbol-at-point ()
  (let* ((thing (thing-at-point 'factor-symbol))
         (s (when thing (substring-no-properties thing))))
    (and (> (length s) 0) s)))


;;; Regexps galore:

;; Utility regexp used by other regexps to match a Factor symbol name
(setq-local symbol "\\(\\(?:\\sw\\|\\s_\\)+\\)")

;; Used to font-lock stack effect declarations with may be nested.
(defun factor-match-brackets (limit)
  (let ((start (point)))
    (when (re-search-forward "[ \n]([ \n]" limit t)
      (backward-char 2)
      (let ((bracket-start (point)))
        (when (condition-case nil
                  (progn (forward-sexp) 't)
                ('scan-error nil))
          (let ((bracket-stop (point)))
            (goto-char bracket-start)
            (re-search-forward ".+" bracket-stop 'mv)))))))

;; Excludes parsing words that are handled by other regexps
(defconst factor-parsing-words
  '(":" "::" ";" "&:" "<<" "<PRIVATE" ">>"
    "ABOUT:" "AFTER:" "ALIAS:" "ALIEN:" "ARTICLE:"
    "B" "BEFORE:"
    "C:" "C-GLOBAL:" "C-TYPE:" "CHAR:" "COLOR:" "COM-INTERFACE:" "CONSTANT:"
    "CONSULT:" "call-next-method"
    "DEFER:"
    "EBNF:" ";EBNF" "ENUM:" "ERROR:"
    "FOREIGN-ATOMIC-TYPE:" "FOREIGN-ENUM-TYPE:" "FOREIGN-RECORD-TYPE:" "FUNCTION-ALIAS:"
    "GAME:" "GENERIC#" "GENERIC:" "GIR:"
    "GLSL-SHADER:" "GLSL-PROGRAM:"
    "HELP:" "HINTS:" "HOOK:"
    "IN:" "initial:" "INSTANCE:" "INTERSECTION:" "IMPLEMENT-STRUCTS:"
    "LIBRARY:"
    "M:" "M::" "MACRO:" "MACRO::" "MAIN:" "MATH:"
    "MEMO:" "MEMO:" "METHOD:" "MIXIN:"
    "NAN:"
    "POSTPONE:" "PRIMITIVE:" "PRIVATE>" "PROTOCOL:" "PROVIDE:"
    "QUALIFIED-WITH:" "QUALIFIED:"
    "read-only" "RENAME:" "REQUIRE:"  "REQUIRES:"
    "SINGLETON:" "SINGLETONS:" "SLOT:" "SPECIALIZED-ARRAY:"
    "SPECIALIZED-ARRAYS:" "STRING:" "SYNTAX:"
    "TYPEDEF:" "TYPED:" "TYPED::"
    "UNIFORM-TUPLE:" "UNION:" "USE:"
    "VARIANT:" "VERTEX-FORMAT:"))

(defconst factor-parsing-words-regex
  (regexp-opt factor-parsing-words 'symbols))

(defconst factor-constant-words
  '("f" "t"))

(defconst factor-constant-words-regex
  (regexp-opt factor-constant-words 'symbols))

(defconst factor-bracer-words
  '("B" "BV" "C" "CS" "H" "T" "V" "W"))

(defconst factor-brace-words-regex
  (format "%s{" (regexp-opt factor-bracer-words t)))

(defconst factor-declaration-words
  '("flushable" "foldable" "inline" "parsing" "recursive" "delimiter"))

(defconst factor-declaration-words-regex
  (regexp-opt factor-declaration-words 'symbols))

(defsubst factor-second-word-regex (prefixes)
  (format "%s +\\([^ \r\n]+\\)" (regexp-opt prefixes t)))

(defconst factor-method-definition-regex
  "^M::? +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst factor-before-definition-regex
  "^BEFORE: +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst factor-after-definition-regex
  "^AFTER: +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst factor-integer-regex
  "\\_<-?\\(0[xob][0-9a-fA-F]+\\|[0-9]+\\)\\_>")

(defconst factor-raw-float-regex
  "[0-9]*\\.[0-9]*\\([eEpP][+-]?[0-9]+\\)?")

(defconst factor-float-regex
  (format "\\_<-?%s\\_>" factor-raw-float-regex))

(defconst factor-number-regex
  (format "\\([0-9]+\\|%s\\)" factor-raw-float-regex))

(defconst factor-ratio-regex
  (format "\\_<[+-]?%s/-?%s\\_>" factor-number-regex factor-number-regex))

(defconst factor-bad-string-regex
  "\\_<\"[^>]\\([^\"\n]\\|\\\\\"\\)*\n")

(defconst factor-word-definition-regex
  (format "\\_<\\(%s\\)?[:#] +\\(%s\\)"
          (regexp-opt
           '(":" "GENERIC" "DEFER" "HOOK" "MACRO" "MAIN" "MATH" "POSTPONE"
             "SYNTAX" "TYPED" "TYPED:" "RENAME"))
          "\\(\\sw\\|\\s_\\|\\s(\\|\\s)\\)+"))

(defconst factor-alias-definition-regex
  "^ALIAS: +\\(\\_<.+?\\_>\\) +\\(\\_<.+?\\_>\\)")

;; Vocabulary patterns
(defconst factor-vocab-ref-regex
  (factor-second-word-regex
   '("IN:" "USE:" "EXCLUDE:" "QUALIFIED:" "QUALIFIED-WITH:")))

(defconst factor-using-lines-regex "^\\(USING\\):[ \n]+\\([^;\t]*\\);")

;; Symbols
(defconst factor-symbol-definition-regex
  (factor-second-word-regex
   '("&:" "CONSTANT:" "DESTRUCTOR:" "FORGET:" "SYMBOL:" "VAR:")))

(defconst factor-symbols-lines-regex "^\\(SYMBOLS\\):[ \n]+\\([^;\t]*\\);")

(defconst factor-int-constant-def-regex
  (factor-second-word-regex '("ALIEN:" "CHAR:" "NAN:")))

(defconst factor-type-definition-regex
  (factor-second-word-regex
   '("C-STRUCT:" "C-UNION:" "COM-INTERFACE:" "MIXIN:" "SINGLETON:"
     "SPECIALIZED-ARRAY:" "STRUCT:" "UNION:" "UNION-STRUCT:")))

(defconst factor-error-regex
  (factor-second-word-regex '("ERROR:")))

(defconst factor-constructor-regex
  "<[^ >]+>")

(defconst factor-getter-regex
  "\\_<\\(?:\\sw\\|\\s_\\)+>>\\_>")

(defconst factor-setter-regex
  "\\_<>>\\(?:\\sw\\|\\s_\\)+\\_>")

(defconst factor-stack-effect-regex
  "\\( ( [^)]* )\\)\\|\\( (( [^)]* ))\\)")

(defconst factor-use-line-regex "^USE: +\\(.*\\)$")

(defconst factor-current-vocab-regex "^IN: +\\([^ \r\n\f]+\\)")

(defconst factor-sub-vocab-regex "^<\\([^ \n]+\\) *$")

(defconst factor-indent-def-starts
  '("" ":"
    "AFTER" "BEFORE"
    "COM-INTERFACE" "CONSULT"
    "ENUM" "ERROR"
    "FROM" "FUNCTION:" "FUNCTION-ALIAS:"
    "INTERSECTION:"
    "M" "M:" "MACRO" "MACRO:"
    "MEMO" "MEMO:" "METHOD"
    "SYNTAX"
    "PREDICATE" "PRIMITIVE" "PROTOCOL"
    "SINGLETONS"
    "STRUCT" "SYMBOLS" "TAG" "TUPLE"
    "TYPED" "TYPED:"
    "UNIFORM-TUPLE"
    "UNION-STRUCT" "UNION"
    "VARIANT" "VERTEX-FORMAT"))

(defconst factor-no-indent-def-starts
  '("ARTICLE" "HELP" "SPECIALIZED-ARRAYS"))

(defconst factor-indent-def-start-regex
  (format "^\\(%s:\\)\\( \\|\n\\)" (regexp-opt factor-indent-def-starts)))

(defconst factor-definition-start-regex
  (format "^\\(%s:\\) " (regexp-opt (append factor-no-indent-def-starts
                                            factor-indent-def-starts))))

(defconst factor-definition-end-regex
  (format "\\(\\(^\\| +\\);\\( *%s\\)*\\($\\| +\\)\\)"
          factor-declaration-words-regex))

(defconst factor-single-liner-regex
  (regexp-opt '("ABOUT:"
                "ALIAS:"
                "CONSTANT:" "C:" "C-GLOBAL:" "C-TYPE:"
                "DEFER:" "DESTRUCTOR:"
                "FORGET:"
                "GAME:" "GENERIC:" "GENERIC#" "GLSL-PROGRAM:"
                "HOOK:"
                "IN:" "INSTANCE:"
                "LIBRARY:"
                "MAIN:" "MATH:" "MIXIN:"
                "NAN:"
                "POSTPONE:" "PRIVATE>" "<PRIVATE"
                "QUALIFIED-WITH:" "QUALIFIED:"
                "RENAME:"
                "SINGLETON:" "SLOT:" "SPECIALIZED-ARRAY:"
                "TYPEDEF:"
                "USE:")))

(defconst factor-begin-of-def-regex
  (format "^USING: \\|\\(%s\\)\\|\\(^%s .*\\)"
          factor-definition-start-regex
          factor-single-liner-regex))

(defconst factor-end-of-def-line-regex
  (format "^.*%s" factor-definition-end-regex))

(defconst factor-end-of-def-regex
  (format "\\(%s\\)\\|\\(^%s .*\\)"
          factor-end-of-def-line-regex
          factor-single-liner-regex))

(defconst factor-word-signature-regex
  (format ":[^ ]* \\([^ ]+\\)\\(%s\\)*" factor-stack-effect-regex))

(defconst factor-defun-signature-regex
  (format "\\(%s\\|%s\\)"
          factor-word-signature-regex
          "M[^:]*: [^ ]+ [^ ]+"))

(defconst factor-constructor-decl-regex
  "\\_<C: +\\(\\w+\\) +\\(\\w+\\)\\( .*\\)?$")

(defconst factor-typedef-regex
  (format "\\_<TYPEDEF: +%s +%s\\( .*\\)?$" symbol symbol))

(defconst factor-c-global-regex
  (format "\\_<C-GLOBAL: +%s +%s\\( .*\\)?$" symbol symbol))

(defconst factor-c-type-regex
  (format "\\_<C-TYPE: +%s\\( .*\\)?$" symbol))

(defconst factor-rename-regex
  (format "\\_<RENAME: +%s +%s +=> +%s\\( .*\\)?$" symbol symbol symbol))


;;; Font lock:

(defconst factor-font-lock-keywords
  `((,factor-brace-words-regex 1 'factor-font-lock-parsing-word)
    (,factor-vocab-ref-regex 2 'factor-font-lock-vocabulary-name)

    (,factor-using-lines-regex (1 'factor-font-lock-parsing-word)
                               (2 'factor-font-lock-vocabulary-name))
    (,factor-symbols-lines-regex (1 'factor-font-lock-parsing-word)
                                 (2 'factor-font-lock-word))
    (,(format "^\\(FROM\\|EXCLUDE\\):[ \n]+%s[ \n]+=>+\\([^;\t]*\\);" symbol)
     (1 'factor-font-lock-parsing-word)
     (2 'factor-font-lock-vocabulary-name)
     (3 'factor-font-lock-word))
    (,factor-constructor-decl-regex
     (1 'factor-font-lock-word)
     (2 'factor-font-lock-type-name)
     (3 'factor-font-lock-invalid-syntax nil t))
    (,factor-typedef-regex (1 'factor-font-lock-type-name)
                           (2 'factor-font-lock-type-name)
                           (3 'factor-font-lock-invalid-syntax nil t))
    (,factor-c-global-regex (1 'factor-font-lock-type-name)
                            (2 'factor-font-lock-word)
                            (3 'factor-font-lock-invalid-syntax nil t))
    (,factor-c-type-regex (1 'factor-font-lock-type-name)
                          (2 'factor-font-lock-invalid-syntax nil t))
    (,factor-rename-regex (1 'factor-font-lock-word)
                          (2 'factor-font-lock-vocabulary-name)
                          (3 'factor-font-lock-word)
                          (4 'factor-font-lock-invalid-syntax nil t))
    (,factor-declaration-words-regex . 'factor-font-lock-comment)
    (,factor-word-definition-regex 2 'factor-font-lock-word)
    (,factor-alias-definition-regex (1 'factor-font-lock-word)
                                    (2 'factor-font-lock-word))
    (,factor-int-constant-def-regex 2 'factor-font-lock-constant)
    (,factor-integer-regex . 'factor-font-lock-number)
    (,factor-float-regex . 'factor-font-lock-number)
    (,factor-ratio-regex . 'factor-font-lock-ratio)
    (,factor-type-definition-regex 2 'factor-font-lock-type-name)
    (,factor-error-regex 2 'factor-font-lock-error-form)
    (,factor-method-definition-regex (1 'factor-font-lock-type-name)
                                     (2 'factor-font-lock-word))
    (,factor-before-definition-regex (1 'factor-font-lock-type-name)
                                     (2 'factor-font-lock-word))
    (,factor-after-definition-regex  (1 'factor-font-lock-type-name)
                                     (2 'factor-font-lock-word))

    ;; Highlights tuple and struct definitions. The TUPLE/STRUCT
    ;; parsing word, class name and optional parent classes are
    ;; matched in three groups. Then the text up until the end of the
    ;; definition that is terminated with ";" is searched for words
    ;; that are slot names which are highlighted with the face
    ;; factor-font-lock-symbol.
    (,(format
       "\\(%s\\):[ \n]+%s\\(?:[ \n]+<[ \n]+%s\\)?"
       (regexp-opt '("ENUM" "PROTOCOL" "STRUCT" "TUPLE" "UNION-STRUCT"))
       symbol
       symbol)
     (1 'factor-font-lock-parsing-word)
     (2 'factor-font-lock-type-name)
     (3 'factor-font-lock-type-name nil t)
     ;; A slot is either a single symbol or a sequence along the
     ;; lines: { foo initial: "bar }
     ("\\(\\(?:\\sw\\|\\s_\\)+\\)\\|\\(?:{[ \n]+\\(\\(?:\\sw\\|\\s_\\)+\\)[^}]+\\)"
      (factor-find-end-of-def)
      nil
      (1 'factor-font-lock-symbol nil t)
      (2 'factor-font-lock-symbol nil t)))
    ;; Highlights predicates
    (,(format "\\(PREDICATE\\):[ \n]%s[ \n]<[ \n]%s" symbol symbol)
     (1 'factor-font-lock-parsing-word)
     (2 'factor-font-lock-type-name)
     (3 'factor-font-lock-type-name))
    ;; Highlights alien function definitions. Types in stack effect
    ;; declarations are given a bold face.
    (,(format "\\(\\(?:GL-\\)?FUNCTION\\|CALLBACK\\):[ \n]+%s[ \n]+%s[ \n]+" symbol symbol)
     (1 'factor-font-lock-parsing-word)
     (2 'factor-font-lock-type-name)
     (3 'factor-font-lock-word)
     ;; Regexp from hell that puts every type name in the first group,
     ;; names and brackets in the second and third.
     ("\\(?:\\(\\(?:\\sw\\|\\s_\\)+\\)[ \n]+\\(\\(?:\\sw\\|\\s_\\)+,?\\(?:[ \n]+)\\)?\\)\\|\\([()]\\)\\)"
      (factor-find-end-of-def)
      nil
      (1 'factor-font-lock-type-in-stack-effect nil t)
      (2 'factor-font-lock-stack-effect nil t)
      (3 'factor-font-lock-stack-effect nil t)))

    ;; Almost identical to the previous one, but for function aliases.
    (,(format "\\(FUNCTION-ALIAS\\):[ \n]+%s[ \n]+%s[ \n]+%s[ \n]+"
              symbol symbol symbol)
     (1 'factor-font-lock-parsing-word)
     (2 'factor-font-lock-word)
     (3 'factor-font-lock-type-name)
     (4 'factor-font-lock-word)
     ("\\(?:\\(\\(?:\\sw\\|\\s_\\)+\\)[ \n]+\\(\\(?:\\sw\\|\\s_\\)+,?\\(?:[ \n]+)\\)?\\)\\|\\([()]\\)\\)"
      (factor-find-end-of-def)
      nil
      (1 'factor-font-lock-type-in-stack-effect nil t)
      (2 'factor-font-lock-stack-effect nil t)
      (3 'factor-font-lock-stack-effect nil t)))
    (factor-match-brackets . 'factor-font-lock-stack-effect)
    (,factor-constructor-regex . 'factor-font-lock-constructor)
    (,factor-setter-regex . 'factor-font-lock-setter-word)
    (,factor-getter-regex . 'factor-font-lock-getter-word)
    (,factor-symbol-definition-regex (1 'factor-font-lock-parsing-word)
                                     (2 'factor-font-lock-word))
    (,factor-bad-string-regex . 'factor-font-lock-invalid-syntax)
    ("\\_<\\(P\\|SBUF\\|DLL\\)\"" 1 'factor-font-lock-parsing-word)
    (,factor-constant-words-regex . 'factor-font-lock-constant)
    (,factor-parsing-words-regex . 'factor-font-lock-parsing-word)
    (,"\t" . 'whitespace-highlight-face)))

;; Handling of multi-line constructs
(defun factor-font-lock-extend-region ()
  (eval-when-compile (defvar font-lock-beg) (defvar font-lock-end))
  (save-excursion
    (goto-char font-lock-beg)
    (let ((found (or (re-search-backward "\n\n" nil t) (point-min))))
      (goto-char font-lock-end)
      (when (re-search-forward "\n\n" nil t)
        (beginning-of-line)
        (setq font-lock-end (point)))
      (setq font-lock-beg found))))

;;; Source code analysis:

(defsubst factor-brackets-depth ()
  (nth 0 (syntax-ppss)))

(defsubst factor-brackets-start ()
  (nth 1 (syntax-ppss)))

(defun factor-brackets-end ()
  (save-excursion
    (goto-char (factor-brackets-start))
    (condition-case nil
        (progn (forward-sexp)
               (1- (point)))
      (error -1))))

(defsubst factor-indentation-at (pos)
  (save-excursion (goto-char pos) (current-indentation)))

(defsubst factor-at-begin-of-def ()
  (looking-at factor-begin-of-def-regex))

(defsubst factor-at-begin-of-indent-def ()
  (looking-at factor-indent-def-start-regex))

(defsubst factor-at-end-of-def ()
  (looking-at factor-end-of-def-regex))

(defsubst factor-looking-at-emptiness ()
  (looking-at "^[ ]*$\\|$"))

(defsubst factor-is-last-char (pos)
  (save-excursion
    (goto-char (1+ pos))
    (looking-at-p "[ ]*$")))

(defsubst factor-line-offset (pos)
  (- pos (save-excursion
           (goto-char pos)
           (beginning-of-line)
           (point))))

(defun factor-previous-non-blank ()
  (forward-line -1)
  (while (and (not (bobp)) (factor-looking-at-emptiness))
    (forward-line -1)))

(defsubst factor-beginning-of-defun (&optional times)
  (re-search-backward factor-begin-of-def-regex nil t times))

(defsubst factor-end-of-defun ()
  (re-search-forward factor-end-of-def-regex nil t))

(defun factor-beginning-of-block-pos ()
  (save-excursion
    (if (> (factor-brackets-depth) 0)
        (factor-brackets-start)
      (factor-beginning-of-defun)
      (point))))

(defun factor-at-setter-line ()
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward factor-setter-regex
                             (line-end-position)
                             t)
      (let* ((to (match-beginning 0))
             (from (factor-beginning-of-block-pos)))
        (goto-char from)
        (let ((depth (factor-brackets-depth)))
          (and (or (re-search-forward factor-constructor-regex to t)
                   (re-search-forward factor-setter-regex to t))
               (= depth (factor-brackets-depth))))))))

(defun factor-at-constructor-line ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward factor-constructor-regex (line-end-position) t)))

(defun factor-in-using ()
  (let ((p (point)))
    (save-excursion
      (and (re-search-backward "^USING:[ \n]" nil t)
           (re-search-forward " ;" nil t)
           (< p (match-end 0))))))

(defsubst factor-end-of-defun-pos ()
  (save-excursion
    (re-search-forward factor-end-of-def-regex nil t)
    (point)))

(defun factor-beginning-of-body ()
  (let ((p (point)))
    (and (factor-beginning-of-defun)
         (re-search-forward factor-defun-signature-regex p t)
         (not (re-search-forward factor-end-of-def-regex p t)))))

(defun factor-beginning-of-sexp ()
  (if (> (factor-brackets-depth) 0)
      (goto-char (factor-brackets-start))
    (factor-beginning-of-body)))

(defsubst factor-beginning-of-sexp-pos ()
  (save-excursion (factor-beginning-of-sexp) (point)))

(defun factor-find-end-of-def (&rest foo)
  (save-excursion
    (re-search-forward " ;" nil t)
    (1- (point))))


;;; USING/IN:

(defvar-local factor-current-vocab-function 'factor-find-in)

(defsubst factor-current-vocab ()
  (funcall factor-current-vocab-function))

(defun factor-find-in ()
  (save-excursion
    (when (re-search-backward factor-current-vocab-regex nil t)
      (match-string-no-properties 1))))

(defvar-local factor-usings-function 'factor-find-usings)

(defsubst factor-usings ()
  (funcall factor-usings-function))

(defun factor-file-has-private ()
  (save-excursion
    (goto-char (point-min))
    (and (re-search-forward "\\_<<PRIVATE\\_>" nil t)
         (re-search-forward "\\_<PRIVATE>\\_>" nil t))))

(defun factor-find-usings (&optional no-private)
  (save-excursion
    (let ((usings))
      (goto-char (point-max))
      (while (re-search-backward factor-using-lines-regex nil t)
        (dolist (u (split-string (match-string-no-properties 1) nil t))
          (push u usings)))
      (when (and (not no-private) (factor-file-has-private))
        (goto-char (point-max))
        (push (concat (factor-find-in) ".private") usings))
      usings)))


;;; Indentation:

(defsubst factor-increased-indentation (&optional i)
  (+ (or i (current-indentation)) factor-indent-level))

(defsubst factor-decreased-indentation (&optional i)
  (- (or i (current-indentation)) factor-indent-level))

(defun factor-indent-in-brackets ()
  (save-excursion
    (beginning-of-line)
    (when (> (factor-brackets-depth) 0)
      (let* ((bs (factor-brackets-start))
             (be (factor-brackets-end))
             (ln (line-number-at-pos)))
        (when (> ln (line-number-at-pos bs))
          (cond ((and (> be 0)
                      (= (- be (point)) (current-indentation))
                      (= ln (line-number-at-pos be)))
                 (factor-indentation-at bs))
                ((or (factor-is-last-char bs)
                     (not (eq ?\ (char-after (1+ bs)))))
                 (factor-increased-indentation
                  (factor-indentation-at bs)))
                (t (+ 2 (factor-line-offset bs)))))))))

(defun factor-indent-definition ()
  (save-excursion
    (beginning-of-line)
    (when (factor-at-begin-of-def) 0)))

(defsubst factor-previous-non-empty ()
  (forward-line -1)
  (while (and (not (bobp))
              (factor-looking-at-emptiness))
    (forward-line -1)))

(defun factor-indent-setter-line ()
  (when (factor-at-setter-line)
    (or (save-excursion
          (let ((indent (and (factor-at-constructor-line)
                             (current-indentation))))
            (while (not (or indent
                            (bobp)
                            (factor-at-begin-of-def)
                            (factor-at-end-of-def)))
              (if (factor-at-constructor-line)
                  (setq indent (factor-increased-indentation))
                (forward-line -1)))
            indent))
        (save-excursion
          (factor-previous-non-empty)
          (current-indentation)))))

(defun factor-indent-continuation ()
  (save-excursion
    (factor-previous-non-empty)
    (cond ((or (factor-at-end-of-def)
               (factor-at-setter-line))
           (factor-decreased-indentation))
          ((factor-at-begin-of-indent-def)
           (factor-increased-indentation))
          (t (current-indentation)))))

(defun factor-calculate-indentation ()
  "Calculate Factor indentation for line at point."
  (or (and (bobp) 0)
      (factor-indent-definition)
      (factor-indent-in-brackets)
      (factor-indent-setter-line)
      (factor-indent-continuation)
      0))

(defun factor-indent-line (&optional ignored)
  "Indents the current Factor line."
  (interactive)
  (let ((target (factor-calculate-indentation))
        (pos (- (point-max) (point))))
    (if (= target (current-indentation))
        (if (< (current-column) (current-indentation))
            (back-to-indentation))
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-to target)
      (if (> (- (point-max) pos) (point))
          (goto-char (- (point-max) pos))))))


;;; Buffer cycling:

(defconst factor-cycle-endings
  '(".factor" "-tests.factor" "-docs.factor"))

(defvar factor-cycle-ring
  (let ((ring (make-ring (length factor-cycle-endings))))
    (dolist (e factor-cycle-endings ring)
      (ring-insert ring e))
    ring))

(defconst factor-cycle-basename-regex
  (format "\\(.+?\\)\\(%s\\)$" (regexp-opt factor-cycle-endings)))

(defun factor-cycle-split (basename)
  (when (string-match factor-cycle-basename-regex basename)
    (cons (match-string 1 basename) (match-string 2 basename))))

(defun factor-cycle-next (file skip)
  (let* ((dir (file-name-directory file))
         (basename (file-name-nondirectory file))
         (p/s (factor-cycle-split basename))
         (prefix (car p/s))
         (ring factor-cycle-ring)
         (idx (or (ring-member ring (cdr p/s)) 0))
         (len (ring-size ring))
         (i 1)
         (result nil))
    (while (and (< i len) (not result))
      (let* ((suffix (ring-ref ring (+ i idx)))
             (path (expand-file-name (concat prefix suffix) dir)))
        (when (or (file-exists-p path)
                  (and (not skip)
                       (not (member suffix factor-cycling-no-ask))
                       (y-or-n-p (format "Create %s? " path))))
          (setq result path))
        (when (and (not factor-cycle-always-ask-p)
                   (not (member suffix factor-cycling-no-ask)))
          (setq factor-cycling-no-ask
                (cons name factor-cycling-no-ask))))
      (setq i (1+ i)))
    result))

(defun factor-visit-other-file (&optional create)
  "Cycle between code, tests and docs factor files.
With prefix, non-existing files will be created."
  (interactive "P")
  (let ((file (factor-cycle-next (buffer-file-name) (not create))))
    (unless file (error "No other file found"))
    (find-file file)
    (unless (file-exists-p file)
      (set-buffer-modified-p t)
      (save-buffer))))


;;; factor-mode:

;; I think it is correct to put almost all punctuation characters in
;; the word class because Factor words can be made up of almost
;; anything. Otherwise you get incredibly annoying regexps.
(defvar factor-mode-syntax-table
  (let ((table (make-syntax-table prog-mode-syntax-table)))
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?! "< 2b" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?# "_ 1b" table)
    (modify-syntax-entry ?$ "_" table)
    (modify-syntax-entry ?@ "_" table)
    (modify-syntax-entry ?? "_" table)
    (modify-syntax-entry ?_ "_" table)
    (modify-syntax-entry ?: "_" table)
    (modify-syntax-entry ?< "_" table)
    (modify-syntax-entry ?> "_" table)
    (modify-syntax-entry ?. "_" table)
    (modify-syntax-entry ?, "_" table)
    (modify-syntax-entry ?& "_" table)
    (modify-syntax-entry ?| "_" table)
    (modify-syntax-entry ?% "_" table)
    (modify-syntax-entry ?= "_" table)
    (modify-syntax-entry ?/ "_" table)
    (modify-syntax-entry ?+ "_" table)
    (modify-syntax-entry ?* "_" table)
    (modify-syntax-entry ?- "_" table)
    (modify-syntax-entry ?\; "_" table)
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    table))

(defun factor-font-lock-string (str)
  "Fontify STR as if it was Factor code."
  (with-temp-buffer
    (set-syntax-table factor-mode-syntax-table)
    (setq-local parse-sexp-ignore-comments t)
    (setq-local parse-sexp-lookup-properties t)
    (setq-local font-lock-defaults '(factor-font-lock-keywords nil nil nil nil))

    (insert str)
    (let ((font-lock-verbose nil))
      (font-lock-fontify-buffer))
    (buffer-string)))

;;;###autoload
(define-derived-mode factor-mode prog-mode "Factor"
  "A mode for editing programs written in the Factor programming language.
\\{factor-mode-map}"

  (setq-local comment-start "! ")
  (setq-local comment-end "")
  (setq-local comment-column factor-comment-column)
  (setq-local comment-start-skip "!+ *")
  (setq-local parse-sexp-ignore-comments t)
  (setq-local parse-sexp-lookup-properties t)
  (setq-local font-lock-defaults '(factor-font-lock-keywords))
  ;; Some syntactic constructs are often split over multiple lines so
  ;; we need to setup multiline font-lock.
  (setq-local font-lock-multiline t)
  (add-hook 'font-lock-extend-region-functions 'factor-font-lock-extend-region)

  (define-key factor-mode-map [remap ff-get-other-file]
    'factor-visit-other-file)

  (setq-local electric-indent-chars
              (append '(?\] ?\} ?\n) electric-indent-chars))

  (setq-local indent-line-function 'factor-indent-line)
  ;; No tabs for you!!
  (setq-local indent-tabs-mode nil)

  (setq-local beginning-of-defun-function 'factor-beginning-of-defun)
  (setq-local end-of-defun-function 'factor-end-of-defun))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))

;;;###autoload
(add-to-list 'interpreter-mode-alist '("factor" . factor-mode))


(provide 'factor-mode)

;;; factor-mode.el ends here
