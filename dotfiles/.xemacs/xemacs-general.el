;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			Basic Customization			    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Delete and copy an entire line (from BOL)

(defun kill-entire-line(num)
  "delete entire line "
  (interactive "p")
  (beginning-of-line)
  (kill-line num)
  )

(defun copy-entire-line(num)
  "copy entire line "
  (interactive "p")
  (beginning-of-line)
  (kill-line num)
  (yank)
  )

;; Popup window with buffer list ; from XEmacs FAQ (2.61)

(defun cw-build-buffers ()
  "Popup buffer menu."
  (interactive "@")
  (run-hooks 'activate-menubar-hook)
  (popup-menu (car (find-menu-item current-menubar '("Buffers"))))
)

;; Navigate paragraphs
(defun previous-paragraph ()
	"Move to the beginning of the previous paragraph"
	(interactive)
  (or (eq last-command this-command)
      (backward-paragraph))
	(backward-paragraph)
	(end-of-line)
	(pc-select-move-char-right)
)

(defun next-paragraph ()
	"Move to the beginning of the next paragraph"
	(interactive)
	(search-forward-regexp "^[ \t]*$")
	(end-of-line)
	(pc-select-move-char-right)
)

;; Print buffer or region using a2ps

(defun print-buffer-a2ps ()
   "Print buffer using a2ps"
   (interactive)
   (let ((old-command lpr-command) 
         (old-switches lpr-switches)
         (a2ps-title "-HEmacs"))
      (cond ((not (eq buffer-file-name nil))
             (setq a2ps-title 
                 (concat "-H" (abbreviate-file-name (buffer-file-name) 1)))))
      (setq lpr-command "a2ps")
;      (setq lpr-switches (list "-Php" a2ps-title))
      (setq lpr-switches (list a2ps-title))
      (lpr-buffer)
      (setq lpr-command old-command)
      (setq lpr-switches old-switches))
)

(defun print-region-a2ps ()
   "Print selected text using a2ps"
   (interactive)
   (let ((old-command lpr-command) 
         (old-switches lpr-switches)
         (a2ps-title "-HEmacs"))
      (cond ((not (eq buffer-file-name nil))
             (setq a2ps-title 
                 (concat "-H" (abbreviate-file-name (buffer-file-name) 1)))))
      (setq lpr-command "a2ps")
      (setq lpr-switches (list "-Php" a2ps-title))
      (lpr-region (mark) (point))
      (setq lpr-command old-command)
      (setq lpr-switches old-switches))
)

;; Jump forward and backward through buffer list ; XEmacs mailing list

(defun gse-unbury-buffer ()
  "Switch to the buffer at the bottom of the buffer list, if it's not a
'hidden' buffer."
  (interactive)
  (let ((all-buffers (buffer-list))
        (done nil)
        (i 1))
    (setq i (- (length all-buffers) 1))
    (while (and (not done) (>= i 0))
      (let ((buf (nth i all-buffers))
            (first-char ""))
        (setq first-char (substring (buffer-name buf) 0 1))
        (if (not (or
                  (equal first-char "*")
                  (equal first-char " ")))
            (progn
              (switch-to-buffer buf)
              (setq done t))
          (setq i (- i 1))
          )))
    ))

(defun gse-bury-buffer ()
"Bury the current buffer until you find a non-'hidden' buffer."
(interactive)

(bury-buffer)
(let ((all-buffers (buffer-list))
      (done nil)
      (i 0))
  (while (and (not done) (<= i (length all-buffers)))
    (let ((buf (nth i all-buffers))
          (first-char ""))
      (setq first-char (substring (buffer-name buf) 0 1))
      (if (not (or
                (equal first-char "*")
                (equal first-char " ")))
          (progn
            (switch-to-buffer buf)
            (setq done t))
        (setq i (+ i 1))
        )))
  ))

;; perltidy functions
(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -q" nil t))
)

(defun perltidy-defun ()
  "Run perltidy on the current defun."
  (interactive)
  (save-excursion (mark-defun)
  (perltidy-region))
)


;; Customize the menubar

;; Add scrollbar-like buttons
; (add-menu-item nil "Top" 'beginning-of-buffer t)
; (add-menu-item nil "<<<" 'scroll-down t)
; (add-menu-item nil " . " 'recenter t)
; (add-menu-item nil ">>>" 'scroll-up t)
; (add-menu-item nil "Bot" 'end-of-buffer t)
;; Add `dired' to the File menu
(add-menu-item '("File") "Edit Directory" 'dired t "Exit XEmacs")
;; Add `print-...-a2ps' to the File and Edit menus
(add-menu-item '("File") "Print Buffer (a2ps)" 'print-buffer-a2ps t 
   "Print Buffer")
(add-menu-item '("Edit") "Print Region (a2ps)" 'print-region-a2ps t 
   "Start Macro Recording")
(add-menu-item '("Edit") "---" nil nil "Start Macro Recording")
;; Add `search-menu' to the Edit menu
(add-menu-item '("Edit") "Search Menu..." 'search-menu t "Search...")
(add-menu-item '("Edit") "---" nil nil "Search...")


;; Set the default, bold, italic, and bold-italic fonts (underline italics)
;; All the rest derive from these
(add-spec-list-to-specifier (face-property 'default 'font) '((global (nil . "-b&h-lucidatypewriter-medium-r-normal-sans-10-100-75-75-m-60-iso8859-1"))))
(add-spec-list-to-specifier (face-property 'bold 'font) '((global (nil . "-b&h-lucidatypewriter-bold-r-normal-sans-10-100-75-75-m-60-iso8859-1"))))
(add-spec-list-to-specifier (face-property 'italic 'font) '((global (nil . "-b&h-lucidatypewriter-bold-r-normal-sans-10-100-75-75-m-60-iso8859-1"))))
(add-spec-list-to-specifier (face-property 'italic 'underline) '((global ((tty) . t))))
(add-spec-list-to-specifier (face-property 'bold-italic 'font) '((global (nil . "-b&h-lucidatypewriter-bold-r-normal-sans-10-100-75-75-m-60-iso8859-1"))))
(add-spec-list-to-specifier (face-property 'bold-italic 'underline) '((global ((tty) . t))))

(set-face-background 'default	"grey50")

;; Gnuserv settings

;; Start the gnuserv process
(gnuserv-start)

;; Tell gnuserv not to create new windows for each file
(setq gnuserv-frame t)

;; If there are multiple frames, use the selected one for new files
(setq gnuserv-frame (selected-frame))



;; Customize various settings

;; Try to flash the frame instead of beep at error/message
;(setq visible-bell 1)

;; Display line numbers in the modeline
(line-number-mode 1)

;; Display column numbers in the modeline
(column-number-mode 1)

;; Automatically replace the selection if typing occurs
;;;;(pending-delete-mode 1)

;; Make the delete key delete the next character instead of the previous one
(custom-set-variables 
  '(delete-key-deletes-forward 1))

;; Set number of lines in a compilation window
(setq compilation-window-height 10)

;; Enable the command `narrow-to-region' ("C-x n n")
(put 'narrow-to-region 'disabled nil)

;; Enable the command `eval-expression' ("M-ESC", or "ESC ESC").  
(put 'eval-expression 'disabled nil)

;; Enable only one command in Buffers menu (select that buffer)
(setq complex-buffers-menu-p nil)

;; If this is true, then a buffer's visited file-name will always be
;; chased back to the real file; it will never be a symbolic link
(setq find-file-use-truenames t)

;; The find-file command will check the truenames of all visited files when 
;; deciding whether a given file is already in a buffer
(setq find-file-compare-truenames t)

;; In answers which are not valid completions, an extra RET must be typed 
;; to confirm the response.
(setq minibuffer-confirm-incomplete t)

;; If non-nil, `next-line' inserts newline to avoid `end of buffer' error
(setq next-line-add-newlines nil)

;; When running ispell, consider all 1-3 character words as correct.
(setq ispell-extra-args '("-W" "3"))

;; Set the modeline control for identifying the buffer being displayed.
(setq-default modeline-buffer-identification '("XEmacs: %17b"))
(setq modeline-buffer-identification '("XEmacs: %17b"))

;; Change the cursor used when the mouse is over a mode line
(setq x-mode-pointer-shape "leftbutton")

;; Set extra directory for Info pages
(setq Info-default-directory-list
    (append Info-default-directory-list '("/usr/local/lib/xemacs/site-info"
					  "/usr/local/info/" 
					  "/usr/local/lib/tex/info")))

;; Display matching parentheses
;(paren-set-mode 'paren)

;; Follow URL's via Netscape
(setq highlight-headers-follow-url-function
            'highlight-headers-follow-url-netscape)
(setq-default browse-url-browser-function 'browse-url-netscape)


;; Number of buffers to display in buffer list ; nill = all
(setq buffers-menu-max-size nil)

;; Change the cursor used during garbage collection.
(if (featurep 'xpm)
    (let ((file (expand-file-name "recycle.xpm" data-directory)))
      (if (condition-case error
	      (make-cursor file)    ; returns a cursor if successful.
	    (error nil))	    ; returns nil if an error occurred.
	  (setq x-gc-pointer-shape file))))

;; Avoid deactivation of region when buffer end or beginning is reached
;; XEmacs mailing list ; schrod@iti.informatik.th-darmstadt.de
;;;; (defadvice line-move (around catch-buffer-border-error activate)
;;;;   "Catch errors `beginning-of-buffer' or `end-of-buffer' to avoid
;;;; deactivation of region"
;;;;   (condition-case ()
;;;;       ad-do-it
;;;;     ((beginning-of-buffer end-of-buffer) (ding nil 'buffer-bound))))

;; Add additional extensions and their appropriate modes
(setq auto-mode-alist
      (append '(("\\.C$"       . c++-mode)
		("\\.cc$"      . c++-mode)
		("\\.hh$"      . c++-mode)
		("\\.c$"       . c-mode)
		("\\.h$"       . c-mode)
		("\\.eps$"     . postscript-mode)
		("\\.fvwmrc$"  . fvwm-mode)
		("\\.pro$"     . idl-mode))
	      auto-mode-alist))
