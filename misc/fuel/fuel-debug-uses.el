;;; fuel-debug-uses.el -- retrieving USING: stanzas -*- lexical-binding: t -*-

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Tue Dec 23, 2008 04:23

;;; Comentary:

;; Support for getting and updating factor source vocabulary lists.

;;; Code:

(require 'fuel-debug)
(require 'fuel-eval)
(require 'fuel-popup)
(require 'fuel-base)



;;; Customization:

;;;###autoload
(defgroup fuel-debug-uses nil
  "Customization for FUEL's debug uses."
  :group 'fuel)

(defface fuel-debug-uses-header-face '((t (:inherit header)))
  "Header face for FUEL's debug uses."
  :group 'fuel-debug-uses
  :group 'fuel-faces
  :group 'faces)

(defface fuel-debug-uses-prompt-face '((t (:inherit comint-highlight-prompt)))
  "Prompt face for FUEL's debug uses."
  :group 'fuel-debug-uses
  :group 'fuel-faces
  :group 'faces)


;;; Utility functions:

(defsubst fuel-debug--chomp (s)
  (replace-regexp-in-string "[\n\r\f]" "" s))

(defun fuel-debug--file-lines (file)
  (when (file-readable-p file)
    (with-current-buffer (find-file-noselect file)
      (save-excursion
        (goto-char (point-min))
        (let ((lines) (in-usings))
          (while (not (eobp))
            (when (looking-at "^USING: ") (setq in-usings t))
            (let ((line (fuel-debug--chomp
                         (substring-no-properties (thing-at-point 'line)))))
              (when in-usings (setq line (concat "! " line)))
              (push line lines))
            (when (and in-usings (looking-at "\\(^\\|.* \\);\\( \\|\n\\)"))
              (setq in-usings nil))
            (forward-line))
          (reverse lines))))))

(defun fuel-debug--uses-filter (restarts)
  (let ((result) (i 1) (rn 0))
    (dolist (r restarts (reverse result))
      (setq rn (1+ rn))
      (when (string-match "Use the .+ vocabulary\\|Defer" r)
        (push (list i rn r) result)
        (setq i (1+ i))))))


;;; Retrieving USINGs:

(defun fuel-debug--uses-buffer ()
  (or (get-buffer "*fuel uses*")
      (with-current-buffer (get-buffer-create "*fuel uses*")
        (fuel-debug-uses-mode)
        (fuel-popup-mode)
        (current-buffer))))

(defvar-local fuel-debug--uses-file nil)

(defvar-local fuel-debug--uses-restarts nil)

(defsubst fuel-debug--uses-insert-title ()
  (insert "Inferring USING: stanza for " fuel-debug--uses-file ".\n\n"))

(defun fuel-debug--uses-prepare (file)
  (with-current-buffer (fuel-debug--uses-buffer)
    (let ((inhibit-read-only t))
      (setq fuel-debug--uses-file file
            fuel-debug--uses nil
            fuel-debug--uses-restarts nil)
      (erase-buffer)
      (fuel-debug--uses-insert-title))))

(defun fuel-debug--uses-clean ()
  (setq fuel-debug--uses-file nil
        fuel-debug--uses nil
        fuel-debug--uses-restarts nil))

(defun fuel-debug--current-usings (file)
  (with-current-buffer (find-file-noselect file)
    (sort (factor-find-usings t) 'string<)))

(defun fuel-debug--uses-for-file (file)
  (let* ((lines (fuel-debug--file-lines file))
         (old-usings (fuel-debug--current-usings file))
         (cmd `(:fuel ((V{ ,@old-usings }
                           [ ,file V{ ,@lines } fuel-get-uses ]
                           fuel-use-suggested-vocabs)) t t)))
    (fuel-debug--uses-prepare file)
    (with-current-buffer (fuel-debug--uses-buffer)
      (let ((inhibit-read-only t))
        (insert "Asking Factor. Please, wait...\n")
        (fuel-eval--send cmd 'fuel-debug--uses-cont)))
    (fuel-popup--display (fuel-debug--uses-buffer))))

(defun fuel-debug--uses-cont (retort)
  (let ((uses (fuel-debug--uses retort))
        (err (fuel-eval--retort-error retort)))
    (if err
        (fuel-debug--uses-display-err retort)
      (fuel-debug--uses-display uses))))

(defun fuel-debug--uses-display (uses)
  (let* ((inhibit-read-only t)
         (old (fuel-debug--current-usings fuel-debug--uses-file))
         (new (sort uses 'string<)))
    (erase-buffer)
    (fuel-debug--uses-insert-title)
    (if (cl-equalp old new)
        (progn
          (insert "Current USING: is already fine!. Type 'q' to bury buffer.\n")
          (fuel-debug--uses-clean))
      (fuel-debug--highlight-names old new 'fuel-font-lock-debug-unneeded-vocab)
      (fuel-debug--highlight-names new old 'fuel-font-lock-debug-missing-vocab)
      (fuel-debug--insert-vlist "Current vocabulary list:" old)
      (newline)
      (fuel-debug--insert-vlist "Correct vocabulary list:" new)
      (setq fuel-debug--uses new)
      (insert "\nType 'y' to update your USING: to the new one.\n"))))

(defun fuel-debug--uses-display-err (retort)
  (let* ((inhibit-read-only t)
         (err (fuel-eval--retort-error retort))
         (restarts (fuel-debug--uses-filter (fuel-eval--error-restarts err)))
         (unique (= 1 (length restarts))))
    (erase-buffer)
    (fuel-debug--uses-insert-title)
    (insert (fuel-eval--retort-output retort))
    (newline)
    (if (not restarts)
        (insert "\nSorry, couldn't infer the vocabulary list.\n")
      (setq fuel-debug--uses-restarts restarts)
      (if unique (fuel-debug--uses-restart 1)
        (insert "\nPlease, type the number of the desired vocabulary:\n\n")
        (dolist (r restarts)
          (insert (format " :%s %s\n" (cl-first r) (cl-third r))))))))

(defun fuel-debug--uses-update-usings ()
  (interactive)
  (let ((inhibit-read-only t)
        (file fuel-debug--uses-file)
        (uses fuel-debug--uses))
    (when file
      (insert "\nDone!")
      (fuel-debug--uses-clean)
      (fuel-popup--quit)
      (fuel-debug--replace-usings file uses)
      (message "USING: updated!"))))

(defun fuel-debug--uses-restart (n)
  (when (and (> n 0) (<= n (length fuel-debug--uses-restarts)))
    (let* ((inhibit-read-only t)
           (restart (format ":%s" (cadr (nth (1- n) fuel-debug--uses-restarts))))
           (cmd `(:fuel ([ (:factor ,restart) ] fuel-with-autouse) t t)))
      (setq fuel-debug--uses-restarts nil)
      (insert "\nAsking Factor. Please, wait ...\n")
      (fuel-eval--send cmd 'fuel-debug--uses-cont))))


;;; Fuel uses mode:

(defconst fuel-debug--uses-header-regex
  (format "^%s.*$"
          (regexp-opt '("Inferring USING: stanza for "
                        "Current USING: is already fine!"
                        "Current vocabulary list:"
                        "Correct vocabulary list:"
                        "Sorry, couldn't infer the vocabulary list."
                        "Done!"))))

(defconst fuel-debug--uses-prompt-regex
  (format "^%s"
          (regexp-opt '("Asking Factor. Please, wait ..."
                        "Please, type the number of the desired vocabulary:"
                        "Type 'y' to update your USING: to the new one."))))

(defconst fuel-debug--uses-font-lock-keywords
  `((,fuel-debug--uses-header-regex . 'fuel-debug-uses-header-face)
    (,fuel-debug--uses-prompt-regex . 'fuel-debug-uses-prompt-face)
    (,fuel-debug--restart-regex (1 'fuel-font-lock-debug-restart-number)
                                (2 'fuel-font-lock-debug-restart-name))))

(defvar fuel-debug-uses-mode-map
  (let ((map (make-keymap)))
    (suppress-keymap map)
    (dotimes (n 9)
      (define-key map (vector (+ ?1 n))
        `(lambda () (interactive) (fuel-debug--uses-restart ,(1+ n)))))
    (define-key map "y" 'fuel-debug--uses-update-usings)
    (define-key map "\C-c\C-c" 'fuel-debug--uses-update-usings)
    map))

;;;###autoload
(define-derived-mode fuel-debug-uses-mode fundamental-mode "FUEL Uses"
  "A major mode for displaying Factor's USING: inference results.
\\{fuel-debug-uses-mode-map}"
  (buffer-disable-undo)
  (setq font-lock-defaults
        '(fuel-debug--uses-font-lock-keywords t nil nil nil)))


(provide 'fuel-debug-uses)

;;; fuel-debug-uses.el ends here
