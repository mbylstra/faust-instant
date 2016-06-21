module Util exposing (..)

import String

{- from @xarv in the Elm Slack elm-dev channel -}
unindent : String -> String
unindent multilineString =
    let
        lines =
            String.lines multilineString

        countLeadingSpaces line =
            case String.uncons line of
                Nothing -> 0
                Just (char, xs) ->
                    case char of
                        ' ' -> 1 + countLeadingSpaces xs
                        _ -> 0

        minLead =
            lines
            |> List.filter (String.any ((/=) ' '))
            |> List.map countLeadingSpaces
            |> List.minimum
            |> Maybe.withDefault 0

    in
        lines
        |> List.map (String.dropLeft minLead)
        |> String.join "\n"


{-| Extract the value, if it's `Just`, or throw an error, if it's `Nothing`.
This is a *dangerous* function and you should do your best to not use it at all in your code. Instead of trying to extract values from `Just`, you should operate within the `Maybe` context by using `Maybe.map`, or extract safely using default value with `Maybe.withDefault`. If you use `unsafe` heavily, consider changing your code style to more idiomatic and type-safe.
-}
unsafeMaybe : Maybe a -> a
unsafeMaybe v =
  case v of
    Nothing -> Debug.crash "unexpected crash when using the Util.unsafe function"
    Just x -> x

unsafeResult : Result err value -> value
unsafeResult r =
  case r of
    Err msg -> Debug.crash (toString msg)
    Ok v -> v

last : List a -> Maybe a
last l =
  l
  |> List.drop ((List.length l) - 1)
  |> List.head

  -- unsafe toFloat s
