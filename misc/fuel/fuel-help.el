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

(require 'fuel-eval)
(require 'fuel-autodoc)
(require 'fuel-completion)
(require 'fuel-font-lock)
(require 'fuel-popup)
(require 'fuel-base)


;;; Customization:

(defgroup fuel-help nil
  "Options controlling FUEL's help system"
  :group 'fuel)

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


;;; Help browser history:

(defvar fuel-help--history
  (list nil                                        ; current
        (make-ring fuel-help-history-cache-size)   ; previous
        (make-ring fuel-help-history-cache-size))) ; next

(defun fuel-help--history-push (term)
  (when (and (car fuel-help--history)
             (not (string= (caar fuel-help--history) (car term))))
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

(fuel-popup--define fuel-help--buffer
  "*fuel help*" 'fuel-help-mode)


(defvar fuel-help--prompt-history nil)

(defun fuel-help--show-help (&optional see word)
  (let* ((def (or word (fuel-syntax-symbol-at-point)))
         (prompt (format "See%s help on%s: " (if see " short" "")
                         (if def (format " (%s)" def) "")))
         (ask (or (not (memq major-mode '(factor-mode fuel-help-mode)))
                  (not def)
                  fuel-help-always-ask))
         (def (if ask (fuel-completion--read-word prompt
                                                  def
                                                  'fuel-help--prompt-history
                                                  t)
                def))
         (cmd `(:fuel* ((:quote ,def) ,(if see 'see 'help)) t)))
    (message "Looking up '%s' ..." def)
    (fuel-eval--send cmd `(lambda (r) (fuel-help--show-help-cont ,def r)))))

(defun fuel-help--show-help-cont (def ret)
  (let ((out (fuel-eval--retort-output ret)))
    (if (or (fuel-eval--retort-error ret) (empty-string-p out))
        (message "No help for '%s'" def)
      (fuel-help--insert-contents def out))))

(defun fuel-help--insert-contents (def str &optional nopush)
  (let ((hb (fuel-help--buffer))
        (inhibit-read-only t)
        (font-lock-verbose nil))
    (set-buffer hb)
    (erase-buffer)
    (insert str)
    (unless nopush
      (goto-char (point-min))
      (when (re-search-forward (format "^%s" def) nil t)
        (beginning-of-line)
        (kill-region (point-min) (point))
        (fuel-help--history-push (cons def (buffer-string)))))
    (set-buffer-modified-p nil)
    (fuel-popup--display)
    (goto-char (point-min))
    (message "%s" def)))


;;; Help mode font lock:

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

(defun fuel-help-next-headline (&optional count)
  (interactive "P")
  (end-of-line)
  (when (re-search-forward fuel-help--headlines-regexp nil t (or count 1))
    (beginning-of-line)))

(defun fuel-help-previous-headline (&optional count)
  (interactive "P")
  (re-search-backward fuel-help--headlines-regexp nil t count))


;;;; Help mode map:

(defvar fuel-help-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (define-key map "\C-m" 'fuel-help)
    (define-key map "b" 'fuel-help-previous)
    (define-key map "f" 'fuel-help-next)
    (define-key map "l" 'fuel-help-previous)
    (define-key map "p" 'fuel-help-previous)
    (define-key map "n" 'fuel-help-next)
    (define-key map (kbd "TAB") 'fuel-help-next-headline)
    (define-key map (kbd "S-TAB") 'fuel-help-previous-headline)
    (define-key map [(backtab)] 'fuel-help-previous-headline)
    (define-key map (kbd "SPC")  'scroll-up)
    (define-key map (kbd "S-SPC") 'scroll-down)
    (define-key map "\C-cz" 'run-factor)
    (define-key map "\C-c\C-z" 'run-factor)
    map))


;;; Help mode definition:

(defun fuel-help-mode ()
  "Major mode for browsing Factor documentation.
\\{fuel-help-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (buffer-disable-undo)
  (use-local-map fuel-help-mode-map)
  (setq mode-name "FUEL Help")
  (setq major-mode 'fuel-help-mode)

  (fuel-font-lock--font-lock-setup fuel-help--font-lock-keywords t)

  (setq fuel-autodoc-mode-string "")
  (fuel-autodoc-mode)

  (run-mode-hooks 'fuel-help-mode-hook)

  (setq buffer-read-only t))


(provide 'fuel-help)
;;; fuel-help.el ends here
