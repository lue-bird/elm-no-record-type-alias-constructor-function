module RecordWithoutConstructorFunction exposing (RecordWithoutConstructorFunction)

{-|

> trick: no record `type alias` constructor function

@docs RecordWithoutConstructorFunction

-}


{-| Every directly aliased record type gets its default constructor function:

    type alias Point =
        { x : Float, y : Float }

    Point 4 2
    --> { x = 4, y = 2 }

you can avoid this by using

    type alias Record =
        RecordWithoutConstructorFunction
            { yourCurrentRecord }


## why

Automatic record constructor functions come with countless problems:

  - order matters

    example from [elm-review-record-alias-constructor](https://dark.elm.dmy.fr/packages/lue-bird/elm-review-record-alias-constructor/latest/)

        type alias User =
            { status : String
            , name : String
            }

        decodeUser =
            map2 User
                (field "name" string)
                (field "status" string)

    Did you spot the mistake?

  - possible name clashes

        type Declaration
          = Function Function
          | ...

        type alias Function =
            { expression : Expression, ... }

  - patterns like record `succeed`/`constant` are encouraged

  - patterns like using a `type` are discouraged

  - doesn't work for indirect or extensible aliases

  - **read more in the [readme](https://dark.elm.dmy.fr/packages/lue-bird/elm-no-record-type-alias-constructor-function/latest/)!**


### tips

  - find & fix your current _usages_ of record `type alias` constructor functions with [elm-review-record-alias-constructor](https://dark.elm.dmy.fr/packages/lue-bird/elm-review-record-alias-constructor/latest/)

  - at the time of writing this, there's no elm-review rule to auto-insert `RecordWithoutConstructorFunction`.
    To find possible aliases, try regex searching for `alias .*=.*\n.*\{`

-}
type alias RecordWithoutConstructorFunction record =
    record
