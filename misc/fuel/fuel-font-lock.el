;;; fuel-font-lock.el -- font lock for factor code

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Wed Dec 03, 2008 21:40

;;; Comentary:

;; Font lock setup for highlighting Factor code.

;;; Code:

(require 'fuel-base)
(require 'fuel-syntax)

(require 'font-lock)


;;; Faces:

(defmacro fuel-font-lock--make-face (prefix def-prefix group face def doc)
  (let ((face (intern (format "%s-%s" prefix face)))
        (def (intern (format "%s-%s-face" def-prefix def))))
    `(defface ,face (face-default-spec ,def)
       ,(format "Face for %s." doc)
       :group ',group
       :group 'faces)))

(defmacro fuel-font-lock--define-faces (prefix def-prefix group faces)
  (let ((setup (make-symbol (format "%s--faces-setup" prefix))))
  `(progn
     (defmacro ,setup ()
       (cons 'progn
             (mapcar (lambda (f) (append '(fuel-font-lock--make-face
                                      ,prefix ,def-prefix ,group) f))
                     ',faces)))
     (,setup))))


;;; Font lock:

(defconst fuel-font-lock--parsing-lock-keywords
  (cons '("\\(P\\|SBUF\\)\"" 1 'factor-font-lock-parsing-word)
        (mapcar (lambda (w) `(,(format "\\(^\\| \\)\\(%s\\)\\($\\| \\)" w)
                         2 'factor-font-lock-parsing-word))
                fuel-syntax--parsing-words)))

(defconst fuel-font-lock--font-lock-keywords
  `(,@fuel-font-lock--parsing-lock-keywords
    (,fuel-syntax--stack-effect-regex . 'factor-font-lock-stack-effect)
    (,fuel-syntax--parsing-words-ext-regex . 'factor-font-lock-parsing-word)
    (,fuel-syntax--declaration-words-regex 1 'factor-font-lock-declaration)
    (,fuel-syntax--word-definition-regex 2 'factor-font-lock-word)
    (,fuel-syntax--type-definition-regex 2 'factor-font-lock-type-name)
    (,fuel-syntax--method-definition-regex (1 'factor-font-lock-type-name)
                                           (2 'factor-font-lock-word))
    (,fuel-syntax--parent-type-regex 1 'factor-font-lock-type-name)
    (,fuel-syntax--constructor-regex . 'factor-font-lock-constructor)
    (,fuel-syntax--setter-regex . 'factor-font-lock-setter-word)
    (,fuel-syntax--symbol-definition-regex 2 'factor-font-lock-symbol)
    (,fuel-syntax--use-line-regex 1 'factor-font-lock-vocabulary-name))
  "Font lock keywords definition for Factor mode.")

(defun fuel-font-lock--font-lock-setup (&optional keywords no-syntax)
  (set (make-local-variable 'comment-start) "! ")
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (set (make-local-variable 'font-lock-comment-face) 'factor-font-lock-comment)
  (set (make-local-variable 'font-lock-string-face) 'factor-font-lock-string)
  (set (make-local-variable 'font-lock-defaults)
       `(,(or keywords 'fuel-font-lock--font-lock-keywords)
         nil nil nil nil
         ,@(if no-syntax nil
             (list (cons 'font-lock-syntactic-keywords
                         fuel-syntax--syntactic-keywords))))))


(provide 'fuel-font-lock)
;;; fuel-font-lock.el ends here
