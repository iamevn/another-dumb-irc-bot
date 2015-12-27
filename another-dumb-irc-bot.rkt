#lang racket
(require irc-client)
(require "pass.txt")
;dumb rizon bot does some stuff probably
(define bot-nick "iambot")
(define bot-username "dumb.bot")
(define bot-realname "adib")


(define-values (conn ready-evt) (irc-connect "irc.rizon.net" 6667
                                             bot-nick bot-username bot-realname))
(sync ready-evt)

(irc-send-message! conn "NickServ" (string-join "IDENTIFY" PASS))
(irc-send-message! conn "HostServ" "ON")


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
          [(IrcMessage other) (printf "~a\n" other)])
    (main-loop)))

(define (check-and-run-commands sender recipient content)
  '())

(main-loop)
