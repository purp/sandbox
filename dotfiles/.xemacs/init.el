; -*- lisp -*-
(setq load-path (cons (expand-file-name "~/.xemacs/") load-path))
(add-to-list 'load-path "~/.xemacs/tramp/lisp/")
(add-to-list 'Info-directory-list "~/emacs/tramp/texi/")




(cond ((string-match "XEmacs\\|Lucid" emacs-version)
       ;; Startup files for XEmacs (19.xx?)
       (load-library "xemacs-general")
       (load-library "xemacs-macros")
       (load-library "xemacs-keys")
       (load-library "xemacs-packages")
;       (load-library "xemacs-mail")
       (load-library "xemacs-c")
       (load-library "tramp")
       (load-library "follow")
;       (load-library "xemacs-c++")
;       (load-library "xemacs-latex")
;       (load-library "xemacs-idl")
       (message "Startup files loaded succesfully.")))

(setq minibuffer-max-depth nil)
