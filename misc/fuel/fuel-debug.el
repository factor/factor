;;; fuel-debug.el -- debugging factor code -*- lexical-binding: t -*-

;; Copyright (C) 2008, 2009, 2010 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 07, 2008 04:16

;;; Comentary:

;; A mode for displaying the results of run-file and evaluation, with
;; support for restarts.

;;; Code:

(require 'fuel-eval)
(require 'fuel-popup)
(require 'fuel-menu)
(require 'fuel-base)


;;; Customization:

;;;###autoload
(defgroup fuel-debug nil
  "Major mode for interaction with the Factor debugger."
  :group 'fuel)

(defcustom fuel-debug-mode-hook nil
  "Hook run after `fuel-debug-mode' activates."
  :group 'fuel-debug
  :type 'hook)

(defcustom fuel-debug-confirm-restarts-p t
  "Whether to ask for confimation before executing a restart in
the debugger."
  :group 'fuel-debug
  :type 'boolean)

(defcustom fuel-debug-show-short-help t
  "Whether to show short help on available keys in debugger."
  :group 'fuel-debug
  :type 'boolean)

(defface fuel-font-lock-debug-error '((t (:inherit font-lock-warning-face)))
  "highlighting errors"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-line
  '((t (:inherit font-lock-variable-name-face)))
  "line numbers in errors/warnings"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-column
  '((t (:inherit font-lock-variable-name-face)))
  "column numbers in errors/warnings"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-info '((t (:inherit font-lock-comment-face)))
  "information headers"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-restart-number
  '((t (:inherit font-lock-warning-face)))
  "restart numbers"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-restart-name
  '((t (:inherit font-lock-function-name-face)))
  "restart names"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-missing-vocab
  '((t (:inherit font-lock-warning-face)))
  "missing vocabulary names"
  :group 'fuel-debug)

(defface fuel-font-lock-debug-unneeded-vocab
  '((t (:inherit font-lock-warning-face)))
  "unneeded vocabulary names"
  :group 'fuel-debug)


;;; Font lock and other pattern matching:

(defconst fuel-debug--compiler-info-alist
  '((":warnings" . ?w) (":errors" . ?e) (":linkage" . ?l)))

(defconst fuel-debug--error-file-regex "^P\" \\([^\"]+\\)\"")
(defconst fuel-debug--error-line-regex "\\([0-9]+\\):")
(defconst fuel-debug--error-cont-regex "^ +\\(\\^\\)$")

(defconst fuel-debug--error-regex
  (format "%s\n%s"
          fuel-debug--error-file-regex
          fuel-debug--error-line-regex))

(defconst fuel-debug--compiler-info-regex
  (format "^\\(%s\\) "
          (regexp-opt (mapcar 'car fuel-debug--compiler-info-alist))))

(defconst fuel-debug--restart-regex "^:\\([0-9]+\\) \\(.+\\)")

(defconst fuel-debug--font-lock-keywords
  `((,fuel-debug--error-file-regex . 'fuel-font-lock-debug-error)
    (,fuel-debug--error-line-regex 1 'fuel-font-lock-debug-line)
    (,fuel-debug--error-cont-regex 1 'fuel-font-lock-debug-column)
    (,fuel-debug--restart-regex (1 'fuel-font-lock-debug-restart-number)
                                (2 'fuel-font-lock-debug-restart-name))
    (,fuel-debug--compiler-info-regex 1 'fuel-font-lock-debug-restart-number)
    ("^\\(Restarts?\\|Loading\\) .+$" . 'fuel-font-lock-debug-info)
    ("^Error: " . 'fuel-font-lock-debug-error)))


;;; Debug buffer:

(defun fuel-debug--buffer ()
  (or (get-buffer "*fuel debug*")
      (with-current-buffer (get-buffer-create "*fuel debug*")
        (fuel-debug-mode)
        (fuel-popup-mode)
        (current-buffer))))

(defvar-local fuel-debug--last-ret nil)

(defvar-local fuel-debug--file nil)

(defvar-local fuel-debug--uses nil)

(defun fuel-debug--prepare-compilation (file msg)
  (let ((inhibit-read-only t))
    (with-current-buffer (fuel-debug--buffer)
      (erase-buffer)
      (insert msg)
      (setq fuel-debug--file file))))

(defun fuel-debug--display-retort (ret &optional success-msg no-pop)
  (let ((err (fuel-eval--retort-error ret))
        (inhibit-read-only t))
    (with-current-buffer (fuel-debug--buffer)
      (erase-buffer)
      (fuel-debug--display-output ret)
      (delete-blank-lines)
      (newline)
      (cond
       ((and (not err) success-msg)
        (message "%s" success-msg)
        (insert "\n" success-msg "\n"))
       ((eq (car err) 'fuel-con-error)
        (fuel-debug--display-parse-error (second err)))
       (err
        (fuel-debug--display-restarts err)
        (delete-blank-lines)
        (newline)))
      (fuel-debug--display-uses ret)
      (let ((hstr (fuel-debug--help-string err fuel-debug--file)))
        (if fuel-debug-show-short-help
            (insert "-----------\n" hstr "\n")
          (message "%s" hstr)))
      (setq fuel-debug--last-ret ret)
      (goto-char (point-max))
      (font-lock-fontify-buffer)
      (when (and err (not no-pop)) (fuel-popup--display))
      (not err))))

(defun fuel-debug--uses (ret)
  (let ((uses (fuel-eval--retort-result ret)))
    (and (eq :uses (car uses))
         (cdr uses))))

(defun fuel-debug--insert-vlist (title vlist)
  (goto-char (point-max))
  (insert title "\n\n  ")
  (let ((i 0) (step 5))
    (dolist (v vlist)
      (setq i (1+ i))
      (insert v)
      (insert (if (zerop (mod i step)) "\n  " " ")))
    (unless (zerop (mod i step)) (newline))
    (newline)))

(defun fuel-debug--highlight-names (names ref face)
  (dolist (n names)
    (when (not (member n ref))
      (put-text-property 0 (length n) 'font-lock-face face n))))

(defun fuel-debug--display-uses (ret)
  (when (setq fuel-debug--uses (fuel-debug--uses ret))
    (newline)
    (fuel-debug--highlight-names fuel-debug--uses
                                 nil 'fuel-font-lock-debug-missing-vocab)
    (fuel-debug--insert-vlist "Missing vocabularies:" fuel-debug--uses)
    (newline)))

(defun fuel-debug--display-output (ret)
  "Diplays the retort `ret' in fuels debug buffer."
  (let* ((last (fuel-eval--retort-output fuel-debug--last-ret))
         (current (fuel-eval--retort-output ret))
         (llen (length last))
         (clen (length current))
         (trail (and last (substring-no-properties last (/ llen 2))))
         (err (fuel-eval--retort-error ret))
         (p (point)))
    (when current (save-excursion (insert current)))
    (when (and (> clen llen) (> llen 0) (search-forward trail nil t))
      (delete-region p (point)))
    (goto-char (point-max))
    (when err
      (insert (format "\nError: %S\n\n" (fuel-eval--error-name err))))))

(defun fuel-debug--display-parse-error (str)
  (insert
   (format
    "FUEL failed to parse the connection response, displayed below:\n\n%s\n\n" str)))

(defun fuel-debug--display-restarts (err)
  (let* ((rs (fuel-eval--error-restarts err))
         (rsn (length rs)))
    (when rs
      (insert "Restarts:\n\n")
      (dotimes (n rsn)
        (insert (format ":%s %s\n" (1+ n) (nth n rs))))
      (newline))))

(defun fuel-debug--help-string (err &optional file)
  (format "Press %s%s%s%sq bury buffer"
          (if (or file (fuel-eval--error-file err)) "g go to file, " "")
          (let ((rsn (length (fuel-eval--error-restarts err))))
            (cond ((zerop rsn) "")
                  ((= 1 rsn) "1 invoke restart, ")
                  (t (format "1-%s invoke restarts, " rsn))))
          (let ((str ""))
            (dolist (ci fuel-debug--compiler-info-alist str)
              (save-excursion
                (goto-char (point-min))
                (when (search-forward (car ci) nil t)
                  (setq str (format "%c %s, %s" (cdr ci) (car ci) str))))))
          (if fuel-debug--uses "u to update USING:, " "")))

(defun fuel-debug--buffer-file ()
  (with-current-buffer (fuel-debug--buffer)
    (or fuel-debug--file
        (and fuel-debug--last-ret
             (fuel-eval--error-file
              (fuel-eval--retort-error fuel-debug--last-ret))))))

(defsubst fuel-debug--buffer-error ()
  (fuel-eval--retort-error fuel-debug--last-ret))

(defsubst fuel-debug--buffer-restarts ()
  (fuel-eval--error-restarts (fuel-debug--buffer-error)))


;;; Buffer navigation:

(defun fuel-debug-goto-error ()
  (interactive)
  (let* ((err (fuel-debug--buffer-error))
         (file (or (fuel-debug--buffer-file)
                   (error "No file associated with compilation")))
         (l/c (and err (fuel-eval--error-line/column err)))
         (line (or (car l/c) 1))
         (col (or (cdr l/c) 0)))
    (find-file-other-window file)
    (when line
      (goto-char (point-min))
      (forward-line (1- line))
      (when col (forward-char col)))))

(defun fuel-debug--read-restart-no ()
  (let ((rs (fuel-debug--buffer-restarts)))
    (unless rs (error "No restarts available"))
    (let* ((rsn (length rs))
           (prompt (format "Restart number? (1-%s): " rsn))
           (no 0))
      (while (or (> (setq no (read-number prompt)) rsn)
                 (< no 1)))
      no)))

(defun fuel-debug-exec-restart (&optional n confirm)
  (interactive (list (fuel-debug--read-restart-no)))
  (let ((n (or n 1))
        (rs (fuel-debug--buffer-restarts)))
    (when (zerop (length rs))
      (error "No restarts available"))
    (when (or (< n 1) (> n (length rs)))
      (error "Restart %s not available" n))
    (when (or (not confirm)
              (y-or-n-p (format "Invoke restart %s? " n)))
      (message "Invoking restart %s" n)
      (let* ((file (fuel-debug--buffer-file))
             (buffer (if file (find-file-noselect file) (current-buffer))))
        (with-current-buffer buffer
          (fuel-debug--display-retort
           (fuel-eval--send/wait `(:fuel ((:factor ,(format ":%s" n)))))
           (format "Restart %s (%s) successful" n (nth (1- n) rs))))))))

(defun fuel-debug-show--compiler-info (info)
  (save-excursion
    (goto-char (point-min))
    (unless (re-search-forward (format "^%s" info) nil t)
      (error "%s information not available" info))
    (message "Retrieving %s info ..." info)
    (unless (fuel-debug--display-retort
             (fuel-eval--send/wait `(:fuel ((:factor ,info)))) "")
      (error "Sorry, no %s info available" info))))

(defun fuel-debug--replace-usings (file uses)
  (pop-to-buffer (find-file-noselect file))
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^USING: " nil t)
        (let ((begin (point))
              (end (or (and (re-search-forward ";\\( \\|$\\)") (point))
                       (point))))
          (kill-region begin end))
      (re-search-forward "^IN: " nil t)
      (beginning-of-line)
      (open-line 2)
      (insert "USING: "))
    (let ((start (point))
          (tokens (append uses '(";"))))
      (insert (mapconcat 'substring-no-properties tokens " "))
      (fill-region start (point) nil))))

(defun fuel-debug-update-usings ()
  (interactive)
  (when (and fuel-debug--file fuel-debug--uses)
    (let* ((file fuel-debug--file)
           (old (with-current-buffer (find-file-noselect file)
                  (factor-find-usings t)))
           (uses (sort (append fuel-debug--uses old) 'string<)))
      (fuel-popup--quit)
      (fuel-debug--replace-usings file uses))))


;;; Fuel Debug mode:

;;;###autoload
(define-derived-mode fuel-debug-mode fundamental-mode "FUEL Debug"
  "A major mode for displaying Factor's compilation results and
invoking restarts as needed.
\\{fuel-debug-mode-map}"
  (buffer-disable-undo)

  (suppress-keymap fuel-debug-mode-map)
  (dotimes (n 9)
    (define-key fuel-debug-mode-map (vector (+ ?1 n))
      `(lambda () (interactive)
         (fuel-debug-exec-restart ,(1+ n) fuel-debug-confirm-restarts-p))))
  (dolist (ci fuel-debug--compiler-info-alist)
    (define-key fuel-debug-mode-map (vector (cdr ci))
      `(lambda () (interactive) (fuel-debug-show--compiler-info ,(car ci)))))

  (setq font-lock-defaults
        '(fuel-debug--font-lock-keywords t nil nil nil)))

(fuel-menu--defmenu fuel-debug fuel-debug-mode-map
  ("Go to error" ("g" "\C-c\C-c") fuel-debug-goto-error)
  ("Next line" "n" next-line)
  ("Previous line" "p" previous-line)
  ("Update USINGs" "u" fuel-debug-update-usings))


(provide 'fuel-debug)

;;; fuel-debug.el ends here
