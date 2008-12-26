;;; fuel-debug-uses.el -- retrieving USING: stanzas

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Tue Dec 23, 2008 04:23

;;; Comentary:

;; Support for getting and updating factor source vocabulary lists.

;;; Code:

(require 'fuel-debug)
(require 'fuel-eval)
(require 'fuel-popup)
(require 'fuel-font-lock)
(require 'fuel-base)



;;; Customization:

(fuel-font-lock--defface fuel-font-lock-debug-missing-vocab
  'font-lock-warning-face fuel-debug "missing vocabulary names")

(fuel-font-lock--defface fuel-font-lock-debug-unneeded-vocab
  'font-lock-warning-face fuel-debug "unneeded vocabulary names")

(fuel-font-lock--defface fuel-font-lock-debug-uses-header
  'bold fuel-debug "headers in Uses buffers")


;;; Utility functions:

(defsubst fuel-debug--at-eou-p ()
  (looking-at ".*\\_<;\\_>"))

(defun fuel-debug--file-lines (file)
  (when (file-readable-p file)
    (with-current-buffer (find-file-noselect file)
      (save-excursion
        (goto-char (point-min))
        (let ((lines) (in-usings))
          (while (not (eobp))
            (when (looking-at "^USING: ") (setq in-usings t))
            (unless in-usings
              (let ((line (substring-no-properties (thing-at-point 'line) 0 -1)))
                (unless (or (empty-string-p line)
                            (fuel--string-prefix-p "! " line))
                  (push line lines))))
            (when (and in-usings (fuel-debug--at-eou-p)) (setq in-usings nil))
            (forward-line))
          (reverse lines))))))

(defun fuel-debug--highlight-names (names ref face)
  (dolist (n names)
    (when (not (member n ref))
      (put-text-property 0 (length n) 'face face n))))

(defun fuel-debug--uses-new-uses (file uses)
  (pop-to-buffer (find-file-noselect file))
  (goto-char (point-min))
  (if (re-search-forward "^USING: " nil t)
      (let ((begin (point))
            (end (or (and (re-search-forward "\\_<;\\_>") (point)) (point))))
        (kill-region begin end))
    (re-search-forward "^IN: " nil t)
    (beginning-of-line)
    (open-line 2)
    (insert "USING: "))
  (let ((start (point)))
    (insert (mapconcat 'identity uses " ") " ;")
    (fill-region start (point) nil)))

(defun fuel-debug--uses-filter (restarts)
  (let ((result) (i 1) (rn 0))
    (dolist (r restarts (reverse result))
      (setq rn (1+ rn))
      (when (string-match "Use the .+ vocabulary\\|Defer" r)
        (push (list i rn r) result)
        (setq i (1+ i))))))


;;; Retrieving USINGs:

(fuel-popup--define fuel-debug--uses-buffer
  "*fuel uses*" 'fuel-debug-uses-mode)

(make-variable-buffer-local
 (defvar fuel-debug--uses nil))

(make-variable-buffer-local
 (defvar fuel-debug--uses-file nil))

(make-variable-buffer-local
 (defvar fuel-debug--uses-restarts nil))

(defsubst fuel-debug--uses-insert-title ()
  (insert "Infering USING: stanza for " fuel-debug--uses-file ".\n\n"))

(defun fuel-debug--uses-prepare (file)
  (fuel--with-popup (fuel-debug--uses-buffer)
    (setq fuel-debug--uses-file file
          fuel-debug--uses nil
          fuel-debug--uses-restarts nil)
    (erase-buffer)
    (fuel-debug--uses-insert-title)))

(defun fuel-debug--uses-clean ()
  (setq fuel-debug--uses-file nil
        fuel-debug--uses nil
        fuel-debug--uses-restarts nil))

(defun fuel-debug--uses-for-file (file)
  (let* ((lines (fuel-debug--file-lines file))
         (cmd `(:fuel ((V{ ,@lines } fuel-get-uses)) t t)))
    (fuel-debug--uses-prepare file)
    (fuel--with-popup (fuel-debug--uses-buffer)
      (insert "Asking Factor. Please, wait ...\n")
      (fuel-eval--send cmd 'fuel-debug--uses-cont))
    (fuel-popup--display (fuel-debug--uses-buffer))))

(defun fuel-debug--uses-cont (retort)
  (let ((uses (fuel-eval--retort-result retort))
        (err (fuel-eval--retort-error retort)))
    (if uses (fuel-debug--uses-display uses)
      (fuel-debug--uses-display-err retort))))

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

(defun fuel-debug--uses-display (uses)
  (let* ((inhibit-read-only t)
         (old (with-current-buffer (find-file-noselect fuel-debug--uses-file)
                (fuel-syntax--usings)))
         (old (sort old 'string<))
         (new (sort uses 'string<)))
    (erase-buffer)
    (fuel-debug--uses-insert-title)
    (if (equalp old new)
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
          (insert (format " :%s %s\n" (first r) (third r))))))))

(defun fuel-debug--uses-update-usings ()
  (interactive)
  (let ((inhibit-read-only t))
    (when (and fuel-debug--uses-file fuel-debug--uses)
      (fuel-debug--uses-new-uses fuel-debug--uses-file fuel-debug--uses)
      (message "USING: updated!")
      (with-current-buffer (fuel-debug--uses-buffer)
        (insert "\n Done!")
        (fuel-debug--uses-clean)
        (fuel-popup--quit)))))

(defun fuel-debug--uses-restart (n)
  (when (and (> n 0) (<= n (length fuel-debug--uses-restarts)))
    (let* ((inhibit-read-only t)
           (restart (format ":%s" (cadr (nth (1- n) fuel-debug--uses-restarts))))
           (cmd `(:fuel ([ (:factor ,restart) ] fuel-with-autouse) t t)))
      (setq fuel-debug--uses-restarts nil)
      (insert "\nAsking Factor. Please, wait ...\n")
      (fuel-eval--send cmd 'fuel-debug--uses-cont))))


;;; Fuel uses mode:

(defvar fuel-debug-uses-mode-map
  (let ((map (make-keymap)))
    (suppress-keymap map)
    (dotimes (n 9)
      (define-key map (vector (+ ?1 n))
        `(lambda () (interactive) (fuel-debug--uses-restart ,(1+ n)))))
    (define-key map "y" 'fuel-debug--uses-update-usings)
    (define-key map "\C-c\C-c" 'fuel-debug--uses-update-usings)
    map))

(defun fuel-debug-uses-mode ()
  "A major mode for displaying Factor's USING: inference results."
  (interactive)
  (kill-all-local-variables)
  (buffer-disable-undo)
  (setq major-mode 'fuel-debug-uses-mode)
  (setq mode-name "Fuel Uses:")
  (use-local-map fuel-debug-uses-mode-map))


(provide 'fuel-debug-uses)
;;; fuel-debug-uses.el ends here
