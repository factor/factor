;;; factor-mode.el -- mode for editing Factor source

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
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
  "Major mode for Factor source code"
  :group 'fuel)

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


;;; Faces:

(fuel-font-lock--define-faces
 factor-font-lock font-lock factor-mode
 ((comment comment "comments")
  (constructor type  "constructors (<foo>)")
  (declaration keyword "declaration words")
  (parsing-word keyword  "parsing words")
  (setter-word function-name "setter words (>>foo)")
  (stack-effect comment "stack effect specifications")
  (string string "strings")
  (symbol variable-name "name of symbol being defined")
  (type-name type "type names")
  (vocabulary-name constant "vocabulary names")
  (word function-name "word, generic or method being defined")))


;;; Syntax table:

(defun factor-mode--syntax-setup ()
  (set-syntax-table fuel-syntax--syntax-table)
  (set (make-local-variable 'beginning-of-defun-function)
       'fuel-syntax--beginning-of-defun)
  (set (make-local-variable 'end-of-defun-function) 'fuel-syntax--end-of-defun)
  (set (make-local-variable 'open-paren-in-column-0-is-defun-start) nil)
  (fuel-syntax--enable-usings))


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
      (let ((op (fuel-syntax--brackets-start))
            (cl (fuel-syntax--brackets-end))
            (ln (line-number-at-pos)))
        (when (> ln (line-number-at-pos op))
          (if (and (> cl 0) (= ln (line-number-at-pos cl)))
              (fuel-syntax--indentation-at op)
            (fuel-syntax--increased-indentation (fuel-syntax--indentation-at op))))))))

(defun factor-mode--indent-definition ()
  (save-excursion
    (beginning-of-line)
    (when (fuel-syntax--at-begin-of-def) 0)))

(defun factor-mode--indent-setter-line ()
  (when (fuel-syntax--at-setter-line)
    (save-excursion
      (let ((indent (and (fuel-syntax--at-constructor-line) (current-indentation))))
        (while (not (or indent
                        (bobp)
                        (fuel-syntax--at-begin-of-def)
                        (fuel-syntax--at-end-of-def)))
          (if (fuel-syntax--at-constructor-line)
              (setq indent (fuel-syntax--increased-indentation))
            (forward-line -1)))
        indent))))

(defun factor-mode--indent-continuation ()
  (save-excursion
    (forward-line -1)
    (while (and (not (bobp))
                (fuel-syntax--looking-at-emptiness))
      (forward-line -1))
    (cond ((or (fuel-syntax--at-end-of-def)
               (fuel-syntax--at-setter-line))
           (fuel-syntax--decreased-indentation))
          ((and (fuel-syntax--at-begin-of-def)
                (not (fuel-syntax--at-using)))
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

(defconst factor-mode--regex-cycle-endings
  (format "\\(.*?\\)\\(%s\\)$"
          (regexp-opt factor-mode--cycle-endings)))

(defconst factor-mode--cycle-endings-ring
  (let ((ring (make-ring (length factor-mode--cycle-endings))))
    (dolist (e factor-mode--cycle-endings ring)
      (ring-insert ring e))))

(defun factor-mode--cycle-next (file)
  (let* ((match (string-match factor-mode--regex-cycle-endings file))
         (base (and match (match-string-no-properties 1 file)))
         (ending (and match (match-string-no-properties 2 file)))
         (idx (and ending (ring-member factor-mode--cycle-endings-ring ending)))
         (gfl (lambda (i) (concat base (ring-ref factor-mode--cycle-endings-ring i)))))
    (if (not idx) file
      (let ((l (length factor-mode--cycle-endings)) (i 1) next)
        (while (and (not next) (< i l))
          (when (file-exists-p (funcall gfl (+ idx i)))
            (setq next (+ idx i)))
          (setq i (1+ i)))
        (funcall gfl (or next idx))))))

(defun factor-mode-visit-other-file (&optional file)
  "Cycle between code, tests and docs factor files."
  (interactive)
  (find-file (factor-mode--cycle-next (or file (buffer-file-name)))))


;;; Keymap:

(defun factor-mode-insert-and-indent (n)
  (interactive "p")
  (self-insert-command n)
  (indent-for-tab-command))

(defvar factor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [?\]] 'factor-mode-insert-and-indent)
    (define-key map [?}] 'factor-mode-insert-and-indent)
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
  (when factor-mode-use-fuel (require 'fuel-mode) (fuel-mode))
  (run-hooks 'factor-mode-hook))


(provide 'factor-mode)
;;; factor-mode.el ends here
