#lang racket
;dumb rizon bot does some stuff probably
(require irc-client)

;provides bot-nick, bot-pass, bot-username, and bot-realname
;all strings used for bot to connect and identify
(require "bot-info.rkt")

(define-values (conn ready-evt) (irc-connect "irc.rizon.net" 6667
                                             bot-nick bot-username bot-realname))
(sync ready-evt)

;idenfity and turn vhost on
(irc-send-message! conn "NickServ" (string-join "IDENTIFY" bot-pass))
(irc-send-message! conn "HostServ" "ON")

;main loop function that eats and parses irc messages (mostly just prints them right now)
;can be broken by commands (mostly useful to debug things in a repl)
(define (main-loop)
  (when (match (irc-recv! conn)
          [(IrcMessage-ChatMessage _ sender recipient content)
           (printf "(~a) <~a> ~a\n" recipient (IrcUser-nick sender) content)
           (check-and-run-commands sender recipient content)]
          [(IrcMessage-ActionMessage _ sender recipient content)
           (printf "(~a) * ~a ~a\n" recipient (IrcUser-nick sender) content)]
          [(IrcMessage-Notice _ sender recipient content)
           (printf "(~a) * ~a ~a\n" recipient (IrcUser-nick sender) content)]
          [(IrcMessage-Join _ sender channel)
           (printf " * ~a has joined ~a\n" (IrcUser-nick sender) channel)]
          [(IrcMessage-Part _ sender channel reason)
           (printf " * ~a has left (~a)\n" (IrcUser-nick sender) channel reason)]
          [(IrcMessage-Quit _ sender reason)
           (printf " * ~a has quit (~a)\n" (IrcUser-nick sender) reason)]
          [(IrcMessage-Kick _ sender channel kicked-nick reason)
           (printf " * ~a has kicked ~a from ~a (~a)\n" (IrcUser-nick sender) kicked-nick channel reason)]
          [(IrcMessage-Kill _ sender killed-nick reason)
           (printf " * ~a has killed ~a (~a)\n" (IrcUser-nick sender) killed-nick reason)]
          [(IrcMessage-Nick _ sender new-nick)
           (printf " * ~a is now known as ~a\n" (IrcUser-nick sender) new-nick)]
          [(IrcMessage other) (printf "~a\n" other)]
          [_ (printf "ERR?") #f])
    (main-loop)))

;if content is a command and sender is able to run said command, run it, sending output to relevant place
;recipient will either be a channel or bot-nick
(define (check-and-run-commands sender recipient content)
  '())


;start up main-loop
(main-loop)
