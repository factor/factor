;;; fuel-debug.el -- debugging factor code

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 07, 2008 04:16

;;; Comentary:

;; A mode for displaying the results of run-file and evaluation, with
;; support for restarts.

;;; Code:

(require 'fuel-base)
(require 'fuel-eval)
(require 'fuel-font-lock)


;;; Customization:

(defgroup fuel-debug nil
  "Major mode for interaction with the Factor debugger"
  :group 'fuel)

(defcustom fuel-debug-mode-hook nil
  "Hook run after `fuel-debug-mode' activates"
  :group 'fuel-debug
  :type 'hook)

(defcustom fuel-debug-show-short-help t
  "Whether to show short help on available keys in debugger"
  :group 'fuel-debug
  :type 'boolean)

(fuel-font-lock--define-faces
 fuel-debug-font-lock font-lock fuel-debug
 ((error warning "highlighting errors")
  (line variable-name "line numbers in errors/warnings")
  (column variable-name "column numbers in errors/warnings")
  (info comment "information headers")
  (restart-number warning "restart numbers")
  (restart-name function-name "restart names")))


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
  `((,fuel-debug--error-file-regex . 'fuel-debug-font-lock-error)
    (,fuel-debug--error-line-regex 1 'fuel-debug-font-lock-line)
    (,fuel-debug--error-cont-regex 1 'fuel-debug-font-lock-column)
    (,fuel-debug--restart-regex (1 'fuel-debug-font-lock-restart-number)
                                (2 'fuel-debug-font-lock-restart-name))
    (,fuel-debug--compiler-info-regex 1 'fuel-debug-font-lock-restart-number)
    ("^\\(Restarts?\\|Loading\\) .+$" . 'fuel-debug-font-lock-info)
    ("^Error: " . 'fuel-debug-font-lock-error)))

(defun fuel-debug--font-lock-setup ()
  (set (make-local-variable 'font-lock-defaults)
       '(fuel-debug--font-lock-keywords t nil nil nil)))


;;; Debug buffer:

(defvar fuel-debug--buffer nil)

(make-variable-buffer-local
 (defvar fuel-debug--last-ret nil))

(make-variable-buffer-local
 (defvar fuel-debug--file nil))

(defun fuel-debug--buffer ()
  (or (and (buffer-live-p fuel-debug--buffer) fuel-debug--buffer)
      (with-current-buffer
          (setq fuel-debug--buffer (get-buffer-create "*fuel dbg*"))
        (fuel-debug-mode)
        (current-buffer))))

(defun fuel-debug--display-retort (ret &optional success-msg no-pop file)
  (let ((err (fuel-eval--retort-error ret))
        (inhibit-read-only t))
    (with-current-buffer (fuel-debug--buffer)
      (erase-buffer)
      (fuel-debug--display-output ret)
      (delete-blank-lines)
      (newline)
      (when (and (not err) success-msg)
        (message "%s" success-msg)
        (insert "\n" success-msg "\n"))
      (when err
        (fuel-debug--display-restarts err)
        (delete-blank-lines)
        (newline)
        (let ((hstr (fuel-debug--help-string err file)))
          (if fuel-debug-show-short-help
              (insert "-----------\n" hstr "\n")
            (message "%s" hstr))))
      (setq fuel-debug--last-ret ret)
      (setq fuel-debug--file file)
      (goto-char (point-max))
      (when (and err (not no-pop)) (pop-to-buffer fuel-debug--buffer))
      (not err))))

(defun fuel-debug--display-output (ret)
  (let* ((last (fuel-eval--retort-output fuel-debug--last-ret))
         (current (fuel-eval--retort-output ret))
         (llen (length last))
         (clen (length current))
         (trail (and last (substring-no-properties last (/ llen 2))))
         (err (fuel-eval--retort-error ret))
         (p (point)))
    (save-excursion (insert current))
    (when (and (> clen llen) (> llen 0) (search-forward trail nil t))
      (delete-region p (point)))
    (goto-char (point-max))
    (when err
      (insert (format "\nError: %S\n\n" (fuel-eval--error-name err))))))

(defun fuel-debug--display-restarts (err)
  (let* ((rs (fuel-eval--error-restarts err))
         (rsn (length rs)))
    (when rs
      (insert "Restarts:\n\n")
      (dotimes (n rsn)
        (insert (format ":%s %s\n" (1+ n) (nth n rs))))
      (newline))))

(defun fuel-debug--help-string (err &optional file)
  (format "Press %s%s%sq bury buffer"
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
                  (setq str (format "%c %s, %s" (cdr ci) (car ci) str))))))))

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
  (let* ((err (or (fuel-debug--buffer-error)
                  (error "No errors reported")))
         (file (or (fuel-debug--buffer-file)
                   (error "No file associated with error")))
         (l/c (fuel-eval--error-line/column err))
         (line (or (car l/c) 1))
         (col (or (cdr l/c) 0)))
    (find-file-other-window file)
    (goto-line line)
    (forward-char col)))

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
           (fuel-eval--send/wait (fuel-eval--cmd/string (format ":%s" n)))
           (format "Restart %s (%s) successful" n (nth (1- n) rs))))))))

(defun fuel-debug-show--compiler-info (info)
  (save-excursion
    (goto-char (point-min))
    (unless (re-search-forward (format "^%s" info) nil t)
      (error "%s information not available" info))
    (message "Retrieving %s info ..." info)
    (unless (fuel-debug--display-retort
             (fuel-eval--send/wait (fuel-eval--cmd/string info))
             "" (fuel-debug--buffer-file))
      (error "Sorry, no %s info available" info))))


;;; Fuel Debug mode:

(defvar fuel-debug-mode-map
  (let ((map (make-keymap)))
    (suppress-keymap map)
    (define-key map "g" 'fuel-debug-goto-error)
    (define-key map "\C-c\C-c" 'fuel-debug-goto-error)
    (define-key map "n" 'next-line)
    (define-key map "p" 'previous-line)
    (define-key map "q" 'bury-buffer)
    (dotimes (n 9)
      (define-key map (vector (+ ?1 n))
        `(lambda () (interactive) (fuel-debug-exec-restart ,(1+ n) t))))
    (dolist (ci fuel-debug--compiler-info-alist)
      (define-key map (vector (cdr ci))
        `(lambda () (interactive) (fuel-debug-show--compiler-info ,(car ci)))))
    map))

(defun fuel-debug-mode ()
  "A major mode for displaying Factor's compilation results and
invoking restarts as needed.
\\{fuel-debug-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'factor-mode)
  (setq mode-name "Fuel Debug")
  (use-local-map fuel-debug-mode-map)
  (fuel-debug--font-lock-setup)
  (setq fuel-debug--file nil)
  (setq fuel-debug--last-ret nil)
  (toggle-read-only 1)
  (run-hooks 'fuel-debug-mode-hook))


(provide 'fuel-debug)
;;; fuel-debug.el ends here
