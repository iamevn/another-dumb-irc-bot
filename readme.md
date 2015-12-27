#The world needs more irc bots, right?
####(This one's written in [Racket](http://racket-lang.org/) using [`irc-client`](https://github.com/lexi-lambda/racket-irc-client/).)

`pass.txt` should look something like this (temporary solution for while I'm too lazy to do actual config file stuff):

    #lang racket
    (provide PASS)
    (define PASS "password")
