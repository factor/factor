;;; fuel-help.el -- accessing Factor's help system

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Wed Dec 03, 2008 21:41

;;; Comentary:

;; Modes and functions interfacing Factor's 'see' and 'help'
;; utilities, as well as an ElDoc-based autodoc mode.

;;; Code:

(require 'fuel-edit)
(require 'fuel-eval)
(require 'fuel-markup)
(require 'fuel-autodoc)
(require 'fuel-completion)
(require 'fuel-syntax)
(require 'fuel-font-lock)
(require 'fuel-popup)
(require 'fuel-base)

(require 'button)


;;; Customization:

(defgroup fuel-help nil
  "Options controlling FUEL's help system."
  :group 'fuel)

(defcustom fuel-help-always-ask t
  "When enabled, always ask for confirmation in help prompts."
  :type 'boolean
  :group 'fuel-help)

(defcustom fuel-help-history-cache-size 50
  "Maximum number of pages to keep in the help browser cache."
  :type 'integer
  :group 'fuel-help)

(defcustom fuel-help-bookmarks nil
  "Bookmars. Maintain this list using the help browser."
  :type 'list
  :group 'fuel-help)


;;; Help browser history:

(defun fuel-help--make-history ()
  (list nil                                        ; current
        (make-ring fuel-help-history-cache-size)   ; previous
        (make-ring fuel-help-history-cache-size))) ; next

(defsubst fuel-help--history-current ()
  (car fuel-help--history))

(defun fuel-help--history-push (link)
  (unless (equal link (car fuel-help--history))
    (let ((next (fuel-help--history-next)))
      (unless (equal link next)
        (when next (fuel-help--history-previous))
        (ring-insert (nth 1 fuel-help--history) (car fuel-help--history))
        (setcar fuel-help--history link))))
  link)

(defun fuel-help--history-next (&optional forget-current)
  (when (not (ring-empty-p (nth 2 fuel-help--history)))
    (when (and (car fuel-help--history) (not forget-current))
      (ring-insert (nth 1 fuel-help--history) (car fuel-help--history)))
    (setcar fuel-help--history (ring-remove (nth 2 fuel-help--history) 0))))

(defun fuel-help--history-previous (&optional forget-current)
  (when (not (ring-empty-p (nth 1 fuel-help--history)))
    (when (and (car fuel-help--history) (not forget-current))
      (ring-insert (nth 2 fuel-help--history) (car fuel-help--history)))
    (setcar fuel-help--history (ring-remove (nth 1 fuel-help--history) 0))))

(defvar fuel-help--history (fuel-help--make-history))


;;; Page cache:

(defun fuel-help--history-current-content ()
  (fuel-help--cache-get (car fuel-help--history)))

(defvar fuel-help--cache (make-hash-table :weakness 'key :test 'equal))

(defsubst fuel-help--cache-get (name)
  (gethash name fuel-help--cache))

(defsubst fuel-help--cache-insert (name str)
  (puthash name str fuel-help--cache))

(defsubst fuel-help--cache-clear ()
  (clrhash fuel-help--cache))


;;; Fuel help buffer and internals:

(fuel-popup--define fuel-help--buffer
  "*fuel help*" 'fuel-help-mode)


(defvar fuel-help--prompt-history nil)

(make-local-variable
 (defvar fuel-help--buffer-link nil))

(defun fuel-help--read-word (see)
  (let* ((def (fuel-syntax-symbol-at-point))
         (prompt (format "See%s help on%s: " (if see " short" "")
                         (if def (format " (%s)" def) "")))
         (ask (or (not def) fuel-help-always-ask)))
    (if ask
        (fuel-completion--read-word prompt
                                        def
                                        'fuel-help--prompt-history
                                        t)
      def)))

(defun fuel-help--word-help (&optional see word)
  (let ((def (or word (fuel-help--read-word see))))
    (when def
      (let ((cmd `(:fuel* (,def ,(if see 'fuel-word-see 'fuel-word-help))
                          "fuel" t)))
        (message "Looking up '%s' ..." def)
        (let* ((ret (fuel-eval--send/wait cmd))
               (res (fuel-eval--retort-result ret)))
          (if (not res)
              (message "No help for '%s'" def)
            (fuel-help--insert-contents (list def def 'word) res)))))))

(defun fuel-help--get-article (name label)
  (message "Retrieving article ...")
  (let* ((name (if (listp name) (cons :seq name) name))
         (cmd `(:fuel* ((,name fuel-get-article)) "fuel" t))
         (ret (fuel-eval--send/wait cmd))
         (res (fuel-eval--retort-result ret)))
    (if (not res)
        (message "Article '%s' not found" label)
      (fuel-help--insert-contents (list name label 'article) res)
      (message ""))))

(defun fuel-help--get-vocab (name)
  (message "Retrieving help vocabulary for vocabulary '%s' ..." name)
  (let* ((cmd `(:fuel* ((,name fuel-vocab-help)) "fuel" (,name)))
         (ret (fuel-eval--send/wait cmd))
         (res (fuel-eval--retort-result ret)))
    (if (not res)
        (message "No help available for vocabulary '%s'" name)
      (fuel-help--insert-contents (list name name 'vocab) res)
      (message ""))))

(defun fuel-help--get-vocab/author (author)
  (message "Retrieving vocabularies by %s ..." author)
  (let* ((cmd `(:fuel* ((,author fuel-get-vocabs/author)) "fuel" t))
         (ret (fuel-eval--send/wait cmd))
         (res (fuel-eval--retort-result ret)))
    (if (not res)
        (message "No vocabularies by %s" author)
      (fuel-help--insert-contents (list author author 'author) res)
      (message ""))))

(defun fuel-help--get-vocab/tag (tag)
  (message "Retrieving vocabularies tagged '%s' ..." tag)
  (let* ((cmd `(:fuel* ((,tag fuel-get-vocabs/tag)) "fuel" t))
         (ret (fuel-eval--send/wait cmd))
         (res (fuel-eval--retort-result ret)))
    (if (not res)
        (message "No vocabularies tagged '%s'" tag)
      (fuel-help--insert-contents (list tag tag 'tag) res)
      (message ""))))

(defun fuel-help--follow-link (link label type &optional no-cache)
  (let* ((llink (list link label type))
         (cached (and (not no-cache) (fuel-help--cache-get llink))))
    (if (not cached)
        (let ((fuel-help-always-ask nil))
          (cond ((eq type 'word) (fuel-help--word-help nil link))
                ((eq type 'article) (fuel-help--get-article link label))
                ((eq type 'vocab) (fuel-help--get-vocab link))
                ((eq type 'author) (fuel-help--get-vocab/author label))
                ((eq type 'tag) (fuel-help--get-vocab/tag label))
                ((eq type 'bookmarks) (fuel-help-display-bookmarks))
                (t (error "Links of type %s not yet implemented" type))))
      (fuel-help--insert-contents llink cached))))

(defun fuel-help--insert-contents (key content)
  (let ((hb (fuel-help--buffer))
        (inhibit-read-only t)
        (font-lock-verbose nil))
    (set-buffer hb)
    (erase-buffer)
    (if (stringp content)
        (insert content)
      (fuel-markup--print content)
      (fuel-markup--insert-newline)
      (delete-blank-lines)
      (fuel-help--cache-insert key (buffer-string)))
    (fuel-help--history-push key)
    (setq fuel-help--buffer-link key)
    (set-buffer-modified-p nil)
    (fuel-popup--display)
    (goto-char (point-min))
    (message "")))


;;; Bookmarks:

(defun fuel-help-bookmark-page ()
  "Add current help page to bookmarks."
  (interactive)
  (let ((link fuel-help--buffer-link))
    (unless link (error "No link associated to this page"))
    (add-to-list 'fuel-help-bookmarks link)
    (customize-save-variable 'fuel-help-bookmarks fuel-help-bookmarks)
    (message "Bookmark '%s' saved" (cadr link))))

(defun fuel-help-delete-bookmark ()
  "Delete link at point from bookmarks."
  (interactive)
  (let ((link (fuel-markup--link-at-point)))
    (unless link (error "No link at point"))
    (unless (member link fuel-help-bookmarks)
      (error "'%s' is not bookmarked" (cadr link)))
    (customize-save-variable 'fuel-help-bookmarks
                             (remove link fuel-help-bookmarks))
    (message "Bookmark '%s' delete" (cadr link))
    (fuel-help-display-bookmarks)))

(defun fuel-help-display-bookmarks ()
  "Display bookmarked pages."
  (interactive)
  (let ((links (mapcar (lambda (l) (cons '$subsection l)) fuel-help-bookmarks)))
    (unless links (error "No links to display"))
    (fuel-help--insert-contents '("bookmarks" "Bookmars" bookmarks)
                                `(article "Bookmarks" ,links))))


;;; Interactive help commands:

(defun fuel-help-short ()
  "See help summary of symbol at point."
  (interactive)
  (fuel-help--word-help t))

(defun fuel-help ()
  "Show extended help about the symbol at point, using a help
buffer."
  (interactive)
  (fuel-help--word-help))

(defun fuel-help-vocab (vocab)
  "Ask for a vocabulary name and show its help page."
  (interactive (list (fuel-completion--read-vocab nil)))
  (fuel-help--get-vocab vocab))

(defun fuel-help-next (&optional forget-current)
  "Go to next page in help browser.
With prefix, the current page is deleted from history."
  (interactive "P")
  (let ((item (fuel-help--history-next forget-current)))
    (unless item (error "No next page"))
    (apply 'fuel-help--follow-link item)))

(defun fuel-help-previous (&optional forget-current)
  "Go to previous page in help browser.
With prefix, the current page is deleted from history."
  (interactive "P")
  (let ((item (fuel-help--history-previous forget-current)))
    (unless item (error "No previous page"))
    (apply 'fuel-help--follow-link item)))

(defun fuel-help-kill-page ()
  "Kill current page if a previous or next one exists."
  (interactive)
  (condition-case nil
      (fuel-help-previous t)
    (error (fuel-help-next t))))

(defun fuel-help-refresh ()
  "Refresh the contents of current page."
  (interactive)
  (when fuel-help--buffer-link
    (apply 'fuel-help--follow-link (append fuel-help--buffer-link '(t)))))

(defun fuel-help-clean-history ()
  "Clean up the help browser cache of visited pages."
  (interactive)
  (when (y-or-n-p "Clean browsing history? ")
    (fuel-help--cache-clear)
    (setq fuel-help--history (fuel-help--make-history))
    (fuel-help-refresh))
  (message ""))

(defun fuel-help-edit ()
  "Edit the current article or word help."
  (interactive)
  (let ((link (car fuel-help--buffer-link))
        (type (nth 2 fuel-help--buffer-link)))
    (cond ((eq type 'word) (fuel-edit-word-doc-at-point nil link))
          ((member type '(article vocab)) (fuel-edit--edit-article link))
          (t (error "No document associated with this page")))))


;;;; Help mode map:

(defvar fuel-help-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (set-keymap-parent map button-buffer-map)
    (define-key map "a" 'fuel-apropos)
    (define-key map "ba" 'fuel-help-bookmark-page)
    (define-key map "bb" 'fuel-help-display-bookmarks)
    (define-key map "bd" 'fuel-help-delete-bookmark)
    (define-key map "c" 'fuel-help-clean-history)
    (define-key map "e" 'fuel-help-edit)
    (define-key map "h" 'fuel-help)
    (define-key map "k" 'fuel-help-kill-page)
    (define-key map "n" 'fuel-help-next)
    (define-key map "l" 'fuel-help-previous)
    (define-key map "p" 'fuel-help-previous)
    (define-key map "r" 'fuel-help-refresh)
    (define-key map "v" 'fuel-help-vocab)
    (define-key map (kbd "SPC")  'scroll-up)
    (define-key map (kbd "S-SPC") 'scroll-down)
    (define-key map "\M-." 'fuel-edit-word-at-point)
    (define-key map "\C-cz" 'run-factor)
    (define-key map "\C-c\C-z" 'run-factor)
    map))


;;; IN: support

(defun fuel-help--find-in ()
  (save-excursion
    (or (fuel-syntax--find-in)
        (and (goto-char (point-min))
             (re-search-forward "Vocabulary: \\(.+\\)$" nil t)
             (match-string-no-properties 1)))))


;;; Help mode definition:

(defun fuel-help-mode ()
  "Major mode for browsing Factor documentation.
\\{fuel-help-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (buffer-disable-undo)
  (use-local-map fuel-help-mode-map)
  (set-syntax-table fuel-syntax--syntax-table)
  (setq mode-name "FUEL Help")
  (setq major-mode 'fuel-help-mode)
  (setq fuel-syntax--current-vocab-function 'fuel-help--find-in)
  (setq fuel-markup--follow-link-function 'fuel-help--follow-link)
  (setq buffer-read-only t))


(provide 'fuel-help)
;;; fuel-help.el ends here
