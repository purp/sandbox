;;; mel-mode.el --- Maya Embedded Language (MEL) code editing commands 
;;;                 for GNU Emacs

;; Copyright (C) 2000  Free Software Foundation, Inc.

;; Author: Jim Meyer
;; Maintainer: JEM
;; Adapted-By: JEM
;; Keywords: languages

;; Adapted from Perl code editing commands 'perl-mode.el', Copyright 1994
;; by the Free Software Foundation, under terms of its General Public License.

;; This file is part of XEmacs.

;; XEmacs is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; XEmacs is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with XEmacs; see the file COPYING.  If not, write to the 
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Synched up with: FSF 19.30.

;;; Commentary:

;; To enter mel-mode automatically, add (autoload 'mel-mode "mel-mode")
;; to your .emacs file and change the first line of your mel script to:
;; // -*-Mel-*-

;; This code is based on the 19.30 version perl-mode.el, with extensive
;; rewriting. Many thanks to William F. Mann for his original effort
;; in deriving perl-mode.el from c-mode.el, as well as to Eric S. Raymond
;; for later adaptation of it. Everything in here is stolen directly from
;; their efforts with whatever modifications were needed to work in MEL.

;; I added a new feature which adds functionality to TAB; it is controlled
;; by the variable perl-tab-to-comment.  With it enabled, TAB does the
;; first thing it can from the following list:  change the indentation;
;; move past leading white space; delete an empty comment; reindent a
;; comment; move to end of line; create an empty comment; tell you that
;; the line ends in a quoted string, or has a # which should be a \#.

;; If your machine is slow, you may want to remove some of the bindings
;; to electric-perl-terminator.  I changed the indenting defaults to be
;; what Larry Wall uses in perl/lib, but left in all the options.

;; I also tuned a few things:  comments and labels starting in column
;; zero are left there by indent-perl-exp; perl-beginning-of-function
;; goes back to the first open brace/paren in column zero, the open brace
;; in 'sub ... {', or the equal sign in 'format ... ='; indent-perl-exp
;; (meta-^q) indents from the current line through the close of the next
;; brace/paren, so you don't need to start exactly at a brace or paren.

;; It may be good style to put a set of redundant braces around your
;; main program.  This will let you reindent it with meta-^q.

;; Known problems (these are all caused by limitations in the Emacs Lisp
;; parsing routine (parse-partial-sexp), which was not designed for such
;; a rich language; writing a more suitable parser would be a big job):
;; 1)  Regular expression delimiters do not act as quotes, so special
;;       characters such as `'"#:;[](){} may need to be backslashed
;;       in regular expressions and in both parts of s/// and tr///.
;; 2)  The globbing syntax <pattern> is not recognized, so special
;;       characters in the pattern string must be backslashed.
;; 3)  The q, qq, and << quoting operators are not recognized; see below.
;; 4)  \ (backslash) always quotes the next character, so '\' is
;;       treated as the start of a string.  Use "\\" as a work-around.
;; 5)  To make variables such a $' and $#array work, perl-mode treats
;;       $ just like backslash, so '$' is the same as problem 5.
;; 6)  Unfortunately, treating $ like \ makes ${var} be treated as an
;;       unmatched }.  See below.
;; 7)  When ' (quote) is used as a package name separator, perl-mode
;;       doesn't understand, and thinks it is seeing a quoted string.

;; Here are some ugly tricks to bypass some of these problems:  the perl
;; expression /`/ (that's a back-tick) usually evaluates harmlessly,
;; but will trick perl-mode into starting a quoted string, which
;; can be ended with another /`/.  Assuming you have no embedded
;; back-ticks, this can used to help solve problem 3:
;;
;;     /`/; $ugly = q?"'$?; /`/;
;;
;; To solve problem 6, add a /{/; before each use of ${var}:
;;     /{/; while (<${glob_me}>) ...
;;
;; Problem 7 is even worse, but this 'fix' does work :-(
;;     $DB'stop#'
;;         [$DB'line#'
;;          ] =~ s/;9$//;


;;; Code:

(defvar mel-mode-abbrev-table nil
  "Abbrev table in use in mel-mode buffers.")
(define-abbrev-table 'mel-mode-abbrev-table ())

(defvar mel-mode-map ()
  "Keymap used in Mel mode.")
(if mel-mode-map
    ()
  (setq mel-mode-map (make-sparse-keymap))
  (set-keymap-name mel-mode-map 'mel-mode-map)
  (define-key mel-mode-map "{" 'electric-mel-terminator)
  (define-key mel-mode-map "}" 'electric-mel-terminator)
  (define-key mel-mode-map ";" 'electric-mel-terminator)
  (define-key mel-mode-map ":" 'electric-mel-terminator)
  (define-key mel-mode-map "\e\C-a" 'mel-beginning-of-function)
  (define-key mel-mode-map "\e\C-e" 'mel-end-of-function)
  (define-key mel-mode-map "\e\C-h" 'mark-mel-function)
  (define-key mel-mode-map "\e\C-q" 'indent-mel-exp)
  (define-key mel-mode-map "\t" 'mel-indent-command))

(autoload 'c-macro-expand "cmacexp"
  "Display the result of expanding all C macros occurring in the region.
The expansion is entirely correct because it uses the C preprocessor."
  t)

(defvar mel-mode-syntax-table nil
  "Syntax table in use in mel-mode buffers.")

(if mel-mode-syntax-table
    ()
  (setq mel-mode-syntax-table (make-syntax-table (standard-syntax-table)))
  (modify-syntax-entry ?\n ">" mel-mode-syntax-table)
  (modify-syntax-entry ?/ "<1" mel-mode-syntax-table)
  (modify-syntax-entry ?/ "<2" mel-mode-syntax-table)
  (modify-syntax-entry ?$ "\\" mel-mode-syntax-table)
  (modify-syntax-entry ?% "." mel-mode-syntax-table)
  (modify-syntax-entry ?& "." mel-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" mel-mode-syntax-table)
  (modify-syntax-entry ?* "." mel-mode-syntax-table)
  (modify-syntax-entry ?+ "." mel-mode-syntax-table)
  (modify-syntax-entry ?- "." mel-mode-syntax-table)
  (modify-syntax-entry ?/ "." mel-mode-syntax-table)
  (modify-syntax-entry ?< "." mel-mode-syntax-table)
  (modify-syntax-entry ?= "." mel-mode-syntax-table)
  (modify-syntax-entry ?> "." mel-mode-syntax-table)
  (modify-syntax-entry ?` "\"" mel-mode-syntax-table)
  (modify-syntax-entry ?| "." mel-mode-syntax-table)
)

;(defvar mel-imenu-generic-expression
;  '(
;    ;; Functions
;    (nil "^sub\\s-+\\([-A-Za-z0-9+_:]+\\)\\(\\s-\\|\n\\)*{" 1 )
;    ;;Variables
;    ("Variables" "^\\([$@%][-A-Za-z0-9+_:]+\\)\\s-*=" 1 )
;    )
;  "Imenu generic expression for Mel mode.  See `imenu-generic-expression'.")

;(defvar mel-font-lock-keywords (purecopy
;  (list
;;   ("if" "until" "while" "elsif" "else" "unless" "for" "foreach" "continue"
;;    "exit" "die" "last" "goto" "next" "redo" "return" "local" "exec")
;   (concat "\\<\\("
;	   "continue\\|die\\|e\\(ls\\(e\\|if\\)\\|x\\(ec\\|it\\)\\)\\|"
;	   "for\\(\\|each\\)\\|goto\\|if\\|l\\(ast\\|ocal\\)\\|next\\|"
;	   "re\\(do\\|turn\\)\\|un\\(less\\|til\\)\\|while"
;	   "\\)\\>")
;;   ("#endif" "#else" "#ifdef" "#ifndef" "#if" "#include" "#define" "#undef")
;   (cons (concat "#\\(define\\|e\\(lse\\|ndif\\)\\|"
;		 "i\\(f\\(\\|def\\|ndef\\)\\|nclude\\)\\|undef\\)\\>")
;	 'font-lock-reference-face)
;   '("^[ \n\t]*sub[ \t]+\\([^ \t{]+\\)[ \t]*[{]" 1 font-lock-function-name-face)
;   '("[ \n\t{]*\\(eval\\)[ \n\t(;]" 1 font-lock-function-name-face)
;   '("\\(--- .* ---\\|=== .* ===\\)" . font-lock-string-face)
;   ))
;  "Additional expressions to highlight in Mel mode.")

;A similar version.
;(defconst mel-font-lock-keywords (purecopy
;  (list
;   (cons (concat "[ \n\t{]*\\("
;		 (mapconcat 'identity
;			    '("if" "until" "while" "elsif" "else" "unless"
;			      "for" "foreach" "continue" "exit" "die" "last"
;			      "goto" "next" "redo" "return" "local" "exec")
;			    "\\|")
;		 "\\)[ \n\t;(]")
;	 1)
;        (mapconcat 'identity
;                   '("#endif" "#else" "#ifdef" "#ifndef" "#if" "#include"
;                     "#define" "#undef")
;                   "\\|")
;        '("^[ \n\t]*sub[ \t]+\\([^ \t{]+\\)[ \n\t]*\\{"
;          1 font-lock-function-name-face)
;        '("[ \n\t{]*\\(eval\\)[ \n\t(;]" 
;          1 font-lock-function-name-face)
;        ;; '("\\(--- .* ---\\|=== .* ===\\)" 1 font-lock-doc-string-face)
;        ))
;  "Additional expressions to highlight in Mel mode.")

(put 'mel-mode 'font-lock-defaults '(mel-font-lock-keywords))

(defvar mel-indent-level 2
  "*Indentation of Mel statements with respect to containing block.")
(defvar mel-continued-statement-offset 2
  "*Extra indent for lines not starting new statements.")
(defvar mel-continued-brace-offset -4
  "*Extra indent for substatements that start with open-braces.
This is in addition to `mel-continued-statement-offset'.")
(defvar mel-brace-offset 0
  "*Extra indentation for braces, compared with other text in same context.")
(defvar mel-brace-imaginary-offset 0
  "*Imagined indentation of an open brace that actually follows a statement.")
(defvar mel-label-offset -2
  "*Offset of Mel label lines relative to usual indentation.")

(defvar mel-tab-always-indent t
  "*Non-nil means TAB in Mel mode always indents the current line.
Otherwise it inserts a tab character if you type it past the first
nonwhite character on the line.")

;; I changed the default to nil for consistency with general Emacs
;; conventions -- rms.
(defvar mel-tab-to-comment nil
  "*Non-nil means TAB moves to eol or makes a comment in some cases.
For lines which don't need indenting, TAB either indents an
existing comment, moves to end-of-line, or if at end-of-line already,
create a new comment.")

;(defvar mel-nochange ";?#\\|\f\\|\\s(\\|\\(\\w\\|\\s_\\)+:"
;  "*Lines starting with this regular expression are not auto-indented.")

(defvar mel-mode-hook nil
  "Invoked on entry to mel-mode.")


;;; bluck. ;;;###autoload
(defun mel-mode ()
  "Major mode for editing Maya Embedded Language (MEL) code.
Expression and list commands understand all MEL brackets.
Tab indents for MEL code.
Comments are delimited with // ... \\n.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.
\\{mel-mode-map}
Variables controlling indentation style:
 mel-tab-always-indent
    Non-nil means TAB in Mel mode should always indent the current line,
    regardless of where in the line point is when the TAB command is used.
 mel-tab-to-comment
    Non-nil means that for lines which don't need indenting, TAB will
    either delete an empty comment, indent an existing comment, move 
    to end-of-line, or if at end-of-line already, create a new comment.
 mel-nochange
    Lines starting with this regular expression are not auto-indented.
 mel-indent-level
    Indentation of Mel statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 mel-continued-statement-offset
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 mel-continued-brace-offset
    Extra indentation given to a brace that starts a substatement.
    This is in addition to `mel-continued-statement-offset'.
 mel-brace-offset
    Extra indentation for line if it starts with an open brace.
 mel-brace-imaginary-offset
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.
 mel-label-offset
    Extra indentation for line that is a label.

Various indentation styles:       K&R  BSD  BLK  GNU  LW
  mel-indent-level                5    8    0    2    4
  mel-continued-statement-offset  5    8    4    2    4
  mel-continued-brace-offset      0    0    0    0   -4
  mel-brace-offset               -5   -8    0    0    0
  mel-brace-imaginary-offset      0    0    4    0    0
  mel-label-offset               -5   -8   -2   -2   -2

Turning on Mel mode runs the normal hook `mel-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (use-local-map mel-mode-map)
  (setq major-mode 'mel-mode)
  (setq mode-name "MEL")
  (setq local-abbrev-table mel-mode-abbrev-table)
  (set-syntax-table mel-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'mel-indent-line)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "# ")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "\\(^\\|\\s-\\);?//+ *")
  (make-local-variable 'comment-indent-function)
  (setq comment-indent-function 'mel-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  ;; Tell imenu how to handle Mel.
;  (make-local-variable 'imenu-generic-expression)
;  (setq imenu-generic-expression mel-imenu-generic-expression)
  (run-hooks 'mel-mode-hook))

;; This is used by indent-for-comment
;; to decide how much to indent a comment in Mel code
;; based on its context.
(defun mel-comment-indent ()
  (if (and (bolp) (not (eolp)))
      0					;Existing comment at bol stays there.
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp)			;Else indent at comment column
	       0			; except leave at least one space if
	     (1+ (current-column)))	; not at beginning of line.
	   comment-column))))

(defun electric-mel-terminator (arg)
  "Insert character and adjust indentation.
If at end-of-line, and not in a comment or a quote, correct the's indentation."
  (interactive "P")
  (let ((insertpos (point)))
    (and (not arg)			; decide whether to indent
	 (eolp)
	 (save-excursion
	   (beginning-of-line)
	   (and (not			; eliminate comments quickly
		 (re-search-forward comment-start-skip insertpos t)) 
		(or (/= last-command-char ?:)
		    ;; Colon is special only after a label ....
		    (looking-at "\\s-*\\(\\w\\|\\s_\\)+$"))
		(let ((pps (parse-partial-sexp 
			    (mel-beginning-of-function) insertpos)))
		  (not (or (nth 3 pps) (nth 4 pps) (nth 5 pps))))))
	 (progn				; must insert, indent, delete
	   (insert-char last-command-char 1)
	   (mel-indent-line)
	   (delete-char -1))))
  (self-insert-command (prefix-numeric-value arg)))

;; not used anymore, but may be useful someday:
;;(defun mel-inside-parens-p ()
;;  (condition-case ()
;;      (save-excursion
;;	(save-restriction
;;	  (narrow-to-region (point)
;;			    (mel-beginning-of-function))
;;	  (goto-char (point-max))
;;	  (= (char-after (or (scan-lists (point) -1 1) (point-min))) ?\()))
;;    (error nil)))

(defun mel-indent-command (&optional arg)
  "Indent current line as MEL code, or optionally, insert a tab character.

With an argument, indent the current line, regardless of other options.

If `mel-tab-always-indent' is nil and point is not in the indentation
area at the beginning of the line, simply insert a tab.

Otherwise, indent the current line.  If point was within the indentation
area it is moved to the end of the indentation area.  If the line was
already indented promely and point was not within the indentation area,
and if `mel-tab-to-comment' is non-nil (the default), then do the first
possible action from the following list:

  1) delete an empty comment
  2) move forward to start of comment, indenting if necessary
  3) move forward to end of line
  4) create an empty comment
  5) move backward to start of comment, indenting if necessary."
  (interactive "P")
  (if arg				; If arg, just indent this line
      (mel-indent-line "\f")
    (if (and (not mel-tab-always-indent)
	     (> (current-column) (current-indentation)))
	(insert-tab)
      (let (bof lsexp delta (oldpnt (point)))
	(beginning-of-line) 
	(setq lsexp (point))
	(setq bof (mel-beginning-of-function))
	(goto-char oldpnt)
	(setq delta (mel-indent-line "\f\\|;?#" bof))
	(and mel-tab-to-comment
	     (= oldpnt (point))		; done if point moved
	     (if (listp delta)		; if line starts in a quoted string
		 (setq lsexp (or (nth 2 delta) bof))
	       (= delta 0))		; done if indenting occurred
	     (let (eol state)
	       (end-of-line) 
	       (setq eol (point))
	       (if (= (char-after bof) ?=)
		   (if (= oldpnt eol)
		       (message "In a format statement"))     
		 (setq state (parse-partial-sexp lsexp eol))
		 (if (nth 3 state)
		     (if (= oldpnt eol)	; already at eol in a string
			 (message "In a string which starts with a %c."
				  (nth 3 state)))
		   (if (not (nth 4 state))
		       (if (= oldpnt eol) ; no comment, create one?
			   (indent-for-comment))
		     (beginning-of-line)
		     (if (re-search-forward comment-start-skip eol 'move)
			 (if (eolp)
			     (progn	; kill existing comment
			       (goto-char (match-beginning 0))
			       (skip-chars-backward " \t")
			       (kill-region (point) eol))
			   (if (or (< oldpnt (point)) (= oldpnt eol))
			       (indent-for-comment) ; indent existing comment
			     (end-of-line)))
		       (if (/= oldpnt eol)
			   (end-of-line)
			 (message "Use backslash to quote # characters.")
			 (ding t))))))))))))

(defun mel-indent-line (&optional nochange parse-start)
  "Indent current line as MEL code.
Return the amount the indentation 
changed by, or (parse-state) if line starts in a quoted string."
  (let ((case-fold-search nil)
	(pos (- (point-max) (point)))
	(bof (or parse-start (save-excursion (mel-beginning-of-function))))
	beg indent shift-amt)
    (beginning-of-line)
    (setq beg (point))
    (setq shift-amt
	  (cond ((= (char-after bof) ?=) 0)
		((listp (setq indent (calculate-mel-indent bof))) indent)
		((looking-at (or nochange mel-nochange)) 0)
		(t
		 (skip-chars-forward " \t\f")
		 (cond ((looking-at "\\(\\w\\|\\s_\\)+:")
			(setq indent (max 1 (+ indent mel-label-offset))))
		       ((= (following-char) ?})
			(setq indent (- indent mel-indent-level)))
		       ((= (following-char) ?{)
			(setq indent (+ indent mel-brace-offset))))
		 (- indent (current-column)))))
    (skip-chars-forward " \t\f")
    (if (and (numberp shift-amt) (/= 0 shift-amt))
	(progn (delete-region beg (point))
	       (indent-to indent)))
    ;; If initial point was within line's indentation,
    ;; position after the indentation.  Else stay at same point in text.
    (if (> (- (point-max) pos) (point))
	(goto-char (- (point-max) pos)))
    shift-amt))

(defun calculate-mel-indent (&optional parse-start)
  "Return appropriate indentation for current line as MEL code.
In usual case returns an integer: the column to indent to.
Returns (parse-state) if line starts inside a string."
  (save-excursion
    (beginning-of-line)
    (let ((indent-point (point))
	  (case-fold-search nil)
	  (colon-line-end 0)
	  state containing-sexp)
      (if parse-start			;used to avoid searching
	  (goto-char parse-start)
	(mel-beginning-of-function))
      (while (< (point) indent-point)	;repeat until right sexp
	(setq parse-start (point))
	(setq state (parse-partial-sexp (point) indent-point 0))
; state = (depth_in_parens innermost_containing_list last_complete_sexp
;          string_terminator_or_nil inside_commentp following_quotep
;          minimum_paren-depth_this_scan)
; Parsing stops if depth in parentheses becomes equal to third arg.
	(setq containing-sexp (nth 1 state)))
      (cond ((nth 3 state) state)	; In a quoted string?
	    ((null containing-sexp)	; Line is at top level.
	     (skip-chars-forward " \t\f")
	     (if (= (following-char) ?{)
		 0   ; move to beginning of line if it starts a function body
	       ;; indent a little if this is a continuation line
	       (mel-backward-to-noncomment)
	       (if (or (bobp)
		       (memq (preceding-char) '(?\; ?\})))
		   0 mel-continued-statement-offset)))
	    ((/= (char-after containing-sexp) ?{)
	     ;; line is expression, not statement:
	     ;; indent to just after the surrounding open.
	     (goto-char (1+ containing-sexp))
	     (current-column))
	    (t
	     ;; Statement level.  Is it a continuation or a new statement?
	     ;; Find previous non-comment character.
	     (mel-backward-to-noncomment)
	     ;; Back up over label lines, since they don't
	     ;; affect whether our line is a continuation.
	     (while (or (eq (preceding-char) ?\,)
			(and (eq (preceding-char) ?:)
			     (memq (char-syntax (char-after (- (point) 2)))
				   '(?w ?_))))
	       (if (eq (preceding-char) ?\,)
		   (mel-backward-to-start-of-continued-exp containing-sexp)
		 (beginning-of-line))
	       (mel-backward-to-noncomment))
	     ;; Now we get the answer.
	     (if (not (memq (preceding-char) '(?\; ?\} ?\{)))
		 ;; This line is continuation of preceding line's statement;
		 ;; indent  mel-continued-statement-offset  more than the
		 ;; previous line of the statement.
		 (progn
		   (mel-backward-to-start-of-continued-exp containing-sexp)
		   (+ mel-continued-statement-offset (current-column)
		      (if (save-excursion (goto-char indent-point)
					  (looking-at "[ \t]*{"))
			  mel-continued-brace-offset 0)))
	       ;; This line starts a new statement.
	       ;; Position at last unclosed open.
	       (goto-char containing-sexp)
	       (or
		 ;; If open paren is in col 0, close brace is special
		 (and (bolp)
		      (save-excursion (goto-char indent-point)
				      (looking-at "[ \t]*}"))
		      mel-indent-level)
		 ;; Is line first statement after an open-brace?
		 ;; If no, find that first statement and indent like it.
		 (save-excursion
		   (forward-char 1)
		   ;; Skip over comments and labels following openbrace.
		   (while (progn
			    (skip-chars-forward " \t\f\n")
			    (cond ((looking-at ";?#")
				   (forward-line 1) t)
				  ((looking-at "\\(\\w\\|\\s_\\)+:")
				   (save-excursion 
				     (end-of-line) 
				     (setq colon-line-end (point)))
				   (search-forward ":")))))
		   ;; The first following code counts
		   ;; if it is before the line we want to indent.
		   (and (< (point) indent-point)
			(if (> colon-line-end (point))
			    (- (current-indentation) mel-label-offset)
			  (current-column))))
		 ;; If no previous statement,
		 ;; indent it relative to line brace is on.
		 ;; For open paren in column zero, don't let statement
		 ;; start there too.  If mel-indent-level is zero,
		 ;; use mel-brace-offset + mel-continued-statement-offset
		 ;; For open-braces not the first thing in a line,
		 ;; add in mel-brace-imaginary-offset.
		 (+ (if (and (bolp) (zerop mel-indent-level))
			(+ mel-brace-offset mel-continued-statement-offset)
		      mel-indent-level)
		    ;; Move back over whitespace before the openbrace.
		    ;; If openbrace is not first nonwhite thing on the line,
		    ;; add the mel-brace-imaginary-offset.
		    (progn (skip-chars-backward " \t")
			   (if (bolp) 0 mel-brace-imaginary-offset))
		    ;; If the openbrace is preceded by a parenthesized exp,
		    ;; move to the beginning of that;
		    ;; possibly a different line
		    (progn
		      (if (eq (preceding-char) ?\))
			  (forward-sexp -1))
		      ;; Get initial indentation of the line we are on.
		      (current-indentation))))))))))

(defun mel-backward-to-noncomment ()
  "Move point backward to after the first non-white-space, skipping comments."
  (interactive)
  (let (opoint stop)
    (while (not stop)
      (setq opoint (point))
      (beginning-of-line)
      (if (re-search-forward comment-start-skip opoint 'move 1)
	  (progn (goto-char (match-end 1))
		 (skip-chars-forward ";")))
      (skip-chars-backward " \t\f")
      (setq stop (or (bobp)
		     (not (bolp))
		     (forward-char -1))))))

(defun mel-backward-to-start-of-continued-exp (lim)
  (if (= (preceding-char) ?\))
      (forward-sexp -1))
  (beginning-of-line)
  (if (<= (point) lim)
      (goto-char (1+ lim)))
  (skip-chars-forward " \t\f"))

;; note: this may be slower than the c-mode version, but I can understand it.
(defun indent-mel-exp ()
  "Indent each line of the MEL grouping following point."
  (interactive)
  (let* ((case-fold-search nil)
	 (oldpnt (point-marker))
	 (bof-mark (save-excursion
		     (end-of-line 2)
		     (mel-beginning-of-function)
		     (point-marker)))
	 eol last-mark lsexp-mark delta)
    (if (= (char-after (marker-position bof-mark)) ?=)
	(message "Can't indent a format statement")
      (message "Indenting Mel expression...")
      (save-excursion (end-of-line) (setq eol (point)))
      (save-excursion			; locate matching close paren
	(while (and (not (eobp)) (<= (point) eol))
	  (parse-partial-sexp (point) (point-max) 0))
	(setq last-mark (point-marker)))
      (setq lsexp-mark bof-mark)
      (beginning-of-line)
      (while (< (point) (marker-position last-mark))
	(setq delta (mel-indent-line nil (marker-position bof-mark)))
	(if (numberp delta)		; unquoted start-of-line?
	    (progn 
	      (if (eolp)
		  (delete-horizontal-space))
	      (setq lsexp-mark (point-marker))))
	(end-of-line)
	(setq eol (point))
	(if (nth 4 (parse-partial-sexp (marker-position lsexp-mark) eol))
	    (progn			; line ends in a comment
	      (beginning-of-line)
	      (if (or (not (looking-at "\\s-*;?#"))
		      (listp delta)
		      (and (/= 0 delta)
			   (= (- (current-indentation) delta) comment-column)))
		  (if (re-search-forward comment-start-skip eol t)
		      (indent-for-comment))))) ; indent existing comment
	(forward-line 1))
      (goto-char (marker-position oldpnt))
      (message "Indenting Mel expression...done"))))

(defun mel-beginning-of-function (&optional arg)
  "Move backward to next beginning-of-function, or as far as possible.
With argument, repeat that many times; negative args move forward.
Returns new value of point in all cases."
  (interactive "p")
  (or arg (setq arg 1))
  (if (< arg 0) (forward-char 1))
  (and (/= arg 0)
       (re-search-backward "^\\s(\\|^\\s-*sub\\b[^{]+{\\|^\\s-*format\\b[^=]*=\\|^\\."
			   nil 'move arg)
       (goto-char (1- (match-end 0))))
  (point))

;; note: this routine is adapted directly from emacs lisp.el, end-of-defun;
;; no bugs have been removed :-)
(defun mel-end-of-function (&optional arg)
  "Move forward to next end-of-function.
The end of a function is found by moving forward from the beginning of one.
With argument, repeat that many times; negative args move backward."
  (interactive "p")
  (or arg (setq arg 1))
  (let ((first t))
    (while (and (> arg 0) (< (point) (point-max)))
      (let ((pos (point)))
	(while (progn
		(if (and first
			 (progn
			  (forward-char 1)
			  (mel-beginning-of-function 1)
			  (not (bobp))))
		    nil
		  (or (bobp) (forward-char -1))
		  (mel-beginning-of-function -1))
		(setq first nil)
		(forward-list 1)
		(skip-chars-forward " \t")
		(if (looking-at "[#\n]")
		    (forward-line 1))
		(<= (point) pos))))
      (setq arg (1- arg)))
    (while (< arg 0)
      (let ((pos (point)))
	(mel-beginning-of-function 1)
	(forward-sexp 1)
	(forward-line 1)
	(if (>= (point) pos)
	    (if (progn (mel-beginning-of-function 2) (not (bobp)))
		(progn
		  (forward-list 1)
		  (skip-chars-forward " \t")
		  (if (looking-at "[#\n]")
		      (forward-line 1)))
	      (goto-char (point-min)))))
      (setq arg (1+ arg)))))

(defun mark-mel-function ()
  "Put mark at end of MEL function, point at beginning."
  (interactive)
  (push-mark (point))
  (mel-end-of-function)
  (push-mark (point))
  (mel-beginning-of-function)
  (backward-paragraph))

(provide 'mel-mode)

;;; mel-mode.el ends here
