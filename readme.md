#The world needs more irc bots, right?
####(This one's written in [Racket](http://racket-lang.org/) using [`irc-client`](https://github.com/lexi-lambda/racket-irc-client/).)

`bot-info.rkt` should look something like this (temporary solution for while I'm too lazy to do actual config file stuff):

    #lang racket
    (provide bot-nick bot-pass bot-username bot-realname)
    (define bot-nick "dumbrobot")
    (define bot-pass "password123")
    (define bot-username "bot")
    (define bot-realname "racket")
