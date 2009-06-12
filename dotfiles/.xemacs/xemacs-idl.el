(cond ((not (eq (locate-library "idl") nil))
       (autoload 'idl-mode "idl" "Major mode for editing IDL .pro files" t)))

(add-hook 'idl-mode-hook
   (function 
     (lambda ()
       (setq idl-block-indent 3          ; Indentation settings
	     idl-main-block-indent 3
	     idl-end-offset -3
	     idl-continuation-indent 1
	     idl-begin-line-comment "^\;[^\;]" 	; Leave ";" but not ";;" 
					        ; anchored at start of line
	     idl-surround-by-blank t     ; Turn on padding symbols =,<,>, etc.
	     abbrev-mode 1		; Turn on abbrevs (-1 for off)
	     ;; If abbrev-mode is off, then case changes (the next 2 lines)
	     ;; will not occur.
	     idl-reserved-word-upcase t  ; Change reserved words to upper case
	     idl-abbrev-change-case nil  ; Don't force case of expansions
	     idl-pad-keyword nil         ; Remove spaces for keyword assign '='
	     idl-hang-indent-regexp ": " ; Change from "- "
	     idl-show-block nil          ; Turn off blinking to matching begin
	     idl-abbrev-move t           ; Allow abbrevs to move backwards
	     case-fold-search nil)       ; Make searches case sensitive

       (easy-menu-add idl-menu idl-mode-map)

       ;; Run other functions here

       (idl-auto-fill-mode 1)	; Turn off auto filling
       ;; Pad with with 1 space (if -n is used then make the 
       ;; padding a minimum of n spaces.)  The defaults use -1
       ;; instead of 1.
       (idl-action-and-binding "=" '(idl-expand-equal 1 1))
       (idl-action-and-binding "<" '(idl-surround 1 1))
       (idl-action-and-binding ">" '(idl-surround 1 1))
       (idl-action-and-binding "&" '(idl-surround 1 1))
       ;; Only pad after comma and with exactly 1 space
       (idl-action-and-binding "," '(idl-surround nil 1))
       ;; Set some personal bindings
       ;; (In this case, makes `,' have the normal self-insert behavior.)
       (local-set-key "," 'self-insert-command)
       ;; Create a newline, indenting the original and new line.
       ;; A similar function that does _not_ reindent the original
       ;; line is on "\C-j" (The default for emacs programming modes).
       (local-set-key "\n" 'idl-newline)
)))
