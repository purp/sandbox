;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Customization of Specific Packages		    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define font-lock keywords for BibTeX mode
(defvar bibtex-font-lock-keywords
  '( 
     ("^\\(@[a-zA-Z]+\\)[ {]" 1 font-lock-keyword-face)
     ("^@\\([a-zA-Z]+\\) *{\\([^,\n]+\\)" 2 font-lock-function-name-face)
     ("=[ \t]*\\([0-9]+\\)[,\n]" 1 font-lock-type-face)
;    ("\\([a-zA-Z]+\\) *=" 1 font-lock-type-face)
;    ("[^a-zA-Z][aA][uU][tT][hH][oO][rR][ \t]*=[ \t]*{\\(.+\\)}[,\n]" 
;     1 font-lock-string-face nil)
;    ("[^a-zA-Z][aA][uU][tT][hH][oO][rR][ \t]*=[ \t]*\\"\\(.+\\)\\"[,\n]" 
;     1 font-lock-string-face nil)
;    ("[^a-zA-Z][aA][uU][tT][hH][oO][rR][ \t]*=[ \t]*``\\(.+\\)[,\n]''" 
;     1 font-lock-string-face nil)
;    ("[^a-zA-Z][tT][iI][tT][lL][eE][ \t]*=[ \t]*{\\(.+\\)}[,\n]" 
;     1 font-lock-doc-string-face nil)
;    ("[^a-zA-Z][tT][iI][tT][lL][eE][ \t]*=[ \t]*\\"\\(.+\\)\\"[,\n]" 
;     1 font-lock-doc-string-face nil)
;    ("[^a-zA-Z][tT][iI][tT][lL][eE][ \t]*=[ \t]*``\\(.+\\)''[,\n]" 
;     1 font-lock-doc-string-face nil)
;    ("=[ \t]*{\\(.+\\)}[,\n]" 1 font-lock-string-face)
;    ("=[ \t]*\"\\(.+\\)\"[,\n]" 1 font-lock-comment-face)
;    ("=[ \t]*``\\(.+\\)''[,\n]" 1 font-lock-doc-string-face)
    )
  "font-lock keywords for BibTeX mode")

;; Load and  customize the Font-Lock syntax-highlighting package
(require 'font-lock)
(add-hook 'font-lock-mode-hook  'turn-on-fast-lock)
(setq fast-lock-cache-directories '("~/.xemacs/fast-lock/"))
(set-face-foreground  'default                      "black")
(set-face-background  'default                      "grey60")
; Face to use for comments
(set-face-foreground  'font-lock-comment-face       "grey80")
; Face to use for function and variable names
(set-face-foreground  'font-lock-function-name-face "blue")
(make-face-bold       'font-lock-function-name-face)
(set-face-foreground  'font-lock-variable-name-face "blue")
(make-face-bold       'font-lock-variable-name-face)
; Face to use for strings and documentation strings
(set-face-foreground  'font-lock-string-face        "blue4")
(set-face-foreground  'font-lock-doc-string-face    "blue4")
; Face to use for preprocessor commands
(set-face-foreground  'font-lock-preprocessor-face  "green4")
(make-face-bold       'font-lock-preprocessor-face)
; Face to use for keywords
(set-face-foreground  'font-lock-keyword-face  "blue3")
(make-face-bold       'font-lock-keyword-face)
; Face to use for reference names
(set-face-foreground  'font-lock-reference-face  "red3")
(make-face-bold       'font-lock-reference-face)
; Face to use for type names
(set-face-foreground  'font-lock-type-face          "yellow4")
(make-face-bold       'font-lock-type-face)
;(set-face-underline-p 'font-lock-string-face nil)
;(make-face-unitalic   'font-lock-string-face)
;(make-face-unitalic   'font-lock-doc-string-face)
;(make-face-unitalic   'font-lock-comment-face)
;(make-face-unitalic   'font-lock-function-name-face)
;(make-face-unitalic   'font-lock-type-face)
(add-hook 'emacs-lisp-mode-hook	'turn-on-font-lock)
(add-hook 'lisp-mode-hook	'turn-on-font-lock)
(add-hook 'c-mode-hook		'turn-on-font-lock)
(add-hook 'c++-mode-hook	'turn-on-font-lock)
(add-hook 'perl-mode-hook	'turn-on-font-lock)
(add-hook 'tex-mode-hook	'turn-on-font-lock)
(add-hook 'bibtex-mode-hook	'turn-on-font-lock)
(add-hook 'texinfo-mode-hook	'turn-on-font-lock)
(add-hook 'postscript-mode-hook	'turn-on-font-lock)
(add-hook 'dired-mode-hook	'turn-on-font-lock)
(add-hook 'ada-mode-hook	'turn-on-font-lock)
(add-hook 'idl-mode-hook	'turn-on-font-lock)

;; Load the func-menu package (menubar entry for function definitions)
(require 'func-menu)
(add-hook 'find-file-hooks 'fume-add-menubar-entry)

;; Load search-menu, a popup window for control search and replace
;(cond ((not (eq (locate-library "search-menu") nil))
;       (load-library "search-menu")))

;; Load the auto-save.el package, which lets you put all of your autosave
;; files in one place, instead of scattering them around the file system.
(require 'auto-save)
(setq auto-save-directory (expand-file-name "~/.xemacs/autosaves/")
      auto-save-directory-fallback auto-save-directory
      auto-save-hash-p nil
      auto-save-interval 2000)

;; Load a partial-completion mechanism
(load-library "completer")

;; Load crypt, a package for automatically decoding and reencoding files
(require 'crypt)
(setq crypt-encryption-type 'pgp   ; default encryption mechanism
      crypt-confirm-password t)	   ; make sure new passwords are correct

;; Load fvwm-mode, a mode for editing fvwm's config files
(autoload 'fvwm-mode "fvwm-mode" "Mode for editing fvwm's config files" t)

;; Load pc-select-mode, PC shift selection minor mode
(cond ((not (eq (locate-library "pc-select") nil))
       (load-library "pc-select")
       (pc-select-mode)))

;; Load n3 mode for RDF
(autoload 'n3-mode "n3-mode" "Major mode for OWL or N3 files" t)
