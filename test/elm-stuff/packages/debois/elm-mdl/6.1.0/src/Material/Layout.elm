module Material.Layout exposing
  ( init, subscriptions , Model, defaultModel
  , Msg(ToggleDrawer), update
  , Property
  , fixedDrawer, fixedTabs, fixedHeader, rippleTabs
  , waterfall, seamed, scrolling, selectedTab, onSelectTab
  , row, spacer, title, navigation, link, onClick, href
  , setTabsWidth
  , Contents, view
  , sub0, subs, render, toggleDrawer
  , transparentHeader
  )


{-| From the
[Material Design Lite documentation](https://www.getmdl.io/components/index.html#layout-section):

> The Material Design Lite (MDL) layout component is a comprehensive approach to
> page layout that uses MDL development tenets, allows for efficient use of MDL
> components, and automatically adapts to different browsers, screen sizes, and
> devices.
>
> Appropriate and accessible layout is a critical feature of all user interfaces,
> regardless of a site's content or function. Page design and presentation is
> therefore an important factor in the overall user experience. See the layout
> component's
> [Material Design specifications page](https://www.google.com/design/spec/layout/structure.html#structure-system-bars)
> for details.
>
> Use of MDL layout principles simplifies the creation of scalable pages by
> providing reusable components and encourages consistency across environments by
> establishing recognizable visual elements, adhering to logical structural
> grids, and maintaining appropriate spacing across multiple platforms and screen
> sizes. MDL layout is extremely powerful and dynamic, allowing for great
> consistency in outward appearance and behavior while maintaining development
> flexibility and ease of use.

# Subscriptions

The layout needs to be initialised with and subscribe to changes in viewport
sizes. Example initialisation of containing app: 

    import Material.Layout as Layout
    import Material

    type Msg = 
      ...
      | Mdl Material.Msg -- Boilerplate

    ...

    App.program 
      { init = ( model, Layout.sub0 Mdl )
      , view = view
      , subscriptions = Layout.subs Mdl
      , update = update
      }

## Tabs width 

Tabs display chevrons when the viewport is too small to show all tabs
simultaneously. Unfortunately, Elm currently does not give us a way to
automatically detect the width of the tabs at app launch. If you have tabs, 
to make the chevron display correctly at app lauch, you must set 
`model.tabScrollState.width` manually in `init`. If you're using parts, 
use `setTabScrollState` to accomplish this. Initialisation would in this case
be (assuming a tab width of 1384 pixels):

    App.program 
      { init = 
          ( { model | mdl = Layout.setTabsWidth 1384 model.mdl }
            , Layout.sub0 Mdl 
          )
      , view = view
      , subscriptions = .mdl >> Layout.subs Mdl
      , update = update
      }


@docs sub0, subs

# Render
@docs Contents, render, toggleDrawer

# Options
@docs Property

## Tabs
@docs fixedTabs, rippleTabs
@docs selectedTab, setTabsWidth 

## Header
@docs fixedHeader, fixedDrawer
@docs waterfall, seamed, scrolling
@docs transparentHeader

## Events
@docs onSelectTab

# Sub-views
@docs row, spacer, title, navigation, link, onClick, href

# Elm architecture
@docs view, Msg, Model, defaultModel, update, init, subscriptions


-}


import Dict exposing (Dict)
import Maybe exposing (andThen, map)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (class, classList, tabindex)
import Html.Events as Events exposing (on)
import Html.Keyed as Keyed
import Platform.Cmd exposing (Cmd)
import Window
import Json.Decode as Decoder exposing ((:=))
import Task

import Parts
import Material.Helpers as Helpers exposing (filter, delay, pure, map1st, map2nd)
import Material.Ripple as Ripple
import Material.Icon as Icon
import Material.Options as Options exposing (Style, cs, nop, css, when, styled)
import Material.Options.Internal exposing (attribute)

import DOM


-- SETUP


{-| Layout needs initial viewport size
-}
init : (Model, Cmd Msg)
init = 
  let
    measureScreenSize = 
      Task.perform 
        (\_ -> Resize (Debug.log "Can't get initial window dimensions. Guessing " 1025))
        Resize 
        Window.width
  in
    ( defaultModel , measureScreenSize )


{-| Layout subscribes to changes in viewport size. 
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Window.resizes (.width >> Resize)


-- MODEL


type alias TabScrollState =
  { canScrollLeft : Bool
  , canScrollRight : Bool
  , width : Maybe Int
  }


{- Elm don't give us a good way to measure the width of the tabs, so we
arbitrarily decide that they probably can't scroll. The user can adjust this
decision by supplying his own estimate of what the width of the tabsWidth might
be. 
-}
defaultTabScrollState : TabScrollState 
defaultTabScrollState = 
  { canScrollRight = True
  , canScrollLeft = False
  , width = Nothing
  }


setTabsWidth' : Int -> Model -> Model 
setTabsWidth' width model = 
  let x = model.tabScrollState in
  { model 
  | tabScrollState = 
    { x | width = Just width }
  }


{-| Component model. 
-}
type alias Model =
  { ripples : Dict Int Ripple.Model
  , isSmallScreen : Bool
  , isCompact : Bool
  , isAnimating : Bool
  , isScrolled : Bool
  , isDrawerOpen : Bool
  , tabScrollState : TabScrollState
  }


{-| Default component model. 
-}
defaultModel : Model
defaultModel =
  { ripples = Dict.empty
  , isSmallScreen = False 
  , isCompact = False
  , isAnimating = False
  , isScrolled = False
  , isDrawerOpen = False
  , tabScrollState = defaultTabScrollState
  }


-- ACTIONS, UPDATE


{-| Component messages.
-}
type Msg
  = ToggleDrawer
  | Resize Int
  | ScrollTab TabScrollState
  | AdvanceTabs Int
  | ScrollPane Bool Float -- True means fixedHeader
  | TransitionHeader { toCompact : Bool, fixedHeader : Bool }
  | TransitionEnd
  | NOP
  -- Subcomponents
  | Ripple Int Ripple.Msg


{-| Component update.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  update' msg model 
    |> Helpers.map1st (Maybe.withDefault model)


update' : Msg -> Model -> (Maybe Model, Cmd Msg)
update' action model =
  case action of
    NOP -> 
      ( Nothing, Cmd.none ) 

    Resize width -> 
      {- High-frequency message. To avoid stuttering during resizes, we must
      return referentially the same model if we're not making any updates. (And
      the user must be using Html.Lazy.)
      -}
      let 
        isSmall = 
          1024 > width 
        tabScrollState = 
          model.tabScrollState.width 
            |> Maybe.map (\tabsWidth ->
                  let tabScrollState = model.tabScrollState in
                  { tabScrollState 
                  | canScrollRight = tabsWidth + (2 * 56) {- chevrons -} > width 
                  })
            |> Maybe.withDefault model.tabScrollState
                {- We have no idea how much horisontal space tabs consume, so we have no
                idea whether they scroll or not. -}
      in
        pure <| 
          -- Make sure we return a referentially equal model if we're not
          -- changing anything. 
          if isSmall == model.isSmallScreen && 
             tabScrollState.canScrollRight == model.tabScrollState.canScrollRight
          then 
            Nothing
          else
            Just <|
              { model  
              | isSmallScreen = isSmall 
              , isDrawerOpen = not isSmall && model.isDrawerOpen
              , tabScrollState = tabScrollState
              }

    ToggleDrawer ->
      Just { model | isDrawerOpen = not model.isDrawerOpen } |> pure

    Ripple tabIndex action' ->
      Dict.get tabIndex model.ripples
      |> Maybe.withDefault Ripple.model
      |> Ripple.update action'
      |> map1st (\ripple' -> 
          Just { model | ripples = Dict.insert tabIndex ripple' model.ripples })
      |> map2nd (Cmd.map (Ripple tabIndex))

    AdvanceTabs _ -> 
      -- Don't know how to do this. 
      pure Nothing

    ScrollTab state ->
      {- High-frequency message. To avoid stuttering during scrolling, we must
      return a referentially identical model if we're making  no changes.
      -}
      pure <| 
        if model.tabScrollState /= state then 
          Just { model | tabScrollState = state } 
        else
          Nothing

    ScrollPane fixedHeader offset -> 
      {- High-frequency message. To avoid stuttering during scrolling, we must
      return a referentially identical model if we're making  no changes.
      -}
      let 
        isScrolled = 0.0 < offset 
      in
        if isScrolled /= model.isScrolled then
          update' 
            (TransitionHeader { toCompact = isScrolled, fixedHeader = fixedHeader })
            { model | isScrolled = isScrolled }
        else
          pure Nothing

    TransitionHeader { toCompact, fixedHeader } -> 
      let 
        headerVisible = (not model.isSmallScreen) || fixedHeader
        model' = 
          { model 
          | isCompact = toCompact
          , isAnimating = headerVisible 
          }
      in
        if not model.isAnimating then 
          ( Just <| 
              { model 
              | isCompact = toCompact
              , isAnimating = headerVisible 
              }
          , delay 200 TransitionEnd -- See comment on transitionend in view. 
          )
        else
          pure Nothing


    TransitionEnd -> 
      pure (Just { model | isAnimating = False })


-- PROPERTIES


type alias Config m = 
  { fixedHeader : Bool
  , fixedDrawer : Bool
  , fixedTabs : Bool
  , rippleTabs : Bool
  , mode : Mode
  , selectedTab : Int
  , onSelectTab : Maybe (Int -> Attribute m)
  , transparentHeader : Bool
  , moreTabs : Bool
  }


defaultConfig : Config m
defaultConfig = 
  { fixedHeader = False
  , fixedDrawer = False
  , fixedTabs = False
  , rippleTabs = True
  , mode = Standard
  , onSelectTab = Nothing
  , selectedTab = -1
  , moreTabs = False
  , transparentHeader = False
  }


{-| Layout options. 
-}
type alias Property m = 
  Options.Property (Config m) m


{-| Header is "fixed": It appears even on small screens. 
-}
fixedHeader : Property m
fixedHeader =
  Options.set (\config -> { config | fixedHeader = True })



{-| Drawer is "fixed": It is always open on large screens. 
-}
fixedDrawer : Property m
fixedDrawer =
  Options.set (\config -> { config | fixedDrawer = True })


{-| Tabs are spread out to consume available space and do not scroll horisontally.
-}
fixedTabs : Property m
fixedTabs =
  Options.set (\config -> { config | fixedTabs = True })


{-| Make tabs ripple when clicked. 
-}
rippleTabs : Property m
rippleTabs =
  Options.set (\config -> { config | rippleTabs = True })


{-| Header behaves as "Waterfall" header: On scroll, the top (argument `True`) or
the bottom (argument `False`) of the header disappears. 
-}
waterfall : Bool -> Property m
waterfall b =
  Options.set (\config -> { config | mode = Waterfall b })


{-| Header behaves as "Seamed" header: it does not cast shadow, is permanently
affixed to the top of the screen.
-}
seamed : Property m
seamed = 
  Options.set (\config -> { config | mode = Seamed })

{-| Header is transparent: It draws on top of the layout's background
-}
transparentHeader : Property m
transparentHeader =
  Options.set (\config -> { config | transparentHeader = True })


{-| Header scrolls with contents. 
-}
scrolling : Property m
scrolling = 
  Options.set (\config -> { config | mode = Scrolling })

{-| Set the selected tab. 
-}
selectedTab : Int -> Property m
selectedTab k =
  Options.set (\config -> { config | selectedTab = k })


{-| Set this property if tabs are missing the "more tabs on the right" indicator
chevron on app launch. 
  
(Elm core libraries currently don't give us a good way to determine this situation
automatically.)
-}
moreTabs : Property m
moreTabs =
  Options.set (\config -> { config | moreTabs = True })


{-| Receieve notification when tab `k` is selected.
-}
onSelectTab : (Int -> m) -> Property m
onSelectTab f = 
  Options.set (\config -> { config | onSelectTab = Just (f >> Events.onClick) })


-- AUXILIARY VIEWS



{-| Push subsequent elements in header row or drawer column to the right/bottom.
-}
spacer : (Html m)
spacer = div [class "mdl-layout-spacer"] []


{-| Title in header row or drawer.
-}
title : List (Property m) -> List (Html m) -> Html m
title styles = 
  Options.span (cs "mdl-layout__title" :: styles) 


{-| Container for links.
-}
navigation : List (Style m) -> List (Html m) -> Html m
navigation styles contents =
  nav [class "mdl-navigation"] contents


type LinkProp = LinkProp


type alias LinkProperty m = 
  Options.Property LinkProp m


{-| onClick for Links.
-}
onClick : m -> LinkProperty m 
onClick = 
  Events.onClick >> attribute


{-| href for Links.
-}
href : String -> LinkProperty m
href = 
  Html.Attributes.href >> attribute


{-| Link.
-}
link : List (LinkProperty m) -> List (Html m) -> Html m
link styles contents =
  Options.styled a 
    (cs "mdl-navigation__link" 
     :: attribute (Html.Attributes.attribute "tabindex" "1")
     :: styles) 
    contents


{-| Header row. 
-}
row : List (Property m) -> List (Html m) -> Html m
row styles = 
  Options.div (cs "mdl-layout__header-row" :: styles) 


-- MAIN VIEWS



{-| Mode for the header.
- A `Standard` header casts shadow, is permanently affixed to the top of the screen.
- A `Seamed` header does not cast shadow, is permanently affixed to the top of the
  screen.
- A `Scroll`'ing header scrolls with contents.
- A `Waterfall` header drops either the top (argument True) or bottom (argument False) 
header-row when content scrolls. 
-}
type Mode
  = Standard
  | Seamed
  | Scrolling
  | Waterfall Bool


isWaterfall : Mode -> Bool
isWaterfall mode = 
  case mode of 
    Waterfall _ -> True
    _ -> False


toList : Maybe a -> List a
toList x = 
  case x of 
    Nothing -> []
    Just y -> [y]


type Direction = 
  Left | Right




tabsView : 
  (Msg -> m) -> Config m -> Model -> (List (Html m), List (Style m)) -> Html m
tabsView lift config model (tabs, tabStyles) =
  let 
    chevron direction offset =
      let 
        dir = 
          case direction of 
            Left -> "left"
            Right -> "right"
      in
        styled div
          [ cs "mdl-layout__tab-bar-button"
          , cs ("mdl-layout__tab-bar-" ++ dir ++ "-button")
          , cs "is-active" 
              `when` 
                ( (direction == Left && model.tabScrollState.canScrollLeft) ||
                  (direction == Right && model.tabScrollState.canScrollRight) )
          , Options.many tabStyles
          ]
          [ Icon.view ("chevron_" ++ dir)
              [ Icon.size24
              , Html.Attributes.attribute 
                  "onclick" 
                  ("document.getElementsByClassName('mdl-layout__tab-bar')[0].scrollLeft += " ++ toString offset)
                |> attribute
              --, Icon.onClick (lift (AdvanceTabs offset))
              ]
          ]
    in
      div
        [ class "mdl-layout__tab-bar-container"
        ]
        [ chevron Left -100
        , Options.div
            [ cs "mdl-layout__tab-bar" 
            , css "scroll-behavior" "smooth"
            , if config.rippleTabs then 
                Options.many 
                  [ cs "mdl-js-ripple-effect"
                  , cs "mds-js-ripple-effect--ignore-events"
                  ]
              else
                nop
            , if config.mode == Standard then cs "is-casting-shadow" else nop
            , Options.many tabStyles
            , attribute <| 
                on "scroll" 
                  (DOM.target 
                     (Decoder.object3 
                        (\scrollWidth clientWidth scrollLeft -> 
                            { canScrollLeft = scrollLeft > 0
                            , canScrollRight = scrollWidth - clientWidth > scrollLeft + 1
                            , width = Just clientWidth
                            } |> ScrollTab |> lift)
                        ("scrollWidth" := Decoder.float)
                        ("clientWidth" := Decoder.float)
                        ("scrollLeft"  := Decoder.float)))
            ]
            (tabs |> List.indexedMap (\tabIndex tab ->
              filter a
                [ classList
                    [ ("mdl-layout__tab", True)
                    , ("is-active", tabIndex == config.selectedTab)
                    ]
                , config.onSelectTab 
                    |> Maybe.map ((|>) tabIndex)
                    |> Maybe.withDefault Helpers.noAttr
                --, Html.Attributes.href ("#mdl-layout-tab-" ++ toString tabIndex)
                ]
                [ Just tab
                , if config.rippleTabs then
                    Dict.get tabIndex model.ripples 
                      |> Maybe.withDefault Ripple.model
                      |> Ripple.view [ class "mdl-layout__tab-ripple-container" ]
                      |> App.map (Ripple tabIndex >> lift)
                      |> Just
                  else
                    Nothing
                ]
             ))
        , chevron Right 100
        ]


headerView 
  : (Msg -> m) -> Config m -> Model 
 -> (Maybe (Html m), List (Html m), Maybe (Html m)) 
 ->  Html m
headerView lift config model (drawerButton, rows, tabs) =
  let 
    mode =
      case config.mode of
        Standard  -> ""
        Scrolling -> "mdl-layout__header--scroll"
        Seamed    -> "mdl-layout__header--seamed"
        Waterfall True -> "mdl-layout__header--waterfall mdl-layout__header--waterfall-hide-top"
        Waterfall False -> "mdl-layout__header--waterfall"
  in
    Html.header
      ([ classList
          [ ("mdl-layout__header", True)
          , ("is-casting-shadow", 
              config.mode == Standard || 
              (isWaterfall config.mode && model.isCompact)
            )
          , ("is-animating", model.isAnimating)
          , ("is-compact", model.isCompact)
          , (mode, mode /= "")
          , ("mdl-layout__header--transparent", config.transparentHeader)
          ]
      ]
      |> List.append (
        if isWaterfall config.mode then 
          [  
          --  Events.onClick addr Click
          --, on "transitionend" Json.value (\_ -> Signal.message addr TransitionEnd)
            {- There is no "ontransitionend" property; you'd have to add a listener, 
            which Elm won't let us. We manually fire a delayed tick instead. 
            See also: https://github.com/evancz/virtual-dom/issues/30
            -}
            Events.onClick 
              (TransitionHeader { toCompact=False, fixedHeader=config.fixedHeader }
               |> lift)
          ]
        else
          []
        )
      )
      (List.concatMap (\x -> x)
         [ toList drawerButton
         , rows 
         , toList tabs
         ]
      )


onKeypressFilterSpaceAndEnter : Html.Attribute x
onKeypressFilterSpaceAndEnter = """
  (function (evt) {
     if (evt && evt.type === "keydown" && (evt.keyCode === 32 || evt.keyCode === 13)) {
       evt.preventDefault();
     }
   })(window.event);
  """
    |> Html.Attributes.attribute "onkeypress"



drawerButton : (Msg -> m) -> Html m
drawerButton lift =
  div 
    [ --onKeypressFilterSpaceAndEnter
    ]
    [
      div
        [ class "mdl-layout__drawer-button"
        , tabindex 1
        , Events.onClick (lift ToggleDrawer)
        , Events.onWithOptions 
            "keydown"
            { stopPropagation = False
            , preventDefault = False --  True
              {- TODO: Should stop propagation exclusively on ENTER, but elm
              currently require me to decide on options before the keycode value is
              available. -} 
            }
            (Decoder.map 
              (lift << \key -> case key of 
                  32 {- SPACE -} -> ToggleDrawer
                  13 {- ENTER -} -> ToggleDrawer
                  _ -> NOP)
              Events.keyCode)
        ]
        [ Icon.i "menu" ]
      ]


obfuscator : (Msg -> m) -> Bool -> Html m
obfuscator lift isVisible =
  div
    [ classList
        [ ("mdl-layout__obfuscator", True)
        , ("is-visible", isVisible)
        ]
    , Events.onClick (lift ToggleDrawer)
    ]
    []


drawerView : (Msg -> m) -> Bool -> List (Html m) -> Html m
drawerView lift isVisible elems =
  div
    [ classList
        [ ("mdl-layout__drawer", True)
        , ("is-visible", isVisible)
        ]
    ] 
    elems


{-| Content of the layout only (contents of main pane is set elsewhere). Every
part is optional; if you supply an empty list for either, the sub-component is 
omitted. 

The `header` and `drawer` contains the contents of the header rows and drawer,
respectively. Use `row`, `spacer`, `title`, `nav`, and `link`, as well as
regular Html to construct these. The `tabs` contains
the title of each tab.
-}
type alias Contents m =
  { header : List (Html m)
  , drawer : List (Html m)
  , tabs : (List (Html m), List (Style m))
  , main : List (Html m)
  }


{-| Main layout view.
-}
view : (Msg -> m) -> Model -> List (Property m) -> Contents m -> Html m
view lift model options { drawer, header, tabs, main } =
  let
    summary = 
      Options.collect defaultConfig options

    config = 
      summary.config 

    (contentDrawerButton, headerDrawerButton) =
      case (drawer, header, config.fixedHeader) of
        (_ :: _, _ :: _, True) ->
          -- Drawer with fixedHeader: Add the button to the header
           (Nothing, Just <| drawerButton lift)

        (_ :: _, _, _) ->
          -- Drawer, no or non-fixed header: Add the button before contents.
           (Just <| drawerButton lift, Nothing)

        _ ->
          -- No drawer: no button.
           (Nothing, Nothing)

    hasTabs = 
      not (List.isEmpty (fst tabs))

    hasHeader = 
      hasTabs || (not (List.isEmpty header))

    hasDrawer = 
      drawer /= [] 

    drawerIsFixed = 
      config.fixedDrawer && not model.isSmallScreen

    drawerIsVisible = 
      model.isDrawerOpen

    tabsElems = 
      if not hasTabs then
        Nothing
      else 
        Just (tabsView lift config model tabs)
  in
  div
    [ classList
        [ ("mdl-layout__container", True)
        , ("has-scrolling-header", config.mode == Scrolling)
        ]
    ]
    [ filter (Keyed.node "div") 
        ([ Just <| classList
            [ ("mdl-layout ", True)
            , ("is-upgraded", True)
            , ("is-small-screen", model.isSmallScreen)
            , ("has-drawer", hasDrawer)
            , ("has-tabs", hasTabs)
            , ("mdl-js-layout", True)
            , ("mdl-layout--fixed-drawer", config.fixedDrawer && hasDrawer)
            , ("mdl-layout--fixed-header", config.fixedHeader && hasHeader)
            , ("mdl-layout--fixed-tabs", config.fixedTabs && hasTabs)
            ]
        {- MDL has code to close drawer on ESC, but it seems to be
           non-operational. We fix it here. Elm 0.17 doesn't give us a way to
           catch global keyboard events, but we can reasonably assume something inside
           mdl-layout__container is focused. 
        -} 
        , if drawerIsVisible && not drawerIsFixed then
            on "keydown" 
               (Decoder.map 
                 (lift << \key -> if key == 27 then ToggleDrawer else NOP) 
                 Events.keyCode)
            |> Just
          else
            Nothing
        ] |> List.filterMap identity)
        [ if hasHeader then
            headerView lift config model (headerDrawerButton, header, tabsElems)
              |> (,) "elm-mdl-header" |> Just
          else
            Nothing
        , if not hasDrawer then Nothing else Just ("elm-mdl-drawer", drawerView lift drawerIsVisible drawer)
        , if not hasDrawer then Nothing else Just ("elm-mdl-obfuscator", obfuscator lift (drawerIsVisible && not drawerIsFixed))
        , contentDrawerButton |> Maybe.map ((,) "elm-drawer-button")
        , main'
            {- Keyed to prevent scrolling state being retained when we switch tab. -}
            (class "mdl-layout__content" 
             :: (if isWaterfall config.mode then 
                   [ on "scroll" 
                       (Decoder.map 
                         (ScrollPane config.fixedHeader >> lift) 
                         (DOM.target DOM.scrollTop))
                   ]
                 else 
                   []
                )
            )
            main
          |> (,) (toString config.selectedTab) |> Just
        ]
    ]


type alias Container c =
  { c | layout : Model }


{-| Component render. Refer to `demo/Demo.elm` on github for an example use. 
Excerpt:

    Layout.render Mdl model.mdl
      [ Layout.selectedTab model.selectedTab
      , Layout.onSelectTab SelectTab
      , Layout.fixedHeader
      ]
      { header = myHeader
      , drawer = myDrawer
      , tabs = (tabTitles, [])
      , main = [ MyComponent.view model ]
      }
-}
render 
  : (Parts.Msg (Container b) -> c)
 -> Container b
 -> List (Property c) 
 -> Contents c 
 -> Html c
render =
  Parts.create1' view update' .layout (\x c -> { c | layout = x }) 


pack : Msg -> Parts.Msg (Container b)
pack = 
  let
    embeddedUpdate = 
      Parts.embedUpdate' .layout (\x c -> { c | layout = x }) update'
  in
    Parts.pack' embeddedUpdate


{-| Component subscriptions (type compatible with render). Either this or 
`subscriptions` must be connected for the Layout to be responsive under
viewport size changes. 
-}
subs : (Parts.Msg (Container b) -> c) -> Container b -> Sub c
subs lift = 
  .layout >> subscriptions >> Sub.map (pack >> lift)


{-| Component subscription initialiser. Either this or 
`init` must be connected for the Layout to be responsive under
viewport size changes. Example use: 
-}
sub0 : (Parts.Msg (Container b) -> c) -> Cmd c
sub0 lift = 
  snd init |> Cmd.map (pack >> lift)


{-| Toggle drawer. 

This function is for use with parts typing. For plain TEA, simply issue 
an update for the exposed Msg `ToggleDrawer`. 
-}
toggleDrawer : (Parts.Msg (Container b) -> c) -> c
toggleDrawer lift = 
  (pack >> lift) ToggleDrawer 


{-| Set tabsWidth

This function is for use with parts typing. For plain TEA, simply set the
`tabsWidth` field in Model. 
-}
setTabsWidth : Int -> Container b -> Container b
setTabsWidth w container = 
  { container 
  | layout = setTabsWidth' w container.layout
  }


