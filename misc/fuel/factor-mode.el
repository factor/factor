;;; factor-mode.el -- mode for editing Factor source

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Tue Dec 02, 2008 21:32

;;; Comentary:

;; Definition of factor-mode, a major Emacs for editing Factor source
;; code.

;;; Code:

(require 'fuel-base)
(require 'fuel-syntax)
(require 'fuel-font-lock)

(require 'ring)


;;; Customization:

(defgroup factor-mode nil
  "Major mode for Factor source code."
  :group 'fuel
  :group 'languages)

(defcustom factor-mode-cycle-always-ask-p t
  "Whether to always ask for file creation when cycling to a
source/docs/tests file.

When set to false, you'll be asked only once."
  :type 'boolean
  :group 'factor-mode)

(defcustom factor-mode-use-fuel t
  "Whether to use the full FUEL facilities in factor mode.

Set this variable to nil if you just want to use Emacs as the
external editor of your Factor environment, e.g., by putting
these lines in your .emacs:

  (add-to-list 'load-path \"/path/to/factor/misc/fuel\")
  (setq factor-mode-use-fuel nil)
  (require 'factor-mode)
"
  :type 'boolean
  :group 'factor-mode)

(defcustom factor-mode-default-indent-width 4
  "Default indentation width for factor-mode.

This value will be used for the local variable
`factor-mode-indent-width' in new factor buffers. For existing
code, we first check if `factor-mode-indent-width' is set
explicitly in a local variable section or line (e.g.
'! -*- factor-mode-indent-witdth: 2 -*-'). If that's not the case,
`factor-mode' tries to infer its correct value from the existing
code in the buffer."
  :type 'integer
  :group 'fuel)

(defcustom factor-mode-hook nil
  "Hook run when entering Factor mode."
  :type 'hook
  :group 'factor-mode)


;;; Syntax table:

(defun factor-mode--syntax-setup ()
  (set-syntax-table fuel-syntax--syntax-table)
  (set (make-local-variable 'beginning-of-defun-function)
       'fuel-syntax--beginning-of-defun)
  (set (make-local-variable 'end-of-defun-function) 'fuel-syntax--end-of-defun)
  (set (make-local-variable 'open-paren-in-column-0-is-defun-start) nil))


;;; Indentation:

(make-variable-buffer-local
 (defvar factor-mode-indent-width factor-mode-default-indent-width
   "Indentation width in factor buffers. A local variable."))

(defun factor-mode--guess-indent-width ()
  "Chooses an indentation value from existing code."
  (let ((word-cont "^ +[^ ]")
        (iw))
    (save-excursion
      (beginning-of-buffer)
      (while (not iw)
        (if (not (re-search-forward fuel-syntax--definition-start-regex nil t))
            (setq iw factor-mode-default-indent-width)
          (forward-line)
          (when (looking-at word-cont)
            (setq iw (current-indentation))))))
    iw))

(defun factor-mode--indent-in-brackets ()
  (save-excursion
    (beginning-of-line)
    (when (> (fuel-syntax--brackets-depth) 0)
      (let* ((bs (fuel-syntax--brackets-start))
             (be (fuel-syntax--brackets-end))
             (ln (line-number-at-pos)))
        (when (> ln (line-number-at-pos bs))
          (cond ((and (> be 0)
                      (= (- be (point)) (current-indentation))
                      (= ln (line-number-at-pos be)))
                 (fuel-syntax--indentation-at bs))
                ((or (fuel-syntax--is-last-char bs)
                     (not (eq ?\ (char-after (1+ bs)))))
                 (fuel-syntax--increased-indentation
                  (fuel-syntax--indentation-at bs)))
                (t (+ 2 (fuel-syntax--line-offset bs)))))))))

(defun factor-mode--indent-definition ()
  (save-excursion
    (beginning-of-line)
    (when (fuel-syntax--at-begin-of-def) 0)))

(defsubst factor-mode--previous-non-empty ()
  (forward-line -1)
  (while (and (not (bobp))
              (fuel-syntax--looking-at-emptiness))
    (forward-line -1)))

(defun factor-mode--indent-setter-line ()
  (when (fuel-syntax--at-setter-line)
    (or (save-excursion
          (let ((indent (and (fuel-syntax--at-constructor-line)
                             (current-indentation))))
            (while (not (or indent
                            (bobp)
                            (fuel-syntax--at-begin-of-def)
                            (fuel-syntax--at-end-of-def)))
              (if (fuel-syntax--at-constructor-line)
                  (setq indent (fuel-syntax--increased-indentation))
                (forward-line -1)))
            indent))
        (save-excursion
          (factor-mode--previous-non-empty)
          (current-indentation)))))

(defun factor-mode--indent-continuation ()
  (save-excursion
    (factor-mode--previous-non-empty)
    (cond ((or (fuel-syntax--at-end-of-def)
               (fuel-syntax--at-setter-line))
           (fuel-syntax--decreased-indentation))
          ((fuel-syntax--at-begin-of-indent-def)
           (fuel-syntax--increased-indentation))
          (t (current-indentation)))))

(defun factor-mode--calculate-indentation ()
  "Calculate Factor indentation for line at point."
  (or (and (bobp) 0)
      (factor-mode--indent-definition)
      (factor-mode--indent-in-brackets)
      (factor-mode--indent-setter-line)
      (factor-mode--indent-continuation)
      0))

(defun factor-mode--indent-line ()
  "Indent current line as Factor code"
  (let ((target (factor-mode--calculate-indentation))
        (pos (- (point-max) (point))))
    (if (= target (current-indentation))
        (if (< (current-column) (current-indentation))
            (back-to-indentation))
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-to target)
      (if (> (- (point-max) pos) (point))
          (goto-char (- (point-max) pos))))))

(defun factor-mode--indentation-setup ()
  (set (make-local-variable 'indent-line-function) 'factor-mode--indent-line)
  (setq factor-indent-width (factor-mode--guess-indent-width))
  (setq indent-tabs-mode nil))


;;; Buffer cycling:

(defconst factor-mode--cycle-endings
  '(".factor" "-tests.factor" "-docs.factor"))

(make-local-variable
 (defvar factor-mode--cycling-no-ask nil))

(defvar factor-mode--cycle-ring
  (let ((ring (make-ring (length factor-mode--cycle-endings))))
    (dolist (e factor-mode--cycle-endings ring)
      (ring-insert ring e))
    ring))

(defconst factor-mode--cycle-basename-regex
  (format "\\(.+?\\)\\(%s\\)$" (regexp-opt factor-mode--cycle-endings)))

(defun factor-mode--cycle-split (basename)
  (when (string-match factor-mode--cycle-basename-regex basename)
    (cons (match-string 1 basename) (match-string 2 basename))))

(defun factor-mode--cycle-next (file skip)
  (let* ((dir (file-name-directory file))
         (basename (file-name-nondirectory file))
         (p/s (factor-mode--cycle-split basename))
         (prefix (car p/s))
         (ring factor-mode--cycle-ring)
         (idx (or (ring-member ring (cdr p/s)) 0))
         (len (ring-size ring))
         (i 1)
         (result nil))
    (while (and (< i len) (not result))
      (let* ((suffix (ring-ref ring (+ i idx)))
             (path (expand-file-name (concat prefix suffix) dir)))
        (when (or (file-exists-p path)
                  (and (not skip)
                       (not (member suffix factor-mode--cycling-no-ask))
                       (y-or-n-p (format "Create %s? " path))))
          (setq result path))
        (when (and (not factor-mode-cycle-always-ask-p)
                   (not (member suffix factor-mode--cycling-no-ask)))
          (setq factor-mode--cycling-no-ask
                (cons name factor-mode--cycling-no-ask))))
      (setq i (1+ i)))
    result))

(defsubst factor-mode--cycling-setup ()
  (setq factor-mode--cycling-no-ask nil))

(defun factor-mode--code-file (kind &optional file)
  (let* ((file (or file (buffer-file-name)))
         (bn (file-name-nondirectory file)))
    (and (string-match (format "\\(.+\\)-%s\\.factor$" kind) bn)
         (expand-file-name (concat (match-string 1 bn) ".factor")
                           (file-name-directory file)))))

(defsubst factor-mode--in-docs (&optional file)
  (factor-mode--code-file "docs"))

(defsubst factor-mode--in-tests (&optional file)
  (factor-mode--code-file "tests"))

(defun factor-mode-visit-other-file (&optional skip)
  "Cycle between code, tests and docs factor files.
With prefix, non-existing files will be skipped."
  (interactive "P")
  (let ((file (factor-mode--cycle-next (buffer-file-name) skip)))
    (unless file (error "No other file found"))
    (find-file file)
    (unless (file-exists-p file)
      (set-buffer-modified-p t)
      (save-buffer))))


;;; Keymap:

(defun factor-mode--insert-and-indent (n)
  (interactive "*p")
  (let ((start (point)))
    (self-insert-command n)
    (save-excursion (font-lock-fontify-region start (point))))
  (indent-according-to-mode))

(defvar factor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [?\]] 'factor-mode--insert-and-indent)
    (define-key map [?}] 'factor-mode--insert-and-indent)
    (define-key map "\C-m" 'newline-and-indent)
    (define-key map "\C-co" 'factor-mode-visit-other-file)
    (define-key map "\C-c\C-o" 'factor-mode-visit-other-file)
    map))

(defun factor-mode--keymap-setup ()
  (use-local-map factor-mode-map))


;;; Factor mode:

;;;###autoload
(defun factor-mode ()
  "A mode for editing programs written in the Factor programming language.
\\{factor-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'factor-mode)
  (setq mode-name "Factor")
  (fuel-font-lock--font-lock-setup)
  (factor-mode--keymap-setup)
  (factor-mode--indentation-setup)
  (factor-mode--syntax-setup)
  (factor-mode--cycling-setup)
  (when factor-mode-use-fuel (require 'fuel-mode) (fuel-mode))
  (run-hooks 'factor-mode-hook))


(provide 'factor-mode)
;;; factor-mode.el ends here
