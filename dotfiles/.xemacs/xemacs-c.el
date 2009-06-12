;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			Customization of C Mode			    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'cc-mode)

;; Definition of my own indentation style
(setq c-style-alist
      (append '(("Erik"
		 (c-basic-offset . 4)
		 (c-comment-only-line-offset . 0)
		 (c-offsets-alist . ((statement-block-intro . +)
		      (knr-argdecl-intro . 5)
		      (substatement-open . +)
		      (case-label . +)
		      (label . -)
		      (statement-cont . +)
		      (arglist-intro . c-lineup-arglist-intro-after-paren)
		      (arglist-close . c-lineup-arglist)))))
	      c-style-alist))

;; Initialisations for C-mode
(add-hook 'c-mode-hook 
  (function
    (lambda () 
      (c-set-style "Erik")
      (define-key c-mode-map '(f9)                 'compile)
      (define-key c-mode-map '(f10)                'next-error)
      (define-key c-mode-map '(shift f10)          'previous-error)
)))
