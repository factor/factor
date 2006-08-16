
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
      (modify-syntax-entry i "_   ")
      (setq i (1+ i)))

    ;; Word components.
    (setq i ?0)
    (while (<= i ?9)
      (modify-syntax-entry i "w   ")
      (setq i (1+ i)))
    (setq i ?A)
    (while (<= i ?Z)
      (modify-syntax-entry i "w   ")
      (setq i (1+ i)))
    (setq i ?a)
    (while (<= i ?z)
      (modify-syntax-entry i "w   ")
      (setq i (1+ i)))

    ;; Whitespace
    (modify-syntax-entry ?\t " ")
    (modify-syntax-entry ?\n ">")
    (modify-syntax-entry ?\f " ")
    (modify-syntax-entry ?\r " ")
    (modify-syntax-entry ?  " ")

    (modify-syntax-entry ?\[ "(]  ")
    (modify-syntax-entry ?\] ")[  ")
    (modify-syntax-entry ?{ "(}  ")
    (modify-syntax-entry ?} "){  ")

    (modify-syntax-entry ?\( "()")
    (modify-syntax-entry ?\) ")(")
    (modify-syntax-entry ?\" "\"    ")))
    
(defcustom factor-mode-hook nil
  "Hook run when entering Factor mode."
  :type 'hook
  :group 'factor)

(defconst factor-font-lock-keywords
  '(("#!.*$" . font-lock-comment-face)
    ("!.*$" . font-lock-comment-face)
    ("( .* )" . font-lock-comment-face)
    "IN:" "USING:" "TUPLE:" "^C:" "^M:" "USE:" "REQUIRE:" "PROVIDE:"
    "GENERIC:" "SYMBOL:" "PREDICATE:"))

(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language."
  (interactive)
  (kill-all-local-variables)
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

(define-derived-mode factor-listener-mode comint-mode "Factor listener"
  (setq comint-prompt-regexp "ok "))

(defvar factor-binary "/scratch/factor-darcs/repos/Factor/f")
(defvar factor-image "/scratch/factor-darcs/repos/Factor/factor.image")

(defun factor-server ()
  (interactive)
  (make-comint "factor-server" factor-binary nil factor-image "-shell=tty")
  (comint-send-string "*factor-server*" "USE: jedit telnet\n"))

;; (defun factor-listener ()
;;   (interactive)
;;   (factor-server)
;;   (sleep-for 0 500)
;;   (switch-to-buffer (make-comint "factor-listener" '("localhost" . 9999)))
;;   (rename-uniquely)
;;   (factor-listener-mode))

(defun factor-listener ()
  (interactive)
  (factor-server)
  (sleep-for 0 1000)
  (if (get-buffer "*factor-listener*")
      (save-excursion
	(set-buffer "*factor-listener*")
	(rename-uniquely)))
  (switch-to-buffer (make-comint "factor-listener" '("localhost" . 9999)))
  (factor-listener-mode))

(defun factor-listener-restart ()
  (interactive)
  (factor-server)
  (sleep-for 0 1000)
  (make-comint-in-buffer
   "factor-listener" (current-buffer) '("localhost" . 9999)))

(defun load-factor-file (file-name)
  (interactive "fLoad Factor file: ")
  (comint-send-string nil (format "\"%s\" run-file\n" file-name)))

(defun factor-update-stack-buffer (&optional string)
  (interactive)
  (save-excursion
    (set-buffer (get-buffer-create "*factor-stack*"))
    (erase-buffer)
    (comint-redirect-send-command-to-process
     ".s" "*factor-stack*" "*factor-listener*" nil)))

(defvar factor-update-stackp nil "*")

(defun factor-send-input ()
  (interactive)
  (comint-send-input)
  (if factor-update-stackp
      (progn (sleep-for 0 250) (factor-update-stack-buffer))))

(defun factor-synopsis ()
  (interactive)
  (message
   (first
    (comint-redirect-results-list-from-process 
     (get-buffer-process "*factor-listener*")
     (format "\\ %s synopsis print" (thing-at-point 'symbol))
     ;; "[ ]*\\(.*\\)\n"
     "\\(.*\\)\n"
     1))))

(fset 'factor-comment-line "\C-a! ")