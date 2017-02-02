
# Experimental Elm Router

This repo is an example elm app with a router that I've been playing with recently.

Basically, the `Router` module allows you to compose The Elm Architecture (TEA) **without any glue code**.

Here's what the routing looks like:

```
main =
    Router.default ProgA.prog
        |> Router.route ( "/b", ProgB.prog )
        |> Router.route ( "/c", ProgC.prog )
        |> Navigation.program Router.SetLocation
```

This maps ProgA as the default handler for any paths not mapped otherwise, ProgB to "/b" and ProgC to "/c". Take a look in ProgA to see that there is nothing weird in there. It's just a normal elm architecture program.

To me, this seems pretty cool. It works by taking advantage of elm's type inference. You might have noticed that the main above does not have an explicit type. Well, here it is:

```
main :
    Program
        Never
        (Router.WithLoc () (Router.WithLoc () ()))
        (
        Router.SetLocation
            String
            (Router.SetLocation String (Router.SetLocation String ()))
        )
```

That's not pretty cool. I can't imagine how gnarly this would get in a real app with a couple dozen routes and complex models on each page. That said, the idea of chaining generic functions together to progressively build an inferred type is pretty cool and new (to me).

What are your thoughts on this?