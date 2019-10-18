;;; fuel-completion.el -- completion utilities

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Dec 14, 2008 21:17

;;; Comentary:

;; Code completion utilities.

;;; Code:

(require 'fuel-base)
(require 'fuel-syntax)
(require 'fuel-eval)
(require 'fuel-log)


;;; Aux:

(defvar fuel-completion--minibuffer-map
  (let ((map (make-keymap)))
    (set-keymap-parent map minibuffer-local-completion-map)
    (define-key map "?" 'self-insert-command)
    map))


;;; Vocabs dictionary:

(defvar fuel-completion--vocabs nil)

(defun fuel-completion--vocabs (&optional reload)
  (when (or reload (not fuel-completion--vocabs))
    (fuel--respecting-message "Retrieving vocabs list")
    (let ((fuel-log--inhibit-p t))
      (setq fuel-completion--vocabs
            (fuel-eval--retort-result
             (fuel-eval--send/wait '(:fuel* (fuel-get-vocabs) "fuel" (:array)))))))
  fuel-completion--vocabs)

(defun fuel-completion--read-vocab (&optional reload init-input history)
  (let ((minibuffer-local-completion-map fuel-completion--minibuffer-map)
        (vocabs (fuel-completion--vocabs reload)))
    (completing-read "Vocab name: " vocabs nil nil init-input history)))

(defsubst fuel-completion--vocab-list (prefix)
  (fuel-eval--retort-result
   (fuel-eval--send/wait `(:fuel* (,prefix fuel-get-vocabs/prefix) t t))))

(defun fuel-completion--words (prefix vocabs)
  (let ((vs (if vocabs (cons :array vocabs) 'f))
        (us (or vocabs 't)))
    (fuel-eval--retort-result
     (fuel-eval--send/wait `(:fuel* (,prefix ,vs fuel-get-words) t ,us)))))


;;; Completions window handling, heavily inspired in slime's:

(defvar fuel-completion--comp-buffer "*Completions*")

(make-variable-buffer-local
 (defvar fuel-completion--window-cfg nil
   "Window configuration before we show the *Completions* buffer.
This is buffer local in the buffer where the completion is
performed."))

(make-variable-buffer-local
 (defvar fuel-completion--completions-window nil
   "The window displaying *Completions* after saving window configuration.
If this window is no longer active or displaying the completions
buffer then we can ignore `fuel-completion--window-cfg'."))

(defun fuel-completion--save-window-cfg ()
  "Maybe save the current window configuration.
Return true if the configuration was saved."
  (unless (or fuel-completion--window-cfg
              (get-buffer-window fuel-completion--comp-buffer))
    (setq fuel-completion--window-cfg
          (current-window-configuration))
    t))

(defun fuel-completion--delay-restoration ()
  (add-hook 'pre-command-hook
            'fuel-completion--maybe-restore-window-cfg
            nil t))

(defun fuel-completion--forget-window-cfg ()
  (setq fuel-completion--window-cfg nil)
  (setq fuel-completion--completions-window nil))

(defun fuel-completion--restore-window-cfg ()
  "Restore the window config if available."
  (remove-hook 'pre-command-hook
               'fuel-completion--maybe-restore-window-cfg)
  (when (and fuel-completion--window-cfg
             (fuel-completion--window-active-p))
    (save-excursion
      (set-window-configuration fuel-completion--window-cfg))
    (setq fuel-completion--window-cfg nil)
    (when (buffer-live-p fuel-completion--comp-buffer)
      (kill-buffer fuel-completion--comp-buffer))))

(defun fuel-completion--maybe-restore-window-cfg ()
  "Restore the window configuration, if the following command
terminates a current completion."
  (remove-hook 'pre-command-hook
               'fuel-completion--maybe-restore-window-cfg)
  (condition-case err
      (cond ((find last-command-char "()\"'`,# \r\n:")
             (fuel-completion--restore-window-cfg))
            ((not (fuel-completion--window-active-p))
             (fuel-completion--forget-window-cfg))
            (t (fuel-completion--delay-restoration)))
    (error
     ;; Because this is called on the pre-command-hook, we mustn't let
     ;; errors propagate.
     (message "Error in fuel-completion--restore-window-cfg: %S" err))))

(defun fuel-completion--window-active-p ()
  "Is the completion window currently active?"
  (and (window-live-p fuel-completion--completions-window)
       (equal (buffer-name (window-buffer fuel-completion--completions-window))
              fuel-completion--comp-buffer)))

(defun fuel-completion--display-comp-list (completions base)
  (let ((savedp (fuel-completion--save-window-cfg)))
    (with-output-to-temp-buffer fuel-completion--comp-buffer
      (display-completion-list completions base)
      (let ((offset (- (point) 1 (length base))))
        (with-current-buffer standard-output
          (setq completion-base-size offset)
          (set-syntax-table fuel-syntax--syntax-table))))
    (when savedp
      (setq fuel-completion--completions-window
            (get-buffer-window fuel-completion--comp-buffer)))))

(defun fuel-completion--display-or-scroll (completions base)
  (cond ((and (eq last-command this-command) (fuel-completion--window-active-p))
         (fuel-completion--scroll-completions))
        (t (fuel-completion--display-comp-list completions base)))
  (fuel-completion--delay-restoration))

(defun fuel-completion--scroll-completions ()
  (let ((window fuel-completion--completions-window))
    (with-current-buffer (window-buffer window)
      (if (pos-visible-in-window-p (point-max) window)
          (set-window-start window (point-min))
        (save-selected-window
          (select-window window)
          (scroll-up))))))


;;; Completion functionality:

(defun fuel-completion--word-list (prefix)
  (let* ((fuel-log--inhibit-p t)
         (cv (fuel-syntax--current-vocab))
         (vs (and cv `("syntax" ,cv ,@(fuel-syntax--usings)))))
    (fuel-completion--words prefix vs)))

(defsubst fuel-completion--all-words-list (prefix)
  (fuel-completion--words prefix nil))

(defvar fuel-completion--word-list-func
  (completion-table-dynamic 'fuel-completion--word-list))

(defvar fuel-completion--all-words-list-func
  (completion-table-dynamic 'fuel-completion--all-words-list))

(defun fuel-completion--complete (prefix vocabs)
  (let* ((words (if vocabs
                    (fuel-completion--vocabs)
                    (fuel-completion--word-list prefix)))
         (completions (all-completions prefix words))
         (partial (try-completion prefix words))
         (partial (if (eq partial t) prefix partial)))
    (cons completions partial)))

(defun fuel-completion--read-word (prompt &optional default history all)
  (let ((minibuffer-local-completion-map fuel-completion--minibuffer-map))
    (completing-read prompt
                     (if all fuel-completion--all-words-list-func
                       fuel-completion--word-list-func)
                     nil nil nil
                     history
                     (or default (fuel-syntax-symbol-at-point)))))

(defvar fuel-completion--vocab-history nil)

(defun fuel-completion--read-vocab (refresh &optional init-input)
  (let ((minibuffer-local-completion-map fuel-completion--minibuffer-map)
        (vocabs (fuel-completion--vocabs refresh))
        (prompt "Vocabulary name: "))
    (if vocabs
        (completing-read prompt vocabs nil nil init-input fuel-completion--vocab-history)
      (read-string prompt init-input fuel-completion--vocab-history))))

(defun fuel-completion--complete-symbol ()
  "Complete the symbol at point.
Perform completion similar to Emacs' complete-symbol."
  (interactive)
  (let* ((end (point))
         (beg (fuel-syntax--beginning-of-symbol-pos))
         (prefix (buffer-substring-no-properties beg end))
         (result (fuel-completion--complete prefix (fuel-syntax--in-using)))
         (completions (car result))
         (partial (cdr result)))
    (cond ((null completions)
           (fuel--respecting-message "Can't find completion for %S" prefix)
           (fuel-completion--restore-window-cfg))
          (t (insert-and-inherit (substring partial (length prefix)))
             (cond ((= (length completions) 1)
                    (fuel--respecting-message "Sole completion")
                    (fuel-completion--restore-window-cfg))
                   (t (fuel--respecting-message "Complete but not unique")
                      (fuel-completion--display-or-scroll completions
                                                          partial)))))))


(provide 'fuel-completion)
;;; fuel-completion.el ends here
