;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                    Customization of MEL Mode                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'cc-mode)

;; Definition of my own indentation style
(setq c-style-alist
      (append '(("Erik"
		 (c-basic-offset . 2)
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

;; Load all program modules for simulated annealing
(defun ann-load ()
  "Load most ann-files into buffers"
  (interactive)
  (find-file "~/source/ann_contour.c")
  (find-file "~/source/ann_costf.c")
  (find-file "~/source/ann_general.c")
  (find-file "~/source/ann_imIO.c")
  (find-file "~/source/ann_output.c")
  (find-file "~/source/ann_param.c")
  (find-file "~/source/ann_prior.c")
  (find-file "~/source/ann_project.c")
  (find-file "~/source/ann.h")
  (find-file "~/source/annproj.c")
  (find-file "~/source/ann.c")
  (find-file "~/source/makefile")
)


;; Initialisations for C-mode
(add-hook 'c-mode-hook 
  (function
    (lambda () 
      (c-set-style "Erik")
      (define-key c-mode-map '(f9)                 'compile)
      (define-key c-mode-map '(f10)                'next-error)
      (define-key c-mode-map '(shift f10)          'previous-error)
)))
