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

;; BUG: A double quote character on a commented line will break the
;; syntax highlighting for that line.

(defgroup factor nil
  "Factor mode"
  :group 'languages)

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

(defconst factor-font-lock-keywords
  '(("#!.*$" . font-lock-comment-face)
    ("!( .* )" . font-lock-comment-face)
    ("^!.*$" . font-lock-comment-face)
    (" !.*$" . font-lock-comment-face)
    ("( .* )" . font-lock-comment-face)
    "MAIN:"
    "IN:" "USING:" "TUPLE:" "^C:" "^M:" "USE:" "REQUIRE:" "PROVIDE:"
    "REQUIRES:"
    "GENERIC:" "GENERIC#" "SYMBOL:" "PREDICATE:" "VAR:" "VARS:"
    "UNION:" "<PRIVATE" "PRIVATE>" "MACRO:" "MACRO::" "DEFER:"))

(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language."
  (interactive)
  (kill-all-local-variables)
  (use-local-map factor-mode-map)
  (setq major-mode 'factor-mode)
  (setq mode-name "Factor")
  (make-local-variable 'comment-start)
  (setq comment-start "! ")
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults
	'(factor-font-lock-keywords nil nil nil nil))
  (set-syntax-table factor-mode-syntax-table)
  (run-hooks 'factor-mode-hooks))

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'comint)

(defvar factor-binary "/scratch/repos/Factor/factor")
(defvar factor-image "/scratch/repos/Factor/factor.image")

(defun run-factor ()
  (interactive)
  (switch-to-buffer
   (make-comint-in-buffer "factor" nil factor-binary nil
			  (concat "-i=" factor-image)
			  "-run=listener")))

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
  (comint-send-string "*factor*" (format "\"%s\"" (buffer-file-name)))
  (comint-send-string "*factor*" " run-file\n"))

(defun factor-send-region (start end)
  (interactive "r")
  (comint-send-region "*factor*" start end)
  (comint-send-string "*factor*" "\n"))

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
  
(defun factor-comment-line ()
  (interactive)
  (beginning-of-line)
  (insert "! "))


(define-key factor-mode-map "\C-c\C-f" 'factor-run-file)
(define-key factor-mode-map "\C-c\C-r" 'factor-send-region)
(define-key factor-mode-map "\C-c\C-s" 'factor-see)
(define-key factor-mode-map "\C-ce" 'factor-edit)
(define-key factor-mode-map "\C-c\C-h" 'factor-help)
