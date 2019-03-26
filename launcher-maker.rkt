#lang racket/gui
(require "gui.rkt")

;;; purpose

; to generate a launcher file automatically
; sudo launcher-maker

;;; defs

(define *appname* "Desktop Shortcut Maker")
(define *home-dir-path*
  (path->string (find-system-path 'home-dir)))

(define (show-application-dialog title)

  (define result #f)

  (define (maybe-text field)
    (let ((s (send field get-value)))
      (if (non-empty-string? s) s #f)))
  
  (define (ok-callback)
    (set! result (list (maybe-text program-name-text-field)
                       (maybe-text icon-path-text-field)
                       (maybe-text binary-path-text-field)))
    (send dialog-frame show #f))
 
  (define dialog-frame
    ;             My Program v1.0              
    (centered-frame *appname* 320 100))

  (define program-name-text-field
    ;__________________________________________
    (text-field dialog-frame "Program Name:"))
  
  (define icon-path-text-field
    ;____________________________  Browse... 
    (text-field-browse-combo dialog-frame "Program Icon:"))

  (define binary-path-text-field
    ;____________________________  Browse... 
    (text-field-browse-combo dialog-frame "Program Binary:"))

  (define-values (cancel-button ok-button)
    ;                    Cancel       OK    
    (cancel-ok-combo dialog-frame ok-callback))
  
  (send dialog-frame show #t)
  result)

;;; main

; show dialog
(define user-selections (show-application-dialog *appname*))
(when (not user-selections) (exit 0))

; extract and check data
(define app-name (first user-selections))
(when (not app-name) (exit 1))

(define path-to-icon (second user-selections))
(when (not path-to-icon) (exit 1))

(define path-to-bin (third user-selections))
(when (not path-to-bin) (exit 1))

; build shortcut contents
(define file-contents
  (list "[Desktop Entry]"
        (string-append "Name=" app-name)
        (string-append "Exec=" path-to-bin)
        (string-append "Icon=" path-to-icon)
        "Type=Application"))

; write shortcut file
(let* ((shortcut              (string-downcase (string-replace app-name " " "-")))
       (shortcut.desktop      (string-append shortcut ".desktop"))
       (home/shortcut.desktop (string-append *home-dir-path* shortcut.desktop))
       (dest-path             "/usr/share/applications/")
       (cp-command            (string-append "cp " home/shortcut.desktop " " dest-path))
       (chmod-command         (string-append "chmod 644 " dest-path shortcut.desktop)))
  (begin (display-lines-to-file file-contents home/shortcut.desktop)
         (system cp-command)
         (system chmod-command)
         (delete-file home/shortcut.desktop)))

; EOF
