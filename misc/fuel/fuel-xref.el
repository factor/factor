;;; fuel-xref.el -- showing cross-reference info

;; Copyright (C) 2008, 2009, 2010 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 22:00

;;; Comentary:

;; A mode and utilities for showing cross-reference information.

;;; Code:

(require 'fuel-edit)
(require 'fuel-completion)
(require 'fuel-help)
(require 'fuel-eval)
(require 'fuel-popup)
(require 'fuel-menu)
(require 'fuel-base)
(require 'factor-mode)

(require 'button)


;;; Customization:

;;;###autoload
(defgroup fuel-xref nil
  "FUEL's cross-referencing engine."
  :group 'fuel)

(defcustom fuel-xref-follow-link-to-word-p t
  "Whether, when following a link to a caller, we position the
cursor at the first ocurrence of the used word."
  :group 'fuel-xref
  :type 'boolean)

(defcustom fuel-xref-follow-link-method nil
  "How new buffers are opened when following a crossref link."
  :group 'fuel-xref
  :type '(choice (const :tag "Other window" window)
                 (const :tag "Other frame" frame)
                 (const :tag "Current window" nil)))

(defface fuel-xref-link-face '((t (:inherit link)))
  "Highlighting links in cross-reference buffers."
  :group 'fuel-xref
  :group 'fuel-faces
  :group 'fuel)

(defface fuel-xref-vocab-face '((t))
  "Vocabulary names in cross-reference buffers."
  :group 'fuel-xref
  :group 'fuel-faces
  :group 'fuel)

(defvar-local fuel-xref--word nil)


;;; Buttons:

(define-button-type 'fuel-xref--button-type
  'action 'fuel-xref--follow-link
  'follow-link t
  'face 'fuel-xref-link-face)

(defun fuel-xref--follow-link (button)
  (let ((file (button-get button 'file))
        (line (button-get button 'line)))
    (when (not file)
      (error "No file for this ref"))
    (when (not (file-readable-p file))
      (error "File '%s' is not readable" file))
    (let ((word fuel-xref--word))
      (fuel-edit--visit-file file fuel-xref-follow-link-method)
      (when (numberp line)
        (goto-char (point-min))
        (forward-line (1- line)))
      (when (and word fuel-xref-follow-link-to-word-p)
        (and (re-search-forward (format "\\_<%s\\_>" word)
                                (factor-end-of-defun-pos)
                                t)
             (goto-char (match-beginning 0)))))))


;;; The xref buffer:

(defun fuel-xref--buffer ()
  (or (get-buffer "*fuel xref*")
      (with-current-buffer (get-buffer-create "*fuel xref*")
        (fuel-xref-mode)
        (fuel-popup-mode)
        (current-buffer))))

(defvar fuel-xref--help-string
  "(Press RET or click to follow crossrefs, or h for help on word at point)")

(defun fuel-xref--title (word cc count thing)
  (put-text-property 0 (length word) 'font-lock-face 'bold word)
  (cond ((zerop count) (format "No known %s %s %s" thing cc word))
        ((= 1 count) (format "1 %s %s %s:" thing cc word))
        (t (format "%s %ss %s %s:" count thing cc word))))

(defun fuel-xref--insert-ref (ref &optional no-vocab)
  (when (and (stringp (cl-first ref))
             (stringp (cl-third ref))
             (numberp (cl-fourth ref)))
    (insert "  ")
    (insert-text-button (cl-first ref)
                        :type 'fuel-xref--button-type
                        'help-echo (format "File: %s (%s)"
                                           (cl-third ref)
                                           (cl-fourth ref))
                        'file (cl-third ref)
                        'line (cl-fourth ref))
    (when (and (not no-vocab) (stringp (cl-second ref)))
      (insert (format " (in %s)" (cl-second ref))))
    (newline)
    t))

(defun fuel-xref--fill-buffer (word cc refs &optional no-vocab app thing)
  (let ((inhibit-read-only t)
        (count 0))
    (with-current-buffer (fuel-xref--buffer)
      (let ((start (if app (goto-char (point-max))
                     (erase-buffer)
                     (point-min))))
        (dolist (ref refs)
          (when (fuel-xref--insert-ref ref no-vocab) (setq count (1+ count))))
        (newline)
        (goto-char start)
        (save-excursion
          (insert (fuel-xref--title word cc count (or thing "word")) "\n\n"))
        count))))

(defun fuel-xref--fill-and-display (word cc refs &optional no-vocab thing)
  (let ((count (fuel-xref--fill-buffer word cc refs no-vocab nil (or thing "word"))))
    (if (zerop count)
        (error (fuel-xref--title word cc 0 (or thing "word")))
      (message "")
      (fuel-popup--display (fuel-xref--buffer)))))

(defun fuel-xref--callers (word)
  (let ((cmd `(:fuel* (((:quote ,word) fuel-callers-xref)))))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))

(defun fuel-xref--show-callers (word)
  (let ((refs (fuel-xref--callers word)))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word word))
    (fuel-xref--fill-and-display word "using" refs)))

(defun fuel-xref--word-callers-files (word)
  (mapcar 'cl-third (fuel-xref--callers word)))

(defun fuel-xref--show-callees (word)
  (let* ((cmd `(:fuel* (((:quote ,word) fuel-callees-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word nil))
    (fuel-xref--fill-and-display word "used by" res)))

(defun fuel-xref--apropos (str)
  (let* ((cmd `(:fuel* ((,str fuel-apropos-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word nil))
    (fuel-xref--fill-and-display str "containing" res)))

(defun fuel-xref--show-vocab (vocab &optional app)
  (let* ((cmd `(:fuel* ((,vocab fuel-vocab-xref)) ,vocab))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word nil))
    (fuel-xref--fill-buffer vocab "in vocabulary" res t app)))

(defun fuel-xref--show-vocab-words (vocab &optional private)
  (fuel-xref--show-vocab vocab)
  (when private
    (fuel-xref--show-vocab (format "%s.private" (substring-no-properties vocab))
                           t))
  (fuel-popup--display (fuel-xref--buffer))
  (goto-char (point-min)))

(defun fuel-xref--show-vocab-usage (vocab)
  (let* ((cmd `(:fuel* ((,vocab fuel-vocab-usage-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word nil))
    (fuel-xref--fill-and-display vocab "using" res t "vocab")))

(defun fuel-xref--show-vocab-uses (vocab)
  (let* ((cmd `(:fuel* ((,vocab fuel-vocab-uses-xref))))
         (res (fuel-eval--retort-result (fuel-eval--send/wait cmd))))
    (with-current-buffer (fuel-xref--buffer) (setq fuel-xref--word nil))
    (fuel-xref--fill-and-display vocab "used by" res t "vocab")))


;;; User commands:

(defvar fuel-xref--word-history nil)

(defun fuel-show-callers (&optional arg)
  "Show a list of callers of word or vocabulary at point.
With prefix argument, ask for word."
  (interactive "P")
  (let ((word (if arg (fuel-completion--read-word "Find callers for: "
                                                  (factor-symbol-at-point)
                                                  fuel-xref--word-history)
                (factor-symbol-at-point))))
    (when word
      (message "Looking up %s's users ..." word)
      (if (and (not arg)
               (fuel-edit--looking-at-vocab))
          (fuel-xref--show-vocab-usage word)
        (fuel-xref--show-callers word)))))

(defun fuel-show-callees (&optional arg)
  "Show a list of callers of word or vocabulary at point.
With prefix argument, ask for word."
  (interactive "P")
  (let ((word (if arg (fuel-completion--read-word "Find callees for: "
                                                  (factor-symbol-at-point)
                                                  fuel-xref--word-history)
                (factor-symbol-at-point))))
    (when word
      (message "Looking up %s's callees ..." word)
      (if (and (not arg)
               (fuel-edit--looking-at-vocab))
          (fuel-xref--show-vocab-uses word)
        (fuel-xref--show-callees word)))))

(defvar fuel-xref--vocab-history nil)

(defun fuel-vocab-uses (&optional arg)
  "Show a list of vocabularies used by a given one.
With prefix argument, force reload of vocabulary list."
  (interactive "P")
  (let ((vocab (fuel-completion--read-vocab arg
                                            (factor-symbol-at-point)
                                            fuel-xref--vocab-history)))
    (fuel-xref--show-vocab-uses vocab)))

(defun fuel-vocab-usage (&optional arg)
  "Show a list of vocabularies that use a given one.
With prefix argument, force reload of vocabulary list."
  (interactive "P")
  (let ((vocab (fuel-completion--read-vocab arg
                                            (factor-symbol-at-point)
                                            fuel-xref--vocab-history)))
    (fuel-xref--show-vocab-usage vocab)))

(defun fuel-apropos (str)
  "Show a list of words containing the given substring."
  (interactive "MFind words containing: ")
  (message "Looking up %s's references ..." str)
  (fuel-xref--apropos str))

(defun fuel-show-file-words (&optional arg)
  "Show a list of words in current file.
With prefix argument, ask for the vocab."
  (interactive "P")
  (let ((vocab (or (and (not arg) (factor-current-vocab))
                   (fuel-completion--read-vocab nil))))
    (when vocab
      (fuel-xref--show-vocab-words vocab
                                   (factor-file-has-private)))))



;;; Xref mode:

(defun fuel-xref-show-help ()
  (interactive)
  (let ((fuel-help-always-ask nil))
    (fuel-help)))

;;;###autoload
(define-derived-mode fuel-xref-mode fundamental-mode "FUEL Xref"
  "Mode for displaying FUEL cross-reference information.
\\{fuel-xref-mode-map}"
  :syntax-table factor-mode-syntax-table
  (buffer-disable-undo)

  (suppress-keymap fuel-xref-mode-map)
  (set-keymap-parent fuel-xref-mode-map button-buffer-map)
  (define-key fuel-xref-mode-map "h" 'fuel-xref-show-help)

  (font-lock-add-keywords nil '(("(in \\(.+\\))" 1 'fuel-xref-vocab-face)))
  (setq buffer-read-only t))


(provide 'fuel-xref)

;;; fuel-xref.el ends here
