;;; fuel-help.el -- accessing Factor's help system

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Wed Dec 03, 2008 21:41

;;; Comentary:

;; Modes and functions interfacing Factor's 'see' and 'help'
;; utilities, as well as an ElDoc-based autodoc mode.

;;; Code:

(require 'fuel-eval)
(require 'fuel-markup)
(require 'fuel-autodoc)
(require 'fuel-xref)
(require 'fuel-completion)
(require 'fuel-font-lock)
(require 'fuel-popup)
(require 'fuel-base)

(require 'button)


;;; Customization:

(defgroup fuel-help nil
  "Options controlling FUEL's help system."
  :group 'fuel)

(defcustom fuel-help-always-ask t
  "When enabled, always ask for confirmation in help prompts."
  :type 'boolean
  :group 'fuel-help)

(defcustom fuel-help-history-cache-size 50
  "Maximum number of pages to keep in the help browser cache."
  :type 'integer
  :group 'fuel-help)


;;; Help browser history:

(defun fuel-help--make-history ()
  (list nil                                        ; current
        (make-ring fuel-help-history-cache-size)   ; previous
        (make-ring fuel-help-history-cache-size))) ; next

(defvar fuel-help--history (fuel-help--make-history))
(defvar fuel-help--cache (make-hash-table :weakness 'key))

(defsubst fuel-help--cache-get (name)
  (gethash name fuel-help--cache))

(defsubst fuel-help--cache-insert (name str)
  (puthash name str fuel-help--cache))

(defsubst fuel-help--cache-clear ()
  (clrhash fuel-help--cache))

(defun fuel-help--history-push (term)
  (when (and (car fuel-help--history)
             (not (string= (car fuel-help--history) term)))
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

(defun fuel-help--history-current-content ()
  (fuel-help--cache-get (car fuel-help--history)))


;;; Fuel help buffer and internals:

(fuel-popup--define fuel-help--buffer
  "*fuel help*" 'fuel-help-mode)


(defvar fuel-help--prompt-history nil)

(defun fuel-help--read-word (see)
  (let* ((def (fuel-syntax-symbol-at-point))
         (prompt (format "See%s help on%s: " (if see " short" "")
                         (if def (format " (%s)" def) "")))
         (ask (or (not (memq major-mode '(factor-mode fuel-help-mode)))
                  (not def)
                  fuel-help-always-ask)))
    (if ask (fuel-completion--read-word prompt
                                        def
                                        'fuel-help--prompt-history
                                        t)
      def)))

(defun fuel-help--word-help (&optional see word)
  (let* ((def (or word (fuel-help--read-word see)))
         (cached (fuel-help--cache-get def)))
    (if cached
        (fuel-help--insert-contents def cached)
      (when def
        (let ((cmd `(:fuel* (,def ,(if see 'fuel-word-see 'fuel-word-help))
                            "fuel" t)))
          (message "Looking up '%s' ..." def)
          (let* ((ret (fuel-eval--send/wait cmd 2000))
                 (res (fuel-eval--retort-result ret)))
            (if (not res)
                (message "No help for '%s'" def)
              (fuel-help--insert-contents def res))))))))

(defun fuel-help--get-article (name label)
  (let ((cached (fuel-help--cache-get name)))
    (if cached
        (fuel-help--insert-contents name cached)
      (message "Retrieving article ...")
      (let* ((cmd `(:fuel* ((,name fuel-get-article)) "fuel" t))
             (ret (fuel-eval--send/wait cmd 2000))
             (res (fuel-eval--retort-result ret)))
        (fuel-help--insert-contents name res)
        (message "")))))

(defun fuel-help--get-vocab (name)
  (let ((cached (fuel-help--cache-get name)))
    (if cached
        (fuel-help--insert-contents name cached)
      (message "Retrieving vocabulary help ...")
      (let* ((cmd `(:fuel* ((,name fuel-vocab-help)) "fuel" (,name)))
             (ret (fuel-eval--send/wait cmd 2000))
             (res (fuel-eval--retort-result ret)))
        (if (not res)
            (message "No help available for vocabulary %s" name)
          (fuel-help--insert-contents name res)
          (message ""))))))

(defun fuel-help--follow-link (label link type)
  (let ((fuel-help-always-ask nil))
    (cond ((eq type 'word) (fuel-help--word-help nil link))
          ((eq type 'article) (fuel-help--get-article link label))
          ((eq type 'vocab) (fuel-help--get-vocab link))
          (t (message (format "Links of type %s not yet implemented" type))))))

(defun fuel-help--insert-contents (def art &optional nopush)
  (let ((hb (fuel-help--buffer))
        (inhibit-read-only t)
        (font-lock-verbose nil))
    (set-buffer hb)
    (erase-buffer)
    (if (stringp art)
        (insert art)
      (fuel-markup--print art)
      (fuel-markup--insert-newline)
      (fuel-help--cache-insert def (buffer-string)))
    (unless nopush (fuel-help--history-push def))
    (set-buffer-modified-p nil)
    (fuel-popup--display)
    (goto-char (point-min))
    (message "")))


;;; Interactive help commands:

(defun fuel-help-short ()
  "See help summary of symbol at point."
  (interactive)
  (fuel-help--word-help t))

(defun fuel-help ()
  "Show extended help about the symbol at point, using a help
buffer."
  (interactive)
  (fuel-help--word-help))

(defun fuel-help-next ()
  "Go to next page in help browser."
  (interactive)
  (let ((item (fuel-help--history-next))
        (fuel-help-always-ask nil))
    (unless item
      (error "No next page"))
    (fuel-help--insert-contents item (fuel-help--cache-get item) t)))

(defun fuel-help-previous ()
  "Go to next page in help browser."
  (interactive)
  (let ((item (fuel-help--history-previous))
        (fuel-help-always-ask nil))
    (unless item
      (error "No previous page"))
    (fuel-help--insert-contents item (fuel-help--cache-get item) t)))

(defun fuel-help-clean-history ()
  "Clean up the help browser cache of visited pages."
  (interactive)
  (when (y-or-n-p "Clean browsing history? ")
    (fuel-help--cache-clear)
    (setq fuel-help--history (fuel-help--make-history)))
  (message ""))


;;;; Help mode map:

(defvar fuel-help-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (set-keymap-parent map button-buffer-map)
    (define-key map "a" 'fuel-apropos)
    (define-key map "b" 'fuel-help-previous)
    (define-key map "c" 'fuel-help-clean-history)
    (define-key map "f" 'fuel-help-next)
    (define-key map "h" 'fuel-help)
    (define-key map "l" 'fuel-help-previous)
    (define-key map "p" 'fuel-help-previous)
    (define-key map "n" 'fuel-help-next)
    (define-key map (kbd "SPC")  'scroll-up)
    (define-key map (kbd "S-SPC") 'scroll-down)
    (define-key map "\M-." 'fuel-edit-word-at-point)
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
  (set-syntax-table fuel-syntax--syntax-table)
  (setq mode-name "FUEL Help")
  (setq major-mode 'fuel-help-mode)

  (setq fuel-markup--follow-link-function 'fuel-help--follow-link)

  (setq fuel-autodoc-mode-string "")
  (fuel-autodoc-mode)

  (setq buffer-read-only t))


(provide 'fuel-help)
;;; fuel-help.el ends here
