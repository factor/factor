(require 'comint)

(define-derived-mode factor-listener-mode comint-mode "Factor listener"
  (setq comint-prompt-regexp "^  "))

(defvar factor-binary "/scratch/factor-darcs/repos/Factor/f")
(defvar factor-image "/scratch/factor-darcs/repos/Factor/factor.image")

(defun factor-server ()
  (interactive)
  (make-comint "factor-server" factor-binary nil factor-image "-shell=tty")
  (comint-send-string "*factor-server*" "USE: jedit telnet\n"))

;; (defun factor-listener ()
;;   (interactive)
;;   (factor-server)
;;   (sleep-for 0 500)
;;   (switch-to-buffer (make-comint "factor-listener" '("localhost" . 9999)))
;;   (rename-uniquely)
;;   (factor-listener-mode))

(defun factor-listener ()
  (interactive)
  (factor-server)
  (sleep-for 0 1000)
  (if (get-buffer "*factor-listener*")
      (save-excursion
	(set-buffer "*factor-listener*")
	(rename-uniquely)))
  (switch-to-buffer (make-comint "factor-listener" '("localhost" . 9999)))
  (factor-listener-mode))

(defun factor-listener-restart ()
  (interactive)
  (factor-server)
  (sleep-for 0 1000)
  (make-comint-in-buffer
   "factor-listener" (current-buffer) '("localhost" . 9999)))

(defun load-factor-file (file-name)
  (interactive "fLoad Factor file: ")
  (comint-send-string nil (format "\"%s\" run-file\n" file-name)))

(defun factor-update-stack-buffer (&optional string)
  (interactive)
  (save-excursion
    (set-buffer (get-buffer-create "*factor-stack*"))
    (erase-buffer)
    (comint-redirect-send-command-to-process
     ".s" "*factor-stack*" "*factor-listener*" nil)))

(defvar factor-update-stackp nil "*")

(defun factor-send-input ()
  (interactive)
  (comint-send-input)
  (if factor-update-stackp
      (progn (sleep-for 0 250) (factor-update-stack-buffer))))

(defun factor-synopsis ()
  (interactive)
  (message
   (first
    (comint-redirect-results-list-from-process 
     (get-buffer-process "*factor-listener*")
     (format "\\ %s synopsis print" (thing-at-point 'symbol))
     ;; "[ ]*\\(.*\\)\n"
     "\\(.*\\)\n"
     1))))

(fset 'factor-comment-line "\C-a! ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mode

;; syntax table

;; (push '("\\.factor\\'" . factor-mode) auto-mode-alist)

;; synopsis of word at point