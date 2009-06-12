;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	       Customization of VM and Mail mode		    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'vm)

;; Install tm MIME extensions for VM
(load "mime-setup")
(require 'tm-vm)

;; Delete message and move forward to next message
(defun vm-delete-message-forward ()
  "Delete message and move forward to next message"
  (interactive)
  (vm-delete-message 1)
  (vm-next-message)
)

;; Definition of mail aliases
;(define-mail-alias "yannic"      "zinka4u@yahoo.com")
;(define-mail-alias "rudi"        "rudi.voet@pandora.be")
;(define-mail-alias "evo"         "evo@argo.be")
;(define-mail-alias "vina"        "lty@skynet.be")
;(define-mail-alias "lars"        "Lars_Machenil@MCKINSEY.COM")
;(define-mail-alias "yvdh"        "Yves.VanderHaeghen@rug.ac.be")
;(define-mail-alias "yves"        "y.pollet@advalvas.be")
;(define-mail-alias "veerle"      "veerle@inwfaxp1.rug.ac.be")
;(define-mail-alias "bartel"      "bvdwalle@sckcen.be")
;(define-mail-alias "sylvie"      "Sylvie.VanOostende@europe.ppdi.com")
;(define-mail-alias "michael"     "mbentein@unicall.be")
;(define-mail-alias "arnaud"      "A.Schmitz@rw.be")
;(define-mail-alias "joan"        "Joan.WILLEMEN@is.belgacom.be")
;(define-mail-alias "michel"      "Michel.Tison@rug.ac.be")
;(define-mail-alias "nadine"      "NADINE.RAMAEKERS@SD.be")
;(define-mail-alias "david"       "davidk@ch.twi.tudelft.nl")
;(define-mail-alias "hugo"        "mediorsoftware@mail.seagha.com")
;(define-mail-alias "kurt"        "GOVAERT@NSCL.MSU.EDU")
;(define-mail-alias "pol"         "pdesmedt@ms.philips.nl")
;(define-mail-alias "bdp"         "bdp@blackadder.lmsal.com")
;(define-mail-alias "bv"          "bart.vinck@vnet.atea.be")
;(define-mail-alias "phil"        "Philippe_Verplancke@mckinsey.com")
;(define-mail-alias "filip"       "fvanhave@sckcen.be")
;(define-mail-alias "wim"         "wivermei@cordius.be")
;(define-mail-alias "joost"       "grillaer@imec.be")
;(define-mail-alias "jean"        "jean_verswijvelen@argo.be")
;(define-mail-alias "jeff"        "74170.3434@compuserve.com")
;(define-mail-alias "eddy"        "Eddy.Moerloose@rug.ac.be")
;(define-mail-alias "carry"       "CVMIDDEL@vdab.be")
;(define-mail-alias "ronny"       "Ronny.Blomme@elis.rug.ac.be")
;(define-mail-alias "herwig"      "Herwig.VanMarck@elis.rug.ac.be")
;(define-mail-alias "ignace"      "Ignace.Lemahieu@elis.rug.ac.be")
;(define-mail-alias "jvc"         "Jan.VanCampenhout@elis.rug.ac.be")
;(define-mail-alias "wilfried"    "Wilfried.Philips@elis.rug.ac.be")
;(define-mail-alias "koen"        "Koen.Denecker@elis.rug.ac.be")
;(define-mail-alias "jeroen"      "jevoverl@bacob.be")
;(define-mail-alias "peter"       "Peter.DeNeve@elis.rug.ac.be")
;(define-mail-alias "krista"      "krista@elis.rug.ac.be")
;(define-mail-alias "kdb"         "Koen.DeBosschere@elis.rug.ac.be")
;(define-mail-alias "review"      "Peter.Veelaert@elis.rug.ac.be")
;(define-mail-alias "vincent"     "vincent@conde.inescn.pt")
;(define-mail-alias "rik"         "rik@mri2.rug.ac.be")
;(define-mail-alias "judge"       "judge@morrolan.eff.org")
;(define-mail-alias "savoini"     "Philippe.SAVOINI@cetp.ipsl.fr")
;(define-mail-alias "ralf"        "srp@egnetz.uebemc.siemens.de")
;(define-mail-alias "ingrid"      "P82500@vnet.atea.be")
;(define-mail-alias "pedro"       "Pedro.Tytgat@ping.be")
;(define-mail-alias "carnac"      "carnac@innet.be")
;(define-mail-alias "alpha"       "alpha-osf-managers@ornl.gov")
;(define-mail-alias "xemacs"      "xemacs@cs.uiuc.edu")

;; Name of file to write all outgoing messages in, or nil for none
(setq mail-archive-file-name "MAILED")

;; Address to insert as default Reply-to field of outgoing messages
;(setq mail-default-reply-to "Erik.Sundermann@advalvas.be")

;; Don't split up large messages before sending
(setq mime-editor/split-message nil)

;; Mail is moved from the system mailbox to this file for reading
(setq vm-primary-inbox "~/Mail/INCOMING")

;; Directory where folders of mail are kept
(setq vm-folder-directory "~/Mail/")

;; Non-nil value causes VM to automatically move mail from spool files
;; to a mail folder when the folder is first visited.  
(setq vm-auto-get-new-mail t)

; If `vm-preview-lines' is `nil', then previewing is not done at all; when 
; a message is first presented it is immediately exposed in its entirety 
; and is flagged as read.
(setq vm-preview-lines nil)

; Non-nil value causes VM's `d' command to automatically invoke vm-next-message
; or vm-previous-message after deleting, to move past the deleted messages.
(setq vm-move-after-deleting 1)

; This is a regular expression that matches the names of headers that should
; be highlighted when a message is first presented.  
(setq vm-highlighted-header-regexp "From:\\|Subject:")

; The value of `vm-visible-headers' should be a list of regular expressions 
; matching the beginnings of headers that should be made visible when a 
; message is presented.
(setq vm-visible-headers (list "From:" "Sender:" "To:" "Apparently-To:" 
   "Resent-" "Reply-To:" "Cc:" "Subject:" "Date:"))

; The variable `vm-invisible-header-regexp' specifies what headers should 
; *not* be displayed ; if the value of vm-invisible-header-regexp is nil, 
; only the headers matched by vm-visible-headers will be displayed.
(setq vm-invisible-header-regexp nil)

; VM automatically marks messages for deletion after successfully saving 
; them to a folder, or after successfully auto-archiving them with the 
; vm-auto-archive-messages command.
(setq vm-delete-after-saving "yes")
(setq vm-delete-after-archiving "yes")

; A string that VM should add to the beginning of the Subject header in 
; replies, if the string is not already present.
(setq vm-reply-subject-prefix "Re: ")

; String used to prefix included text in replies.
(setq vm-included-text-prefix " > ")

; List of headers that should be forwarded by vm-forward-message. These should
; be listed in the order you wish them to appear in the forwarded message. If 
; the value of vm-unforwarded-header-regexp is nil, the headers matched by 
; vm-forwarded-headers are the only headers that will be forwarded.
(setq vm-forwarded-headers '("From:" "To:" "Subject:" "Date:"))
(setq vm-unforwarded-header-regexp nil)

; String which specifies the format of the contents of the Subject header 
; that is generated for a forwarded message.  
(setq vm-forwarding-subject-format "(forwarded) %s")

; The variable `vm-startup-with-summary' controls wether VM automatically 
; displays a summary of the folder's contents at startup.
(setq vm-startup-with-summary "yes")

; The variable `vm-auto-center-summary' controls wether VM will keep the 
; summary arrow vertically centered within the summary window. 
(setq vm-auto-center-summary t)

; String which specifies the message summary line format.
; Original value = "%n %*%a %-17.17F %-3.3m %2d %4l/%-5c %I\"%s\"\n"
(setq vm-summary-format "%n %*[%4a] %2d %-3.3m %4y  %-20.20F  %s\n")

; VM will search for URLs in messages and pass them to Netscape
(setq browse-url-browser-function 'vm-mouse-send-url-to-netscape)
(setq vm-url-browser 'vm-mouse-send-url-to-netscape)

; List of addresses that you don't consider interesting enough to
; appear in the summary.
(setq vm-summary-uninteresting-senders (user-login-name))

; This is an alist that VM will use to choose a default folder name when 
; messages are saved.
;(setq vm-auto-folder-alist '(("Sender:"
;			         ("owner-anneal@zuni.chaco.com" . "ANNEAL")
;				 ("Digital Equipment Corporation" . "DECNEWS")
;				 ("marion@cas.et.tudelft.nl" . "PRORISC")
;				 ("@Newswire.Microsoft.com" . "MICROSOFT")
;				 ("alpha-osf-managers-relay" . "OSF"))
;			     ("From:"
;				 ("@Newswire.Microsoft.com" . "MICROSOFT"))
;			     ("To:"
;			         ("xemacs@" . "XEMACS")
;				 ("list-civ2@" . "CIV2")
;				 ("prorisc@" . "PRORISC")
;				 ("ruginfo@" . "RUGELIS")
;				 ("rugannounce@" . "RUGELIS")
;				 ("elisannounce@" . "RUGELIS")
;				 ("elispersoneel@" . "RUGELIS")
;				 ("ELISPERSONEEL@" . "RUGELIS")
;				 ("allusers@elis" . "RUGELIS")
;				 ("oapFTW@" . "RUGELIS")
;				 ("oap@" . "RUGELIS"))
;                             ("Reply-To:" 
;			         ("info-mi-service@MOM.SPIE.ORG" . "SPIE-MI"))
;                             ("Return-Path:" 
;				 ("daemon@cti-pet.com" . "ECAT")
;				 ("physnews@aip.org" . "PHYSNEWS")
;                                 ("owner-xemacs" . "XEMACS")
;                                 ("xemacs-request" . "XEMACS"))
;			     ("Subject:"
;			         ("MSR" . "MSR")
;			         ("Microsoft" . "MICROSOFT")
;			         ("proletter" . "PRORISC")
;				 ("[Oo][Aa][Pp]" . "RUGELIS")
;				 ("[Ll]eona" . "LEONA"))))


;; Initialisations for VM-mode
(add-hook 'vm-mode-hook
  (function
    (lambda ()
      (define-key vm-mode-map '(a)    'vm-auto-archive-messages)
      (define-key vm-mode-map '(c)    'vm-mail)
      ;; (define-key vm-mode-map '(d)    'vm-delete-message-forward)
      (define-key vm-mode-map '(f)    'vm-forward-message)
      ;; Don't make backups of the VM folders
      (make-local-variable 'make-backup-files)
      (setq make-backup-files nil)
      (require 'highlight-headers)
      (make-face-bold      'message-headers)
      (make-face-unitalic  'message-headers)
      (set-face-foreground 'message-headers "black")
      (make-face-unbold    'message-header-contents)
      (make-face-unitalic  'message-header-contents)
      (set-face-foreground 'message-header-contents "blue")
      (make-face-bold      'message-highlighted-header-contents)
      (make-face-unitalic  'message-highlighted-header-contents)
      (set-face-foreground 'message-highlighted-header-contents "blue")
      (make-face-unbold    'message-cited-text)
      (make-face-unitalic  'message-cited-text)
      (set-face-foreground 'message-cited-text "medium orchid")
)))

;; Initialisations for mail-mode
(add-hook 'mail-mode-hook 
  (function
    (lambda () 
      (define-key mail-mode-map '(control prior)  'gse-unbury-buffer)
      (define-key mail-mode-map '(control next)   'gse-bury-buffer)
      (turn-on-auto-fill)
)))

