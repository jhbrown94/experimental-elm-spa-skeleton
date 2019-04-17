# Experimental Elm SPA skeleton

This is an experimental approach to implementing an SPA in (pure) Elm.   My principal goal was to let pages be self-contained.  If you like it, you can copy it and use it as a baseline for your own SPA, it's pretty straightforward.  

It's a work in progress.  If it's interesting to you, please let me know.  If there's enthusiasm for this project, I'll do a lot more documenting and general cleanup and usability improvements.  (E.g. I've written this README, but I haven't documented the individual files yet, and probably won't if there isn't at least some external interest.)

Something not to worry about:  I've used `elm-ui` for the `view` functions in the skeleton.  There's no fundamental dependency on `elm-ui`; you can use `html` or whatever else you want to generate views.  I just like `elm-ui` a lot better than the alternatives.

## Warnings

1. While I'm still feeling my way forward, I will push breaking changes at my whimsy, so if you want stability (or even niceties like a version number) this is probably not the platform for you.

2. The Elm debugger can't presently visualize closures, so using this skeleton will leave your top-level model pretty opaque in the debugger.  (On the other hand, building with --debug is broken in many cases anyhow right now.)  I hope that perhaps closures will become less opaque to the debugger in the future.

## Major influences

This skeleton is particularly influenced by these Elm codebases:

* [RealWorld example app (AKA elm-spa-example)](https://github.com/rtfeldman/elm-spa-example)
* [package.elm-lang.org](https://github.com/elm/package.elm-lang.org)
* [Elm Shared State example](https://github.com/ohanhi/elm-shared-state)


## Install and run the skeleton

This isn't packaged as an Elm package, so use `git clone` to get this repo.  

To compile this yourself, run `elm make src/Main.elm --output main.js`.  Then you have a few options to play with it:

1) You can visit with `elm reactor` -- browse to Main.elm.  Because the reactor URL is not recognizable to the SPA, you'll get a "Not found" page in the SPA -- click the button to get back to the root and explore the app.  (Also, you won't get proper session persistence because ports will silently fail.)

2) Fire up a simple webserver and view index.html directly.  One simple option:
```
 npm install http-server -g
 http-server 
```

You'll get session persistence here.  However, if you hand-type a URL or hit browser reload on any page other than the root, you'll wind up with a not-found from the server.

3) Configure a webserver to redirect all URLs to the app.  Now you can play with how it responds to hand-typed URLs. 


## Example: Adding a page

Let's say we want to add a new page type `Email`:
1. Create `src/Page/Email.elm` using this template:
   ```
   
   module Page.Email exposing (Model, Msg, init, subscriptions, update, view, wrapSessionEvent)
   
   import Browser exposing (Document)
   import Route
   import Session exposing (Session)
   [your imports here]
   
   type alias Model = {your model here}
   
   
   type Msg
       = YourFirstMessage
       | SubscriptionMsg -- customize this for your subscriptions, if any; or remove
       | SessionEventMsg Session.Event -- remove this if you're not listening to Session events
       | ...
   
   
   init : Session -> ( Session, Model, Cmd Msg )
   init session =
     session body here
   
   
   view : Session -> Model -> Document Msg
   view session model =
       { title = "Landing"
       , body =  your document body here}
   
   
   update : Msg -> Session -> Model -> ( Session, Model, Cmd Msg )
   update msg session model =
       case msg of
         YourFirstMessage -> your handler here
         ...

   -- This is optional, only implement it if you need it. 
   subscriptions session model =
      yourSubsHere <| SubscriptionMsg

   -- This is optional, only implement it if you need it. 
   -- Read more about this in the Sessions section of the README
   wrapSessionEvent event =
      SessionEventMsg event
   ```

  Note: To standardize some of the other boilerplate, even if you don't need a `Model` or `Msg`, define them as aliases of `()`, e.g. `type alias Model = ()`.

2. Edit `PageMsg.elm` to add an import and a `PageMsg` constructor for `Page.Email` messages:
   ```
   ...
   import Page.Email as Email

   ...
   type PageMsg
       = AboutMsg About.Msg
       ...
       | EmailMsg Email.Msg
   ```

3. Edit `Descriptors.elm` to add an import and an entry for `Page.Email`:
   ```
   ...
   import Page.Email as Email
   ...

   emailDescriptor : Descriptor PageMsg Email.Msg Email.Model
   emailDescriptor =
       { view = Email.view
       , update = Email.update
       , subscriptions = Just Email.subscriptions -- or Nothing if you don't need it
       , wrapSessionEvent = Just Email.wrapSessionEvent -- or Nothing if you don't need it
       , msgWrapper = EmailMsg
       , msgFilter =
           \main ->
               case main of
                   EmailMsg msg ->
                       Just msg
   
                   _ ->
                       Nothing
       }
   ```


4. Edit `Route.elm` to add a Destination for the new page, and to handle converting between URLs and the destination:
   ```
   type Destination
       = Root
       ...
       | Email   
   ...   

   urlFor destination =
       case destination of
           Email -> "/email" 
           ... 
   ...
   routeParser =
       oneOf
           [ map Root top
           ...
           , map Email (s "email"))
           ...
           ]
   ```

5. Edit `Router.elm` to add an import for the new page, and one or more clauses to the `route` function describing how to handle the `Destination` to that page based on session state (typically, authentication):
   ```
   import Page.Email as Email
   ...
   route url ({ session, page } as model) =
       let
           ...
         byDestination destination =
            case ( destination, newSession |> Session.getAuthToken ) of
                   ... 
                   -- The following matches when we have authentication.
                   ( Email, Just auth ) ->
                       newPage emailDescriptor Email.init
               ... 
   ```


## Key concepts

Each page is entirely self-contained with no reference to the global hierarchy of pages.  They are linked by `Destination`s (from `Route.elm`)

A `Destination`  is essentially a validated route within the SPA.  `Route.elm` doesn't contain references to the global page hierarchy.

A shared `Session` type enables pages to share state across page changes.  `Session` is interesting enough that it gets the next section below for more exposition.

A Page's `init`, `update`,  `view`, and optional `subscription` functions operate in terms of the Page's local `Model` and `Msg` types, and also receive a shared `Session`; update also returns the (optionally modified) `Session`.

A Page's `Descriptor` hides the page-specific `Model` and `Msg` types behind closures, thus providing a uniform interface for `Main.elm`'s `update` and `view` functions.

The dispatcher in `Router.elm` selects which page to go to based on both a `Destination` and any conditions you want to impose on the shared `Session`; the version here looks at whether authentication has taken place, but there's nothing that prevents you from doing something else.

## Session

`Session` provides a place to hang your global state.  It also provides a central point for performing global operations.  For instance, all URL-changing navigation operations happen using `Session.navPush`, `Session.navReplace`, and `Session.navBack`.  `Session.update` handlers may return a `Session.Event`, and pages which have a non-Nothing `wrapSessionEvent` entry in their `Descriptor` will receive those events.  (The example code checked in now doesn't demonstrate this, unfortunately -- I use it to announce updates when global information comes back from a server and a page might want to trigger new commands in response.)


## Refactoring an existing SPA into this style

It is possible to refactor an existing SPA into this style.  Add this kind of wrapped page as a single page, and then migrate individual pages into this style and out of your `Main.elm` case statements.  Similarly, move your global state into `Session` as you are able.

## What's missing or broken

Bug:  If you try to reach an authenticated page without auth, you'll get sent to `Page.Login`, and thereafter redirected to the page.  The current router leaves the URL at '/login', though.  It is on my queue to work this.