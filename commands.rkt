#lang racket
(provide check-and-run-commands)
;TODO:
; - finish implementing basic commands
; - move commands to a hashset for constant time access
; ? threading for commands that can be threaded
; - implement command-enabled? with a simple database handling user permissions
; - separate out command declarations and definitions into their own files so that
;      adding a new command is as simple as throwing a racket file providing it into a directory
; - case-insensitivity (?) 
; - more commands
(require irc-client)


;a command has a string name and an associated function
;this function should be of 4 args:
;   the connection,
;   the IrcUser that sent command,
;   a string for a channel or user receiving the command,
;   and cmd-str, a string that is the text of the message sent
(struct Command (Name Fn) #:transparent)

(define cmd-lst
  (list (Command "break"
                 (λ (conn sender recipient cmd-str)
                    'break))
        (Command "join" ;password protected channels?
                 (λ (conn sender recipient cmd-str)
                    (map (λ (ch) (when (equal? #\# (string-ref ch 0))
                                       (irc-join-channel! conn ch)))
                         (cdr (string-split cmd-str)))))
        (Command "part" ;no arg part in a channel parts that channel
                 (λ (conn sender recipient cmd-str)
                    (map (λ (ch) (when (equal? #\# (string-ref ch 0))
                                       (irc-part-channel! conn ch)))
                         (cdr (string-split cmd-str)))))
        (Command "say"
                 (λ (conn sender recipient cmd-str)
                    (let* ([s (string-split cmd-str)]
                           [target (if (and (cdr s)
                                        (equal? #\# (string-ref (car (cdr s)) 0)))
                                 (car (cdr s))
                                 recipient)]
                           [m (string-join (if (cdr s)
                                             (if (equal? #\# (string-ref (car (cdr s)) 0))
                                               (cdr (cdr s))
                                               (cdr s))
                                             '("")))])
                      (irc-send-message! conn target m))))
        ;; need to decide how to handle errors
        ; (Command "eval"
        ;          (λ (conn sender recipient cmd-str)
        ;             'DOSOMETHING))
        (Command "wait-reply"
                 (λ (sender recipient cmd-str)
                    (let ([n (string->number (car (cdr (string-split cmd-str))))])
                      (if n (thread (λ ()
                                       (sleep n)
                                       (irc-send-message! conn
                                                          (if (equal? #\# (string-ref recipient 0))
                                                            recipient
                                                            sender)
                                                          (string-join (list
                                                                         "waited"
                                                                         (number->string n)
                                                                         "seconds")))))
                        'SYNTAXERR))))))

; (define cmd-hash (make-hash))
; (map (λ (cmd) (hash-set! cmd-hash (Command-Name cmd) cmd))
;      cmd-lst)
(define cmd-hash (foldl (λ (h cmd) (hash-set h (Command-Name cmd) cmd))
                        (make-hash)
                        cmd-lst))

;if content is a command and sender is able to run said command for recipient,
; run it, sending output to relevant place
; recipient will either be a channel or bot-nick
;returns 'break if main-loop should break (for debug mostly)
;modifies conn (by sending messages on it)
(define (check-and-run-commands! conn sender recipient content)
  (let* ([cmd-str (string-normalize-spaces content)]
         [cmd (known-command? cmd-str)])
    (when (and cmd
               (command-enabled? sender recipient cmd))
      ((Command-Fn cmd) sender recipient cmd-str))))

;if cmd-str represents a valid command, return the associated Command struct
;otherwise return #f
(define (known-command? cmd-str)
  (hash-ref cmd-hash
            (car (string-split cmd-str))
            #f))
; (define (known-command? cmd-str)
;   (let ([foo (member (car (string-split cmd-str)) cmd-lst
;                      (λ (a b) (string-ci=? a (Command-Name b))))])
;     (if foo (car foo)
;       #f)))

;#t if cmd is enabled for sender/recipient pair
;#f otherwise
(define (command-enabled? sender recipient cmd)
  #t)

