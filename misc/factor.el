;;; factor.el --- Interacting with Factor within emacs
;;
;; Authors: Eduardo Cavazos <wayo.cavazos@gmail.com>
;;          Jose A Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;;; Quick setup:

;; Add these lines to your .emacs file:
;;
;;   (load-file "/scratch/repos/Factor/misc/factor.el")
;;   (setq factor-binary "/scratch/repos/Factor/factor")
;;   (setq factor-image "/scratch/repos/Factor/factor.image")
;;
;; Of course, you'll have to edit the directory paths for your system
;; accordingly. Alternatively, put this file in your load-path and use
;;
;;   (require 'factor)
;;
;; instead of load-file.
;;
;; That's all you have to do to "install" factor.el on your
;; system. Whenever you edit a factor file, Emacs will know to switch
;; to Factor mode.
;;
;; For further customization options,
;;   M-x customize-group RET factor
;;
;; To start a Factor listener inside Emacs,
;;   M-x run-factor

;;; Requirements:

(require 'font-lock)
(require 'comint)
(require 'view)

;;; Customization:

(defgroup factor nil
  "Factor mode"
  :group 'languages)

(defcustom factor-default-indent-width 4
  "Default indentantion width for factor-mode.

This value will be used for the local variable
`factor-indent-width' in new factor buffers. For existing code,
we first check if `factor-indent-width' is set explicitly in a
local variable section or line (e.g. '! -*- factor-indent-witdth: 2 -*-').
If that's not the case, `factor-mode' tries to infer its correct
value from the existing code in the buffer."
  :type 'integer
  :group 'factor)

(defcustom factor-binary "~/factor/factor"
  "Full path to the factor executable to use when starting a listener."
  :type '(file :must-match t)
  :group 'factor)

(defcustom factor-image "~/factor/factor.image"
  "Full path to the factor image to use when starting a listener."
  :type '(file :must-match t)
  :group 'factor)

(defcustom factor-use-doc-window t
  "When on, use a separate window to display help information.
Disable to see that information in the factor-listener comint
window."
  :type 'boolean
  :group 'factor)

(defcustom factor-listener-use-other-window t
  "Use a window other than the current buffer's when switching to
the factor-listener buffer."
  :type 'boolean
  :group 'factor)

(defcustom factor-listener-window-allow-split t
  "Allow window splitting when switching to the factor-listener
buffer."
  :type 'boolean
  :group 'factor)

(defcustom factor-help-always-ask t
  "When enabled, always ask for confirmation in help prompts."
  :type 'boolean
  :group 'factor)

(defcustom factor-help-use-minibuffer t
  "When enabled, use the minibuffer for short help messages."
  :type 'boolean
  :group 'factor)

(defcustom factor-display-compilation-output t
  "Display the REPL buffer before compiling files."
  :type 'boolean
  :group 'factor)

(defcustom factor-mode-hook nil
  "Hook run when entering Factor mode."
  :type 'hook
  :group 'factor)

(defcustom factor-help-mode-hook nil
  "Hook run by `factor-help-mode'."
  :type 'hook
  :group 'factor)

(defgroup factor-faces nil
  "Faces used in Factor mode"
  :group 'factor
  :group 'faces)

(defface factor-font-lock-parsing-word (face-default-spec font-lock-keyword-face)
  "Face for parsing words."
  :group 'factor-faces)

(defface factor-font-lock-declaration (face-default-spec font-lock-keyword-face)
  "Face for declaration words (inline, parsing ...)."
  :group 'factor-faces)

(defface factor-font-lock-comment (face-default-spec font-lock-comment-face)
  "Face for comments."
  :group 'factor-faces)

(defface factor-font-lock-string (face-default-spec font-lock-string-face)
  "Face for strings."
  :group 'factor-faces)

(defface factor-font-lock-stack-effect (face-default-spec font-lock-comment-face)
  "Face for stack effect specifications."
  :group 'factor-faces)

(defface factor-font-lock-word-definition (face-default-spec font-lock-function-name-face)
  "Face for word, generic or method being defined."
  :group 'factor-faces)

(defface factor-font-lock-symbol-definition (face-default-spec font-lock-variable-name-face)
  "Face for name of symbol being defined."
  :group 'factor-faces)

(defface factor-font-lock-vocabulary-name (face-default-spec font-lock-constant-face)
  "Face for names of vocabularies in USE or USING."
  :group 'factor-faces)

(defface factor-font-lock-type-definition (face-default-spec font-lock-type-face)
  "Face for type (tuple) names."
  :group 'factor-faces)

(defface factor-font-lock-constructor (face-default-spec font-lock-type-face)
  "Face for constructors (<foo>)."
  :group 'factor-faces)

(defface factor-font-lock-setter-word (face-default-spec font-lock-function-name-face)
  "Face for setter words (>>foo)."
  :group 'factor-faces)

(defface factor-font-lock-parsing-word (face-default-spec font-lock-keyword-face)
  "Face for parsing words."
  :group 'factor-faces)

(defface factor-font-lock-help-mode-headlines '((t (:bold t :weight bold)))
  "Face for headlines in help buffers."
  :group 'factor-faces)


;;; Factor mode font lock:

(defconst factor--parsing-words
  '("{" "}" "^:" "^::" ";" "<<" "<PRIVATE" ">>"
    "BIN:" "BV{" "B{" "C:" "C-STRUCT:" "C-UNION:" "CHAR:" "CS{" "C{"
    "DEFER:" "ERROR:" "EXCLUDE:" "FORGET:"
    "GENERIC#" "GENERIC:" "HEX:" "HOOK:" "H{"
    "IN:" "INSTANCE:" "INTERSECTION:"
    "M:" "MACRO:" "MACRO::" "MAIN:" "MATH:" "METHOD:" "MIXIN:"
    "OCT:" "POSTPONE:" "PREDICATE:" "PRIMITIVE:" "PRIVATE>" "PROVIDE:"
    "REQUIRE:"  "REQUIRES:" "SINGLETON:" "SLOT:" "SYMBOL:" "SYMBOLS:"
    "TUPLE:" "T{" "t\\??" "TYPEDEF:"
    "UNION:" "USE:" "USING:" "V{" "VAR:" "VARS:" "W{"))

(defconst factor--regex-parsing-words-ext
  (regexp-opt '("B" "call-next-method" "delimiter" "f" "initial:" "read-only")
              'words))

(defconst factor--declaration-words
  '("flushable" "foldable" "inline" "parsing" "recursive"))

(defconst factor--regex-declaration-words
  (regexp-opt factor--declaration-words 'words))

(defsubst factor--regex-second-word (prefixes)
  (format "^%s +\\([^ \r\n]+\\)" (regexp-opt prefixes t)))

(defconst factor--regex-word-definition
  (factor--regex-second-word '(":" "::" "M:" "GENERIC:")))

(defconst factor--regex-type-definition
  (factor--regex-second-word '("TUPLE:")))

(defconst factor--regex-parent-type "^TUPLE: +[^ ]+ +< +\\([^ ]+\\)")

(defconst factor--regex-constructor "<[^ >]+>")

(defconst factor--regex-setter "\\W>>[^ ]+\\b")

(defconst factor--regex-symbol-definition
  (factor--regex-second-word '("SYMBOL:")))

(defconst factor--regex-stack-effect " ( .* )")

(defconst factor--regex-using-line "^USING: +\\([^;]*\\);")

(defconst factor--regex-use-line "^USE: +\\(.*\\)$")

(defconst factor--font-lock-keywords
  `((,factor--regex-stack-effect . 'factor-font-lock-stack-effect)
    ("\\(P\\|SBUF\\)\"" 1 'factor-font-lock-parsing-word)
    ,@(mapcar #'(lambda (w) (cons (concat "\\(^\\| \\)\\(" w "\\)\\($\\| \\)")
                             '(2 'factor-font-lock-parsing-word)))
              factor--parsing-words)
    (,factor--regex-parsing-words-ext . 'factor-font-lock-parsing-word)
    (,factor--regex-declaration-words 1 'factor-font-lock-declaration)
    (,factor--regex-word-definition 2 'factor-font-lock-word-definition)
    (,factor--regex-type-definition 2 'factor-font-lock-type-definition)
    (,factor--regex-parent-type 1 'factor-font-lock-type-definition)
    (,factor--regex-constructor . 'factor-font-lock-constructor)
    (,factor--regex-setter . 'factor-font-lock-setter-word)
    (,factor--regex-symbol-definition 2 'factor-font-lock-symbol-definition)
    (,factor--regex-using-line 1 'factor-font-lock-vocabulary-name)
    (,factor--regex-use-line 1 'factor-font-lock-vocabulary-name))
  "Font lock keywords definition for Factor mode.")


;;; Factor mode syntax:

(defconst factor--regex-definition-starters
  (regexp-opt '("TUPLE" "MACRO" "MACRO:" "M" ":" "")))

(defconst factor--regex-definition-start
  (format "^\\(%s:\\) " factor--regex-definition-starters))

(defconst factor--regex-definition-end
  (format "\\(;\\( +%s\\)?\\)" factor--regex-declaration-words))

(defconst factor--font-lock-syntactic-keywords
  `(("\\(#!\\)" (1 "<"))
    (" \\(!\\)" (1 "<"))
    ("^\\(!\\)" (1 "<"))
    ("\\(!(\\) .* \\()\\)" (1 "<") (2 ">"))))

(defvar factor-mode-syntax-table nil
  "Syntax table used while in Factor mode.")

(if factor-mode-syntax-table
    ()
  (let ((i 0))
    (setq factor-mode-syntax-table (make-syntax-table))

    ;; Default is atom-constituent
    (while (< i 256)
      (modify-syntax-entry i "_   " factor-mode-syntax-table)
      (setq i (1+ i)))

    ;; Word components.
    (setq i ?0)
    (while (<= i ?9)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))
    (setq i ?A)
    (while (<= i ?Z)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))
    (setq i ?a)
    (while (<= i ?z)
      (modify-syntax-entry i "w   " factor-mode-syntax-table)
      (setq i (1+ i)))

    ;; Whitespace
    (modify-syntax-entry ?\t " " factor-mode-syntax-table)
    (modify-syntax-entry ?\f " " factor-mode-syntax-table)
    (modify-syntax-entry ?\r " " factor-mode-syntax-table)
    (modify-syntax-entry ?  " " factor-mode-syntax-table)

    ;; (end of) Comments
    (modify-syntax-entry ?\n ">" factor-mode-syntax-table)

    ;; Parenthesis
    (modify-syntax-entry ?\[ "(]  " factor-mode-syntax-table)
    (modify-syntax-entry ?\] ")[  " factor-mode-syntax-table)
    (modify-syntax-entry ?{ "(}  " factor-mode-syntax-table)
    (modify-syntax-entry ?} "){  " factor-mode-syntax-table)

    (modify-syntax-entry ?\( "()" factor-mode-syntax-table)
    (modify-syntax-entry ?\) ")(" factor-mode-syntax-table)

    ;; Strings
    (modify-syntax-entry ?\" "\"" factor-mode-syntax-table)
    (modify-syntax-entry ?\\ "/" factor-mode-syntax-table)))

;;; symbol-at-point

(defun factor--beginning-of-symbol ()
  "Move point to the beginning of the current symbol."
  (while (eq (char-before) ?:) (backward-char))
  (skip-syntax-backward "w_"))

(defun factor--end-of-symbol ()
  "Move point to the end of the current symbol."
  (skip-syntax-forward "w_")
  (while (looking-at ":") (forward-char)))

(put 'factor-symbol 'end-op 'factor--end-of-symbol)
(put 'factor-symbol 'beginning-op 'factor--beginning-of-symbol)

(defsubst factor--symbol-at-point ()
  (let ((s (substring-no-properties (thing-at-point 'factor-symbol))))
    (and (> (length s) 0) s)))


;;; Factor mode indentation:

(make-variable-buffer-local
 (defvar factor-indent-width factor-default-indent-width
   "Indentation width in factor buffers. A local variable."))

(defun factor--guess-indent-width ()
  "Chooses an indentation value from existing code."
  (let ((word-cont "^ +[^ ]")
        (iw))
    (save-excursion
      (beginning-of-buffer)
      (while (not iw)
        (if (not (re-search-forward factor--regex-definition-start nil t))
            (setq iw factor-default-indent-width)
          (forward-line)
          (when (looking-at word-cont)
            (setq iw (current-indentation))))))
    iw))

(defsubst factor--ppss-brackets-depth ()
  (nth 0 (syntax-ppss)))

(defsubst factor--ppss-brackets-start ()
  (nth 1 (syntax-ppss)))

(defun factor--ppss-brackets-end ()
  (save-excursion
    (goto-char (factor--ppss-brackets-start))
    (forward-sexp)
    (1- (point))))

(defsubst factor--indentation-at (pos)
  (save-excursion (goto-char pos) (current-indentation)))

(defsubst factor--at-first-char-p ()
  (= (- (point) (line-beginning-position)) (current-indentation)))

(defconst factor--regex-single-liner
  (format "^%s" (regexp-opt '("DEFER:" "GENERIC:" "IN:"
                              "PRIVATE>" "<PRIVATE" "SYMBOL:" "USE:"))))

(defsubst factor--at-begin-of-def ()
  (or (looking-at factor--regex-definition-start)
      (looking-at factor--regex-single-liner)))

(defsubst factor--looking-at-emptiness ()
  (looking-at "^[ \t]*$"))

(defsubst factor--at-end-of-def ()
  (or (looking-at factor--regex-definition-end)
      (looking-at factor--regex-single-liner)))

(defun factor--at-setter-line ()
  (save-excursion
    (beginning-of-line)
    (if (not (factor--looking-at-emptiness))
        (re-search-forward factor--regex-setter (line-end-position) t)
      (forward-line -1)
      (or (factor--at-constructor-line)
          (factor--at-setter-line)))))

(defun factor--at-constructor-line ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward factor--regex-constructor (line-end-position) t)))

(defsubst factor--increased-indentation (&optional i)
  (+ (or i (current-indentation)) factor-indent-width))
(defsubst factor--decreased-indentation (&optional i)
  (- (or i (current-indentation)) factor-indent-width))

(defun factor--indent-in-brackets ()
  (save-excursion
    (beginning-of-line)
    (when (> (factor--ppss-brackets-depth) 0)
      (let ((op (factor--ppss-brackets-start))
            (cl (factor--ppss-brackets-end))
            (ln (line-number-at-pos)))
        (when (> ln (line-number-at-pos op))
          (if (= ln (line-number-at-pos cl))
              (factor--indentation-at op)
            (factor--increased-indentation (factor--indentation-at op))))))))

(defun factor--indent-definition ()
  (save-excursion
    (beginning-of-line)
    (when (factor--at-begin-of-def) 0)))

(defun factor--indent-setter-line ()
  (when (factor--at-setter-line)
    (save-excursion
      (let ((indent (and (factor--at-constructor-line) (current-indentation))))
        (while (not (or indent
                        (bobp)
                        (factor--at-begin-of-def)
                        (factor--at-end-of-def)))
          (if (factor--at-constructor-line)
              (setq indent (factor--increased-indentation))
            (forward-line -1)))
        indent))))

(defun factor--indent-continuation ()
  (save-excursion
    (forward-line -1)
    (while (and (not (bobp)) (factor--looking-at-emptiness))
      (forward-line -1))
    (if (or (factor--at-end-of-def) (factor--at-setter-line))
        (factor--decreased-indentation)
      (if (factor--at-begin-of-def)
          (factor--increased-indentation)
        (current-indentation)))))

(defun factor--calculate-indentation ()
  "Calculate Factor indentation for line at point."
  (or (and (bobp) 0)
      (factor--indent-definition)
      (factor--indent-in-brackets)
      (factor--indent-setter-line)
      (factor--indent-continuation)
      0))

(defun factor--indent-line ()
  "Indent current line as Factor code"
  (let ((target (factor--calculate-indentation))
        (pos (- (point-max) (point))))
    (if (= target (current-indentation))
        (if (< (current-column) (current-indentation))
            (back-to-indentation))
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-to target)
      (if (> (- (point-max) pos) (point))
          (goto-char (- (point-max) pos))))))


;; Factor mode:
(defvar factor-mode-map (make-sparse-keymap)
  "Key map used by Factor mode.")

(defsubst factor--beginning-of-defun (times)
  (re-search-backward factor--regex-definition-start nil t times))

(defsubst factor--end-of-defun ()
  (re-search-forward factor--regex-definition-end nil t))

;;;###autoload
(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language.
\\{factor-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map factor-mode-map)
  (setq major-mode 'factor-mode)
  (setq mode-name "Factor")
  ;; Font locking
  (set (make-local-variable 'comment-start) "! ")
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (set (make-local-variable 'font-lock-comment-face) 'factor-font-lock-comment)
  (set (make-local-variable 'font-lock-string-face) 'factor-font-lock-string)
  (set (make-local-variable 'font-lock-defaults)
       `(factor--font-lock-keywords
         nil nil nil nil
         (font-lock-syntactic-keywords . ,factor--font-lock-syntactic-keywords)))

  (set-syntax-table factor-mode-syntax-table)
  ;; Defun navigation
  (set (make-local-variable 'beginning-of-defun-function) 'factor--beginning-of-defun)
  (set (make-local-variable 'end-of-defun-function) 'factor--end-of-defun)
  (set (make-local-variable 'open-paren-in-column-0-is-defun-start) nil)
  ;; Indentation
  (set (make-local-variable 'indent-line-function) 'factor--indent-line)
  (setq factor-indent-width (factor--guess-indent-width))
  (setq indent-tabs-mode nil)
  ;; ElDoc
  (set (make-local-variable 'eldoc-documentation-function) 'factor--eldoc)

  (run-hooks 'factor-mode-hook))

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))


;;; Factor listener mode:

;;;###autoload
(define-derived-mode factor-listener-mode comint-mode "Factor Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{factor-listener-mode-map}"
  (set (make-local-variable 'comint-prompt-regexp) "^( [^)]+ ) "))

(defvar factor--listener-buffer nil
  "The buffer in which the Factor listener is running.")

(defun factor--listener-start-process ()
  "Start an inferior Factor listener process, using
`factor-binary' and `factor-image'."
  (setq factor--listener-buffer
        (apply 'make-comint "factor" (expand-file-name factor-binary) nil
               `("-run=listener" ,(format "-i=%s" (expand-file-name factor-image)))))
  (with-current-buffer factor--listener-buffer
    (factor-listener-mode)))

(defun factor--listener-process (&optional start)
  (or (and (buffer-live-p factor--listener-buffer)
           (get-buffer-process factor--listener-buffer))
      (when start
        (factor--listener-start-process)
        (factor--listener-process t))))

;;;###autoload
(defalias 'switch-to-factor 'run-factor)
;;;###autoload
(defun run-factor (&optional arg)
  "Show the factor-listener buffer, starting the process if needed."
  (interactive)
  (let ((buf (process-buffer (factor--listener-process t)))
        (pop-up-windows factor-listener-window-allow-split))
    (if factor-listener-use-other-window
        (pop-to-buffer buf)
      (switch-to-buffer buf))))

(defun factor-telnet-to-port (port)
  (interactive "nPort: ")
  (switch-to-buffer
   (make-comint-in-buffer "factor-telnet" nil (cons "localhost" port))))

(defun factor-telnet ()
  (interactive)
  (factor-telnet-to-port 9000))

(defun factor-telnet-factory ()
  (interactive)
  (factor-telnet-to-port 9010))


;;; Factor listener interaction:

(defun factor--listener-send-cmd (cmd)
  (let ((proc (factor--listener-process)))
    (when proc
      (let* ((out (get-buffer-create "*factor messages*"))
             (beg (with-current-buffer out (goto-char (point-max)))))
        (comint-redirect-send-command-to-process cmd out proc nil t)
        (with-current-buffer factor--listener-buffer
          (while (not comint-redirect-completed) (sleep-for 0 1)))
        (with-current-buffer out
          (split-string (buffer-substring-no-properties beg (point-max))
                        "[\"\f\n\r\v]+" t))))))

;;;;; Current vocabulary:
(make-variable-buffer-local
 (defvar factor--current-vocab nil
   "Current vocabulary."))

(defconst factor--regexp-current-vocab "^IN: +\\([^ \r\n\f]+\\)")

(defun factor--current-buffer-vocab ()
  (save-excursion
    (when (or (re-search-backward factor--regexp-current-vocab nil t)
              (re-search-forward factor--regexp-current-vocab nil t))
      (setq factor--current-vocab (match-string-no-properties 1)))))

(defun factor--current-listener-vocab ()
  (car (factor--listener-send-cmd "USING: parser ; in get .")))


(defun factor--set-current-listener-vocab (&optional vocab)
  (factor--listener-send-cmd
   (format "IN: %s" (or vocab (factor--current-buffer-vocab))))
  t)

(defmacro factor--with-vocab (vocab &rest body)
  (let ((current (make-symbol "current")))
    `(let ((,current (factor--current-listener-vocab)))
       (factor--set-current-listener-vocab ,vocab)
       (prog1 (condition-case nil (progn . ,body) (error nil))
         (factor--set-current-listener-vocab ,current)))))

(put 'factor--with-vocab 'lisp-indent-function 1)

;;;;; Synchronous interaction:

(defsubst factor--listener-vocab-cmds (cmds &optional vocab)
  (factor--with-vocab vocab
    (mapcar #'factor--listener-send-cmd cmds)))

(defsubst factor--listener-vocab-cmd (cmd &optional vocab)
  (factor--with-vocab vocab
    (factor--listener-send-cmd cmd)))

;;;;; Interface: see

(defconst factor--regex-error-marker "^Type :help for debugging")
(defconst factor--regex-data-stack "^--- Data stack:")

(defun factor--prune-ans-strings (ans)
  (nreverse
   (catch 'done
     (let ((res))
       (dolist (a ans res)
         (cond ((string-match factor--regex-stack-effect a)
                (throw 'done (cons a res)))
               ((string-match factor--regex-data-stack a)
                (throw 'done res))
               ((string-match factor--regex-error-marker a)
                (throw 'done nil))
               (t (push a res))))))))

(defun factor--see-ans-to-string (ans)
  (let ((s (mapconcat #'identity (factor--prune-ans-strings ans) " "))
        (font-lock-verbose nil))
    (and (> (length s) 0)
         (with-temp-buffer
           (insert s)
           (factor-mode)
           (font-lock-fontify-buffer)
           (buffer-string)))))

(defun factor--see-current-word (&optional word)
  (let ((word (or word (factor--symbol-at-point))))
    (when word
      (let ((answer (factor--listener-send-cmd (format "\\ %s see" word))))
        (and answer (factor--see-ans-to-string answer))))))

(defalias 'factor--eldoc 'factor--see-current-word)

(defun factor-see-current-word (&optional word)
  "Echo in the minibuffer information about word at point."
  (interactive)
  (unless (factor--listener-process)
    (error "No factor listener running. Try M-x run-factor"))
  (let ((word (or word (factor--symbol-at-point)))
        (msg (factor--see-current-word word)))
    (if msg (message "%s" msg)
      (if word (message "No help found for '%s'" word)
        (message "No word at point")))))

;;; to fix:
(defun factor-run-file ()
  (interactive)
  (when (and (buffer-modified-p)
             (y-or-n-p (format "Save file %s? " (buffer-file-name))))
    (save-buffer))
  (when factor-display-compilation-output
    (factor-display-output-buffer))
  (comint-send-string "*factor*" (format "\"%s\"" (buffer-file-name)))
  (comint-send-string "*factor*" " run-file\n"))

(defun factor-display-output-buffer ()
  (with-current-buffer "*factor*"
    (goto-char (point-max))
    (unless (get-buffer-window (current-buffer) t)
      (display-buffer (current-buffer) t))))

(defun factor-send-string (str)
  (let ((n (length (split-string str "\n"))))
    (save-excursion
      (set-buffer "*factor*")
      (goto-char (point-max))
      (if (> n 1) (newline))
      (insert str)
      (comint-send-input))))

(defun factor-send-region (start end)
  (interactive "r")
  (let ((str (buffer-substring start end))
        (n   (count-lines      start end)))
    (save-excursion
      (set-buffer "*factor*")
      (goto-char (point-max))
      (if (> n 1) (newline))
      (insert str)
      (comint-send-input))))

(defun factor-send-definition ()
  (interactive)
  (factor-send-region (search-backward ":")
                      (search-forward  ";")))

(defun factor-edit ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " edit\n"))

(defun factor-clear ()
  (interactive)
  (factor-send-string "clear"))

(defun factor-comment-line ()
  (interactive)
  (beginning-of-line)
  (insert "! "))


;;;; Factor help mode:

(defvar factor-help-mode-map (make-sparse-keymap)
  "Keymap for Factor help mode.")

(defconst factor--help-headlines
  (regexp-opt '("Definition"
                "Examples"
                "Generic word contract"
                "Inputs and outputs"
                "Parent topics:"
                "See also"
                "Syntax"
                "Vocabulary"
                "Warning"
                "Word description")
              t))

(defconst factor--help-headlines-regexp (format "^%s" factor--help-headlines))

(defconst factor--help-font-lock-keywords
  `((,factor--help-headlines-regexp . 'factor-font-lock-help-mode-headlines)
    ,@factor--font-lock-keywords))

(defun factor-help-mode ()
  "Major mode for displaying Factor help messages.
\\{factor-help-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map factor-help-mode-map)
  (setq mode-name "Factor Help")
  (setq major-mode 'factor-help-mode)
  (set (make-local-variable 'font-lock-defaults)
       '(factor--help-font-lock-keywords t nil nil nil))
  (set (make-local-variable 'comint-redirect-subvert-readonly) t)
  (set (make-local-variable 'comint-redirect-echo-input) nil)
  (set (make-local-variable 'view-no-disable-on-exit) t)
  (view-mode)
  (setq view-exit-action
        (lambda (buffer)
          ;; Use `with-current-buffer' to make sure that `bury-buffer'
          ;; also removes BUFFER from the selected window.
          (with-current-buffer buffer
            (bury-buffer))))
  (run-mode-hooks 'factor-help-mode-hook))

(defun factor--listener-help-buffer ()
  (with-current-buffer (get-buffer-create "*factor-help*")
    (let ((inhibit-read-only t)) (erase-buffer))
    (factor-help-mode)
    (current-buffer)))

(defvar factor--help-history nil)

(defun factor--listener-show-help (&optional see)
  (unless (factor--listener-process)
    (error "No running factor listener. Try M-x run-factor"))
  (let* ((def (factor--symbol-at-point))
         (prompt (format "See%s help on%s: " (if see " short" "")
                         (if def (format " (%s)" def) "")))
         (ask (or (not (eq major-mode 'factor-mode))
                  (not def)
                  factor-help-always-ask))
         (cmd (format "\\ %s %s"
                      (if ask (read-string prompt nil 'factor--help-history def) def)
                      (if see "see" "help")))
         (hb (factor--listener-help-buffer))
         (proc (factor--listener-process)))
    (comint-redirect-send-command-to-process cmd hb proc nil)
    (pop-to-buffer hb)
    (beginning-of-buffer hb)))

;;;; Interface: see/help commands

(defun factor-see (&optional arg)
  "See a help summary of symbol at point.
By default, the information is shown in the minibuffer. When
called with a prefix argument, the information is displayed in a
separate help buffer."
  (interactive "P")
  (if (if factor-help-use-minibuffer (not arg) arg)
      (factor-see-current-word)
    (factor--listener-show-help t)))

(defun factor-help ()
  "Show extended help about the symbol at point, using a help
buffer."
  (interactive)
  (factor--listener-show-help))



(defun factor-refresh-all ()
  "Reload source files and documentation for all loaded
vocabularies which have been modified on disk."
  (interactive)
  (comint-send-string "*factor*" "refresh-all\n"))


;;; Key bindings:

(defun factor--define-key (key cmd &optional both)
  (let ((ms (list factor-mode-map)))
    (when both (push factor-help-mode-map ms))
    (dolist (m ms)
      (define-key m (vector '(control ?c) key) cmd)
      (define-key m (vector '(control ?c) `(control ,key)) cmd))))

(factor--define-key ?f 'factor-run-file)
(factor--define-key ?r 'factor-send-region)
(factor--define-key ?d 'factor-send-definition)
(factor--define-key ?s 'factor-see t)
(factor--define-key ?e 'factor-edit)
(factor--define-key ?z 'switch-to-factor t)
(factor--define-key ?c 'comment-region)

(define-key factor-mode-map "\C-ch" 'factor-help)
(define-key factor-help-mode-map "\C-ch" 'factor-help)
(define-key factor-mode-map "\C-m" 'newline-and-indent)

(define-key factor-listener-mode-map [f8] 'factor-refresh-all)



(provide 'factor)
;;; factor.el ends here
