# Experimental Elm SPA skeleton

This is an experimental approach to implementing an SPA in (pure) Elm.   My principal goal was to let pages be self-contained.  If you like it, you can copy it and use it as a baseline for your own SPA, it's pretty straightforward.

It's a work in progress.  If it's interesting to you, please let me know.  If there's enthusiasm for this project, I'll do a lot more documenting and general cleanup and usability improvements.  (E.g. I've written this README, but I haven't documented the individual files yet, and probably won't if there isn't at least some external interest.)

Something not to worry about:  I've used `elm-ui` for the `view` functions in the skeleton.  There's no fundamental dependency on `elm-ui`; you can use `html` or whatever else you want to generate views.  I just like `elm-ui` a lot better than the alternatives.

## Install and run the skeleton

This isn't packaged as an Elm package, so use `git clone` to get this repo.  

You can run it with `elm reactor` -- navigate to `src/Main.elm`.  Because the reactor URL is not recognizable to the SPA, you'll get a "Not found" page in the SPA -- click the button to get back to the root and explore the app.

To compile this yourself, run `elm make src/Main.elm`.   If you host it on a webserver and redirect all URLs to the app, you can play with how it responds to hand-typed URLs. (Note that there's no session persistence, so you'll have to "log in" after every browser page load.)

## Key concepts

The basic idea is to have each page in the SPA encapsulate its data using partial application.  Partially-applied page-specific `view` and `update` functions are then encapsulated (along with additional information) in a uniform `Page` opaque type.  This means that adding a new page does not require touching the top-level `view` and `update` functions.  Page data is comprised of the page's title (as seen in the browser tab); any page-specific state; and optionally a session type which is shared accross all pages.  Pages are interconnected with routes, which also support direct access by URL.

To adapt the skeleton to your uses, probably the three types to think about first are `Page`, `Session`, and `Route`.

### `Session`

`Session` is a type shared by all `Page`s that refer to sessions in the SPA.  `Session` is defined in `src/Session.elm`.  What you store in a Session is completely configurable.  In the skeleton, the presence of a session indicates whether or not the user has logged in, but you could do something very different with it. 

### `Route` and `Router`

#### `Route`
`src/Route.elm` defines `Route`, a union type providing a mapping with of valid URLs into the SPA.  Here are key fragments from the skeleton:
```
type Route
    = Root
    | NotFound String
    | Login (Maybe Url)
    ...
    | About
```

The `Route` union defines all legitimate URL structures.

```
routeParser =
    oneOf
        [ map Root top
        , map loginParserHelper (s loginSegment <?> Query.string loginSuccessKey)
        ...
        , map About (s aboutSegment)
        ]
```
The `routeParser` function uses `Url.Parser` to parse a `Url` into a `Route`.  Note the use of a helper function (not shown here) for `Login` -- the helper handles the case in which `loginSuccessKey` is not a valid URL.

```
routeToUrlString : Route -> String
routeToUrlString route =
    case route of
        Root ->
            absolute [] []

        Login (Just successUrl) ->
            absolute [ loginSegment ] [ Builder.string loginSuccessKey (Url.toString successUrl) ]

        Login Nothing ->
            absolute [ loginSegment ] []
```

`routeToUrlString` converts a `Route` into a string representation of a URL, suitable for handing to (e.g.) `Browser.Navigation.pushUrl`

#### `Router`
`src/Router.elm` glues `Route`s together with `Page`s.  Which `Page` is selected for a route may depend on the availability of a `Session`.  Here's the key function in its entirety:
```
handlerFor url route model =
    case ( route, Model.session model ) of
        -- Special routing case: "/" goes to Landing or Primary depending on Session state
        ( Root, Just s ) ->
            Normal <| Page.Primary.init s

        ( Root, Nothing ) ->
            Normal <| Page.Landing.init

        ( Login success, s ) ->
            Normal <| Page.Login.init s success model

        ( Logout, _ ) ->
            Normal <| Page.Logout.init

        ( NotFound urlString, s ) ->
            Normal <| Page.NotFound.init s urlString

        -- Normal session required pages
        ( Secondary, Just s ) ->
            Normal <| Page.Secondary.init s

        -- Normal session-not-required pages
        ( About, s ) ->
            Normal <| Page.About.init s

        -- Catch-all to redirect session-required pages to Login if no session is present
        ( _, Nothing ) ->
            Redirect <| Login (Just url)
```


### `Page`

`Page msg model` is an opaque type representing pages in the SPA.  Each SPA page is implemented in a file in `src/Page/`.    A really simple "About my app" page implementation might look something like this:

```
module Page.About exposing (init)

import Page
import <stuff for the view>


init session =
    ( Page.withOptionalSession
        view
        update
        { title = "MyApp: About"
        , session = session
        , state = ()
        }
    , Cmd.none
    )


view data model =
    stuffForTheView model "This page is all about this app"


update builder data msg model =
    ( model, Cmd.none )
```

The first thing to notice is that the only export is `init`.  `init` can take arbitrary arguments, as explained below in `Route`.  It must return a `(Page msg model, Cmd msg)` tuple.   Within init, for this simple example we construct the `Page` when we call `Page.withOptionalSession`.  

`withOptionalSession` takes three arguments:
1. a `view` function which accepts a `Page.DataWithOptionalSession session state` record, and a `model`; and returns a tuple `(Page msg model, Cmd msg)`
2. an `update` function which accepts an opaque builder value, a `Page.DataWithOptionalSession session state` value, and a `model`; and returns a tuple `(Page msg model, Cmd msg)`
3. a `Page.DataWithOptionalSession session state` record.  Digging in, this contains:
  - a title `String`
  - a `Maybe session`.  `session` will generally get specialized as `Session`.
  - page-specific `state.  This is the page-local state.  For this example, the page has no state.

Other page creation options are `Page.withSession`, in which the `data.session` field is of type `session` instead of `Maybe session`; and `Page.withNoSession`, in which `data` does not have a `session` field.  For the About page, we choose `withOptionalSession` because don't care if the user has logged in or not to view this page, but if they do have a `session` we want to preserve it.

#### Page-local state

The About page above doesn't need local state, so `state` is just `()`.  In a Login page with a couple of text inputs, `state` might be something like this:
```
module Page.Login exposing (init)
...
type alias State =
    { username : String
    , password : String
    , successUrlString : String
    }
...
```


#### Page-specific messages

The About page didn't do much of anything, so it didn't need its own messages.  The Login page, however, needs to update its state when users type.  To do that, page-specific messages are defined in `src/Msg/Page/Login.elm`:
```
module Msg.Page.Login exposing (Msg(..))


type Msg
    = UsernameChanged String
    | PasswordChanged String
    | LoginPressed
    | CancelPressed
```

These messages are pulled into the global message type by adding a wrapper constructor in `src/Msg.elm`:
```
module Msg exposing (MainMsg(..), Msg(..))
...
import Msg.Page.Login as Login 
...


type Msg
    = Main MainMsg
    | Login Login.Msg   -- This is the new wrapper created for Login messages
...
```

To see how messages are used, we turn to the `view` function.

#### The `view` function
Here's a fragment of a Login-page view function:
```
view : Page.ViewWithOptionalSession Session State Msg.Msg Model
view data model =
   ... 
            Input.username []
                { text = data.state.username
                , onChange = Msg.Login << UsernameChanged
                ...
                }
```

The input's `text` value is set from the login-page-specific `data.state` record.  When `onChange` fires, it wraps the string result with `Msg.Page.UsernameChanged`, and further wraps that with `Msg.Login`, which makes the return type of this page's `view` function consistent with all other pages'.

Another fragment of a view might include a button (could be a link instead) to go to the about page:
```
view data model =
   ...
                button [] { onPress = Just <| Msg.Main <| Msg.PushRoute Route.About, label = text "About" }

```

`Msg.PushRoute` is a `MainMsg` routing message that takes a `Route` and attempts to apply it.  `Msg.Main` wraps it to turn it into a `Msg.Msg` so that the central `update` function knows how to dispatch it.

#### The `update` function

Here's a fragment of a possible `update` for a login page:
```
update : Page.UpdateWithOptionalSession Session State Msg.Msg Model
update builder ({ state } as oldData) msg model =
    case msg of
        Msg.Login loginMsg ->
            case loginMsg of
                UsernameChanged username ->
                    ( model
                        |> Model.updatePageInPlace
                            (Page.updateWithOptionalSession { oldData | state = {state | username = username } } )
                                builder
                            )
                    , Cmd.none )
...
                CancelPressed ->
                    ( model, Navigation.back model.key 1 )

        _ ->
            ( model, Cmd.none )

```
Things to note:
* The outermost `case` handles `Msg.Login` messages, and discards everything else.  This lets the compiler check that we handle all `Login` messages, while also discarding any late asynchronous messages arriving due to actions set up by prior pages.  (Note:  `Main.update` handles `Msg.MainMsg` messages directly, so they are never discarded.)
* When the username input changes and the `UsernameChanged` message arrives, the page updates its internal state with `Page.updateWithOptionalSession`.  The arguments are a new `data` value, and the opaque `builder` object.  Under the hood, the `builder` contains references to the un-partially-evaluated `view` and `update` functions, enabling `updateWithOptionalSession` to build a new `Page` by partially-evaluating them against the new `data`.
* `Model.updatePageInPlace` updates the page at the top level without triggering any navigation.
* Right now, navigation-related stuff is stored visibly on `Model`.  I expect I'll make Model opaque and provide navigation operations directly on it.

## Putting it all together: adding a `Page`
Let's say we want to add a new page type `Email`:
1. Create `src/Page/Email.elm`.  Consider starting it by copying an existing `Page` with similar properties (e.g. WithSession, WithOptionalSession, or NoSession)
2. If the page will have its own messages:
   1. Create `src/Msg/Page/Email.elm` for messages specific to the page
   2. Edit `src/Msg.elm` to import the new file and add an `Email` wrapper type to `Msg`
3. Edit `src/Route.elm` to add the new `Route` constructor; parsing logic in `routeParser`, and unparsing in `routeToUrlString`.
4. Edit `src/Router.elm` to add the `Route`-to-`Page` cases in the `handlerFor` function.

That should do it!



