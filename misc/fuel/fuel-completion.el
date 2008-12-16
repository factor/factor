;;; fuel-completion.el -- completion utilities

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
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

(defsubst fuel-completion--words (prefix vocabs)
  (fuel-eval--retort-result
   (fuel-eval--send/wait `(:fuel* (,prefix V{ ,@vocabs } fuel-get-words) t ,vocabs))))


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

(defun fuel-completion--maybe-save-window-configuration ()
  "Maybe save the current window configuration.
Return true if the configuration was saved."
  (unless (or fuel-completion--window-cfg
              (get-buffer-window fuel-completion--comp-buffer))
    (setq fuel-completion--window-cfg
          (current-window-configuration))
    t))

(defun fuel-completion--delay-restoration ()
  (add-hook 'pre-command-hook
            'fuel-completion--maybe-restore-window-configuration
            nil t))

(defun fuel-completion--forget-window-configuration ()
  (setq fuel-completion--window-cfg nil)
  (setq fuel-completion--completions-window nil))

(defun fuel-completion--restore-window-configuration ()
  "Restore the window config if available."
  (remove-hook 'pre-command-hook
               'fuel-completion--maybe-restore-window-configuration)
  (when (and fuel-completion--window-cfg
             (fuel-completion--window-active-p))
    (save-excursion
      (set-window-configuration fuel-completion--window-cfg))
    (setq fuel-completion--window-cfg nil)
    (when (buffer-live-p fuel-completion--comp-buffer)
      (kill-buffer fuel-completion--comp-buffer))))

(defun fuel-completion--maybe-restore-window-configuration ()
  "Restore the window configuration, if the following command
terminates a current completion."
  (remove-hook 'pre-command-hook
               'fuel-completion--maybe-restore-window-configuration)
  (condition-case err
      (cond ((find last-command-char "()\"'`,# \r\n:")
             (fuel-completion--restore-window-configuration))
            ((not (fuel-completion--window-active-p))
             (fuel-completion--forget-window-configuration))
            (t (fuel-completion--delay-restoration)))
    (error
     ;; Because this is called on the pre-command-hook, we mustn't let
     ;; errors propagate.
     (message "Error in fuel-completion--restore-window-configuration: %S" err))))

(defun fuel-completion--window-active-p ()
  "Is the completion window currently active?"
  (and (window-live-p fuel-completion--completions-window)
       (equal (buffer-name (window-buffer fuel-completion--completions-window))
              fuel-completion--comp-buffer)))

(defun fuel-completion--display-comp-list (completions base)
  (let ((savedp (fuel-completion--maybe-save-window-configuration)))
    (with-output-to-temp-buffer fuel-completion--comp-buffer
      (display-completion-list completions)
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

(defsubst fuel-completion--word-list (prefix)
  (let ((fuel-log--inhibit-p t))
    (fuel-completion--words
     prefix `("syntax" ,(fuel-syntax--current-vocab) ,@(fuel-syntax--usings)))))

(defun fuel-completion--complete (prefix)
  (let* ((words (fuel-completion--word-list prefix))
         (completions (all-completions prefix words))
         (partial (try-completion prefix words))
         (partial (if (eq partial t) prefix partial)))
    (cons completions partial)))

(defun fuel-completion--complete-symbol ()
  "Complete the symbol at point.
Perform completion similar to Emacs' complete-symbol."
  (interactive)
  (let* ((end (point))
         (beg (fuel-syntax--symbol-start))
         (prefix (buffer-substring-no-properties beg end))
         (result (fuel-completion--complete prefix))
         (completions (car result))
         (partial (cdr result)))
    (cond ((null completions)
           (fuel--respecting-message "Can't find completion for %S" prefix)
           (fuel-completion--restore-window-configuration))
          (t (insert-and-inherit (substring partial (length prefix)))
             (cond ((= (length completions) 1)
                    (fuel--respecting-message "Sole completion")
                    (fuel-completion--restore-window-configuration))
                   (t (fuel--respecting-message "Complete but not unique")
                      (fuel-completion--display-or-scroll completions
                                                          partial)))))))


(provide 'fuel-completion)
;;; fuel-completion.el ends here
