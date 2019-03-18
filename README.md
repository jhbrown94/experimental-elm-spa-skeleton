# Experimental Elm SPA skeleton

This is an experimental approach to implementing an SPA in (pure) Elm.   My principal goal was to let pages be self-contained.  If you like it, you can copy it and use it as a baseline for your own SPA, it's pretty straightforward.

It's a work in progress.  If it's interesting to you, please let me know.  If there's enthusiasm for this project, I'll do a lot more documenting and general cleanup and usability improvements.  (E.g. I've written this README, but I haven't documented the individual files yet, and probably won't if there isn't at least some external interest.)

Something not to worry about:  I've used `elm-ui` for the `view` functions in the skeleton.  There's no fundamental dependency on `elm-ui`; you can use `html` or whatever else you want to generate views.  I just like `elm-ui` a lot better than the alternatives.


## Install and run the skeleton

This isn't packaged as an Elm package, so use `git clone` to get this repo.  

You can run it with `elm reactor` -- navigate to `src/Main.elm`.  Because the reactor URL is not recognizable to the SPA, you'll get a "Not found" page in the SPA -- click the button to get back to the root and explore the app.

To compile this yourself, run `elm make src/Main.elm`.   If you host it on a webserver and redirect all URLs to the app, you can play with how it responds to hand-typed URLs. (Note that there's no session persistence, so you'll have to "log in" after every browser page load.)


## Example: Adding a page

Let's say we want to add a new page type `Email`:
1. Create `src/Page/Email.elm` using this template:
   ```
   
   module Page.Email exposing (Model, Msg, init, update, view)
   
   import Browser exposing (Document)
   import Route
   import Session exposing (Session)
   [your imports here]
   
   type alias Model = {your model here}
   
   
   type Msg
       = YourFirstMessage
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

3. Edit `Descriptors.elm` to add an import and and entry for `Page.Email`:
   ```
   ...
   import Page.Email as Email
   ...

   emailDescriptor : Descriptor PageMsg Email.Msg Email.Model
   emailDescriptor =
       { view = Email.view
       , update = Email.update
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
               case ( destination, session.authToken ) of
                   ... 
                   -- The following matches when we have authentication.
                   ( Email, Just auth ) ->
                       newPage emailDescriptor Email.init
               ... 
   ```


## Key concepts

Each page is entirely self-contained with no reference to the global hierarchy of pages.

A shared `Session` type enables pages to share state across page changes.

A Page's `init`, `update`, and `view` functions operate in terms of the Page's local `Model` and `Msg` types, and also receive a shared `Session`; update also returns the (optionally modified) `Session`.

A Page's `Descriptor` hides the page-specific `Model` and `Msg` types behind closures, thus providing a uniform interface for `Main.elm`'s `update` and `view` functions.

A `Destination` (from `Route.elm` is essentially a validated route within the SPA.)

The dispatcher in `Router.elm` selects which page to go to based on both a `Destination` and any conditions you want to impose on the shared `Session`; the version here looks at whether authentication has taken place, but there's nothing that prevents you from doing something else.

## What's missing or broken

If a Page needs to be able to invoke global operations, it can store a request in the `Session` that `Main.elm` could look at after calling the page's `update`.  There's no example of that in here (yet), though.

Bug:  If you try to reach an authenticated page without auth, you'll get sent to Login, and thereafter redirected to the page.  The current router leaves the URL at '/login', though.  It is on my queue to work this.