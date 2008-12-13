;;; fuel-help.el -- accessing Factor's help system

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Wed Dec 03, 2008 21:41

;;; Comentary:

;; Modes and functions interfacing Factor's 'see' and 'help'
;; utilities, as well as an ElDoc-based autodoc mode.

;;; Code:

(require 'fuel-base)
(require 'fuel-font-lock)
(require 'fuel-eval)


;;; Customization:

(defgroup fuel-help nil
  "Options controlling FUEL's help system"
  :group 'fuel)

(defcustom fuel-help-minibuffer-font-lock t
  "Whether to use font lock for info messages in the minibuffer."
  :group 'fuel-help
  :type 'boolean)

(defcustom fuel-help-always-ask t
  "When enabled, always ask for confirmation in help prompts."
  :type 'boolean
  :group 'fuel-help)

(defcustom fuel-help-use-minibuffer t
  "When enabled, use the minibuffer for short help messages."
  :type 'boolean
  :group 'fuel-help)

(defcustom fuel-help-mode-hook nil
  "Hook run by `factor-help-mode'."
  :type 'hook
  :group 'fuel-help)

(defcustom fuel-help-history-cache-size 50
  "Maximum number of pages to keep in the help browser cache."
  :type 'integer
  :group 'fuel-help)

(defface fuel-help-font-lock-headlines '((t (:bold t :weight bold)))
  "Face for headlines in help buffers."
  :group 'fuel-help
  :group 'faces)


;;; Autodoc mode:

(defvar fuel-help--font-lock-buffer
  (let ((buffer (get-buffer-create " *fuel help minibuffer messages*")))
    (set-buffer buffer)
    (fuel-font-lock--font-lock-setup)
    buffer))

(defun fuel-help--font-lock-str (str)
  (set-buffer fuel-help--font-lock-buffer)
  (erase-buffer)
  (insert str)
  (let ((font-lock-verbose nil)) (font-lock-fontify-buffer))
  (buffer-string))

(defun fuel-help--word-synopsis (&optional word)
  (let ((word (or word (fuel-syntax-symbol-at-point)))
        (fuel-eval--log t))
    (when word
      (let* ((str (format "\\ %s synopsis fuel-eval-set-result" word))
             (cmd (fuel-eval--cmd/string str t t))
             (ret (fuel-eval--send/wait cmd 20)))
        (when (and ret (not (fuel-eval--retort-error ret)))
          (if fuel-help-minibuffer-font-lock
              (fuel-help--font-lock-str (fuel-eval--retort-result ret))
            (fuel-eval--retort-result ret)))))))

(make-variable-buffer-local
 (defvar fuel-autodoc-mode-string " A"
   "Modeline indicator for fuel-autodoc-mode"))

(define-minor-mode fuel-autodoc-mode
  "Toggle Fuel's Autodoc mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Autodoc mode is enabled, a synopsis of the word at point is
displayed in the minibuffer."
  :init-value nil
  :lighter fuel-autodoc-mode-string
  :group 'fuel

  (set (make-local-variable 'eldoc-documentation-function)
       (when fuel-autodoc-mode 'fuel-help--word-synopsis))
  (set (make-local-variable 'eldoc-minor-mode-string) nil)
  (eldoc-mode fuel-autodoc-mode)
  (message "Fuel Autodoc %s" (if fuel-autodoc-mode "enabled" "disabled")))


;;; Help browser history:

(defvar fuel-help--history
  (list nil
        (make-ring fuel-help-history-cache-size)
        (make-ring fuel-help-history-cache-size)))

(defvar fuel-help--history-idx 0)

(defun fuel-help--history-push (term)
  (when (car fuel-help--history)
    (ring-insert (nth 1 fuel-help--history) (car fuel-help--history)))
  (setcar fuel-help--history term))

(defun fuel-help--history-next ()
  (when (not (ring-empty-p (nth 2 fuel-help--history)))
    (when (car fuel-help--history)
      (ring-insert (nth 1 fuel-help--history) (car fuel-help--history)))
    (setcar fuel-help--history (ring-remove (nth 2 fuel-help--history) 0))))

(defun fuel-help--history-previous ()
  (when (not (ring-empty-p (nth 1 fuel-help--history)))
    (when (car fuel-help--history)
      (ring-insert (nth 2 fuel-help--history) (car fuel-help--history)))
    (setcar fuel-help--history (ring-remove (nth 1 fuel-help--history) 0))))


;;; Fuel help buffer and internals:

(defun fuel-help--help-buffer ()
  (with-current-buffer (get-buffer-create "*fuel-help*")
    (fuel-help-mode)
    (current-buffer)))

(defvar fuel-help--prompt-history nil)

(defun fuel-help--show-help (&optional see word)
  (let* ((def (or word (fuel-syntax-symbol-at-point)))
         (prompt (format "See%s help on%s: " (if see " short" "")
                         (if def (format " (%s)" def) "")))
         (ask (or (not (memq major-mode '(factor-mode fuel-help-mode)))
                  (not def)
                  fuel-help-always-ask))
         (def (if ask (read-string prompt nil 'fuel-help--prompt-history def)
                def))
         (cmd (format "\\ %s %s" def (if see "see" "help"))))
    (message "Looking up '%s' ..." def)
    (fuel-eval--send (fuel-eval--cmd/string cmd t t)
                     `(lambda (r) (fuel-help--show-help-cont ,def r)))))

(defun fuel-help--show-help-cont (def ret)
  (let ((out (fuel-eval--retort-output ret)))
    (if (or (fuel-eval--retort-error ret) (empty-string-p out))
        (message "No help for '%s'" def)
      (fuel-help--insert-contents def out))))

(defun fuel-help--insert-contents (def str &optional nopush)
  (let ((hb (fuel-help--help-buffer))
        (inhibit-read-only t)
        (font-lock-verbose nil))
    (set-buffer hb)
    (erase-buffer)
    (insert str)
    (goto-char (point-min))
    (when (re-search-forward (format "^%s" def) nil t)
      (beginning-of-line)
      (kill-region (point-min) (point))
      (next-line)
      (open-line 1))
    (set-buffer-modified-p nil)
    (unless nopush (fuel-help--history-push (cons def str)))
    (pop-to-buffer hb)
    (goto-char (point-min))
    (message "%s" def)))


;;; Interactive help commands:

(defun fuel-help-short (&optional arg)
  "See a help summary of symbol at point.
By default, the information is shown in the minibuffer. When
called with a prefix argument, the information is displayed in a
separate help buffer."
  (interactive "P")
  (if (if fuel-help-use-minibuffer (not arg) arg)
      (fuel-help--word-synopsis)
    (fuel-help--show-help t)))

(defun fuel-help ()
  "Show extended help about the symbol at point, using a help
buffer."
  (interactive)
  (fuel-help--show-help))

(defun fuel-help-next ()
  "Go to next page in help browser."
  (interactive)
  (let ((item (fuel-help--history-next))
        (fuel-help-always-ask nil))
    (unless item
      (error "No next page"))
    (fuel-help--insert-contents (car item) (cdr item) t)))

(defun fuel-help-previous ()
  "Go to next page in help browser."
  (interactive)
  (let ((item (fuel-help--history-previous))
        (fuel-help-always-ask nil))
    (unless item
      (error "No previous page"))
    (fuel-help--insert-contents (car item) (cdr item) t)))


;;;; Factor help mode:

(defvar fuel-help-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-m" 'fuel-help)
    (define-key map "q" 'bury-buffer)
    (define-key map "b" 'fuel-help-previous)
    (define-key map "f" 'fuel-help-next)
    (define-key map (kbd "SPC")  'scroll-up)
    (define-key map (kbd "S-SPC") 'scroll-down)
    map))

(defconst fuel-help--headlines
  (regexp-opt '("Class description"
                "Definition"
                "Errors"
                "Examples"
                "Generic word contract"
                "Inputs and outputs"
                "Methods"
                "Notes"
                "Parent topics:"
                "See also"
                "Syntax"
                "Variable description"
                "Variable value"
                "Vocabulary"
                "Warning"
                "Word description")
              t))

(defconst fuel-help--headlines-regexp (format "^%s" fuel-help--headlines))

(defconst fuel-help--font-lock-keywords
  `(,@fuel-font-lock--font-lock-keywords
    (,fuel-help--headlines-regexp . 'fuel-help-font-lock-headlines)))

(defun fuel-help-mode ()
  "Major mode for browsing Factor documentation.
\\{fuel-help-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map fuel-help-mode-map)
  (setq mode-name "Factor Help")
  (setq major-mode 'fuel-help-mode)

  (fuel-font-lock--font-lock-setup fuel-help--font-lock-keywords t)

  (setq fuel-autodoc-mode-string "")
  (fuel-autodoc-mode)

  (run-mode-hooks 'fuel-help-mode-hook)
  (toggle-read-only 1))


(provide 'fuel-help)
;;; fuel-help.el ends here
