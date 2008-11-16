;; Eduardo Cavazos - wayo.cavazos@gmail.com

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add these lines to your .emacs file:

;; (load-file "/scratch/repos/Factor/misc/factor.el")
;; (setq factor-binary "/scratch/repos/Factor/factor")
;; (setq factor-image "/scratch/repos/Factor/factor.image")

;; Of course, you'll have to edit the directory paths for your system
;; accordingly.

;; That's all you have to do to "install" factor.el on your
;; system. Whenever you edit a factor file, Emacs will know to switch
;; to Factor mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; M-x run-factor === Start a Factor listener inside Emacs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup factor nil
  "Factor mode"
  :group 'languages)

(defvar factor-mode-syntax-table nil
  "Syntax table used while in Factor mode.")

(defcustom factor-display-compilation-output t
  "Display the REPL buffer before compiling files."
  :type '(choice (const :tag "Enable" t) (const :tag "Disable" nil))
  :group 'factor)


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
    (modify-syntax-entry ?\n ">" factor-mode-syntax-table)
    (modify-syntax-entry ?\f " " factor-mode-syntax-table)
    (modify-syntax-entry ?\r " " factor-mode-syntax-table)
    (modify-syntax-entry ?  " " factor-mode-syntax-table)

    (modify-syntax-entry ?\[ "(]  " factor-mode-syntax-table)
    (modify-syntax-entry ?\] ")[  " factor-mode-syntax-table)
    (modify-syntax-entry ?{ "(}  " factor-mode-syntax-table)
    (modify-syntax-entry ?} "){  " factor-mode-syntax-table)

    (modify-syntax-entry ?\( "()" factor-mode-syntax-table)
    (modify-syntax-entry ?\) ")(" factor-mode-syntax-table)
    (modify-syntax-entry ?\" "\"    " factor-mode-syntax-table)))

(defvar factor-mode-map (make-sparse-keymap))

(defcustom factor-mode-hook nil
  "Hook run when entering Factor mode."
  :type 'hook
  :group 'factor)

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
  (regexp-opt '("B" "call-next-method" "delimiter" "f" "flushable" "foldable"
                "initial:" "inline" "parsing" "read-only" "recursive")
              'words))

(defun factor--regex-second-word (prefixes)
  (format "^%s +\\([^ ]+\\)" (regexp-opt prefixes t)))

(defconst factor--regex-word-definition
  (factor--regex-second-word '(":" "::" "M:" "GENERIC:")))

(defconst factor--regex-type-definition
  (factor--regex-second-word '("TUPLE:")))

(defconst factor--regex-const-definition
  (factor--regex-second-word '("SYMBOL:")))

(defconst factor--regex-using-line "^USING: +\\([^;]*\\);")
(defconst factor--regex-use-line "^USE: +\\(.*\\)$")

(defconst factor-font-lock-keywords
  `(("#!.*$" . font-lock-comment-face)
    ("!( .* )" . font-lock-comment-face)
    ("^!.*$" . font-lock-comment-face)
    (" !.*$" . font-lock-comment-face)
    ("( .* )" . font-lock-comment-face)
    ("\"\\(\\\\\"\\|[^\"]\\)*\"" . font-lock-string-face)
    ("\\(P\\|SBUF\\)\"" 1 font-lock-keyword-face)
    ,@(mapcar #'(lambda (w) (cons (concat "\\(^\\| \\)\\(" w "\\)\\($\\| \\)")
                             '(2 font-lock-keyword-face)))
              factor--parsing-words)
    (,factor--regex-parsing-words-ext . font-lock-keyword-face)
    (,factor--regex-word-definition 2 font-lock-function-name-face)
    (,factor--regex-type-definition 2 font-lock-type-face)
    (,factor--regex-const-definition 2 font-lock-constant-face)
    (,factor--regex-using-line 1 font-lock-constant-face)
    (,factor--regex-use-line 1 font-lock-constant-face)))

(defun factor-indent-line ()
  "Indent current line as Factor code"
  (indent-line-to (+ (current-indentation) 4)))

(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language.
\\{factor-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map factor-mode-map)
  (setq major-mode 'factor-mode)
  (setq mode-name "Factor")
  (set (make-local-variable 'indent-line-function) #'factor-indent-line)
  (make-local-variable 'comment-start)
  (setq comment-start "! ")
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
	'(factor-font-lock-keywords t nil nil nil))
  (set-syntax-table factor-mode-syntax-table)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'factor-indent-line)
  (run-hooks 'factor-mode-hook))

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'comint)

(defvar factor-binary "~/factor/factor")
(defvar factor-image "~/factor/factor.image")

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

;; (defun factor-send-region (start end)
;;   (interactive "r")
;;   (comint-send-region "*factor*" start end)
;;   (comint-send-string "*factor*" "\n"))

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

(defun factor-see ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " see\n"))

(defun factor-help ()
  (interactive)
  (comint-send-string "*factor*" "\\ ")
  (comint-send-string "*factor*" (thing-at-point 'sexp))
  (comint-send-string "*factor*" " help\n"))

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

(define-key factor-mode-map "\C-c\C-f" 'factor-run-file)
(define-key factor-mode-map "\C-c\C-r" 'factor-send-region)
(define-key factor-mode-map "\C-c\C-d" 'factor-send-definition)
(define-key factor-mode-map "\C-c\C-s" 'factor-see)
(define-key factor-mode-map "\C-ce"    'factor-edit)
(define-key factor-mode-map "\C-c\C-h" 'factor-help)
(define-key factor-mode-map "\C-cc"    'comment-region)
(define-key factor-mode-map [return]   'newline-and-indent)
(define-key factor-mode-map [tab]      'indent-for-tab-command)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; indentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst factor-word-starting-keywords
  '("" ":" "TUPLE" "MACRO" "MACRO:" "M"))

(defmacro factor-word-start-re (keywords)
  `(format
    "^\\(%s\\): "
    (mapconcat 'identity ,keywords "\\|")))

(defun factor-calculate-indentation ()
  "Calculate Factor indentation for line at point."
  (let ((not-indented t)
        (cur-indent 0))
    (save-excursion
      (beginning-of-line)
      (if (bobp)
          (setq cur-indent 0)
        (save-excursion
          (while not-indented
            ;; Check that we are inside open brackets
            (save-excursion
              (let ((cur-depth (factor-brackets-depth)))
                (forward-line -1)
                (setq cur-indent (+ (current-indentation)
                                    (* default-tab-width
                                       (- cur-depth (factor-brackets-depth)))))
                (setq not-indented nil)))
            (forward-line -1)
              ;; Check that we are after the end of previous word
              (if (looking-at ".*;[ \t]*$")
                  (progn
                    (setq cur-indent (- (current-indentation) default-tab-width))
                    (setq not-indented nil))
                ;; Check that we are after the start of word
                (if (looking-at (factor-word-start-re factor-word-starting-keywords))
;                (if (looking-at "^[A-Z:]*: ")
                    (progn
                      (message "inword")
                      (setq cur-indent (+ (current-indentation) default-tab-width))
                      (setq not-indented nil))
                  (if (bobp)
                      (setq not-indented nil))))))))
    cur-indent))

(defun factor-brackets-depth ()
  "Returns number of brackets, not closed on previous lines."
  (syntax-ppss-depth
   (save-excursion
     (syntax-ppss (line-beginning-position)))))

(defun factor-indent-line ()
  "Indent current line as Factor code"
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; factor-listener-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-derived-mode factor-listener-mode comint-mode "Factor Listener")

(define-key factor-listener-mode-map [f8] 'factor-refresh-all)

(defun run-factor ()
  (interactive)
  (switch-to-buffer
   (make-comint-in-buffer "factor" nil (expand-file-name factor-binary) nil
			  (concat "-i=" (expand-file-name factor-image))
			  "-run=listener"))
  (factor-listener-mode))

(defun factor-refresh-all ()
  (interactive)
  (comint-send-string "*factor*" "refresh-all\n"))
