> trick: no record `type alias` constructor function

[forms example in guide.elm-lang.org](https://guide.elm-lang.org/architecture/forms.html):
```elm
type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    }

init : Model
init =
    Model "" "" ""
```
↑ Every directly aliased record type gets its default constructor function.

You can trick the compiler into not creating a `Model` record constructor function:

```elm
import RecordWithoutConstructorFunction exposing (RecordWithoutConstructorFunction)

type alias Model =
    RecordWithoutConstructorFunction
        { name : String
        , password : String
        , passwordAgain : String
        }

init : Model
init =
    -- Model "" "" ""  <- error
    { name = "", password = "", passwordAgain = "" }
```

where

```elm
type alias RecordWithoutConstructorFunction record =
    record
```


### tips

  - find & fix your current _usages_ of record `type alias` constructor functions with [elm-review-record-alias-constructor](https://dark.elm.dmy.fr/packages/lue-bird/elm-review-record-alias-constructor/latest/)

  - at the time of writing this, there's no elm-review rule to auto-insert `RecordWithoutConstructorFunction`.
    To find possible aliases, try regex searching for `alias .*=.*\n.*\{`

## why

Fields in a record don't have a "natural order".

```elm
{ age = 42, name = "Balsa" }
== { name = "Balsa", age = 42 }
--> True
```

So it shouldn't matter whether you write

```elm
type alias User =
    { name : String, age : Int }
or  { age : Int, name : String }
```
as well.

```elm
User "Balsa" 42
```
however relies on a specific field order in the type and is more difficult to understand/read.
These constructors also open up the possibility for bugs to sneak in without the compiler warning you:

```elm
type alias User =
    { status : String
    , name : String 
    }

decodeUser : Decoder User
decodeUser =
    map2 User
        (field "name" string)
        (field "status" string)
```
Did you spot the mistake? [↑ a similar example](https://sporto.github.io/elm-patterns/advanced/pipeline-builder.html#caveat)

To avoid these kinds of bugs, just **forbid type alias constructors**:
```elm
type alias User =
    RecordWithoutConstructorFunction ...
```

Problems don't end there.

### implicit magic

> ["There are worse things than being explicit" – Evan](https://twitter.com/evancz/status/928359289135046656)

Most record type aliases are not intended to work with positional arguments!
`Model` is the perfect example.

Even if you think it's ok currently, no one reminds you when you add new fields.

### there are better alternatives

It's so easy to create an explicit constructor

```elm
xy : Float -> Float -> { x : Float, y : Float }
```

As argued, unnamed arguments shouldn't be the _default_.

Additionally, your record will be more descriptive and type-safe as a `type`

```elm
type Cat
    = Cat { mood : Mood, birthTime : Time.Posix }
```

to make wrapping, unwrapping and combining easier, you can try [typed-value](https://dark.elm.dmy.fr/packages/lue-bird/elm-typed-value/latest/).

### only works in very limited scenarios

```elm
type alias Record =
    { someField : () }

type alias Indirect =
    Record
```

  - `Record` has a constructor function
  - `Indirect` doesn't have a constructor function

```elm
type alias Extended record =
    { record | someField : () }

type alias Constructed =
    Extended {}
```

  - `Constructed`, `Extended` don't have constructor functions

### name clash with variant

example adapted from [`Elm.Syntax.Exposing`](https://dark.elm.dmy.fr/packages/stil4m/elm-syntax/latest/Elm-Syntax-Exposing#TopLevelExpose)
```elm
type TopLevelExpose
    = ...
    | TypeExpose TypeExpose

type alias TypeExpose =
    { name : String
    , open : Maybe Range
    }
```
> NAME CLASH - multiple defined `TypeExpose` type constructors.
> 
> How can I know which one you want? Rename one of them!

Either rename `type alias TypeExpose` to `TypeExposeData`/... or
```elm
type alias TypeExpose =
    RecordWithoutConstructorFunction ...
```
and **get rid of the compile-time error**

### `succeed`/`constant` are misused

I'd consider `succeed`/`constant`/... in record `Decoder`s/`Generator`s/... unidiomatic.
You don't decode or randomly generate anything there.

```elm
projectDecoder : Decoder Project
projectDecoder =
    map2
        (\name scale selected ->
            { name = name
            , scale = scale
            , selected = selected
            }
        )
        (field "name" string)
        (field "scale" float)
        (succeed NothingSelected) -- weird
```

Constants should much rather be introduced explicitly in a translation step:

```elm
projectDecoder : Decoder Project
projectDecoder =
    map2
        (\name scale ->
            { name = name
            , scale = scale
            , selected = NothingSelected
            }
        )
        (field "name" string)
        (field "scale" float)
```

For record `Codec`s (from [MartinSStewart's `elm-serialize`](https://package.elm-lang.org/packages/MartinSStewart/elm-serialize/latest/) in this example) where we don't need to encode every field value:

```elm
serializeProject : Codec String Project
serializeProject =
    record Project
        |> field .name string
        |> field .scale float
        |> field .selected
            (succeed NothingSelected)
        |> finishRecord
```
`succeed` is a weird concept for codecs because some dummy value must be encoded which will never be read.

It does not exist in elm-serialize, but it does exist in [miniBill's `elm-codec`](https://package.elm-lang.org/packages/miniBill/elm-codec/latest) (, [prozacchiwawa's `elm-json-codec`](https://package.elm-lang.org/packages/prozacchiwawa/elm-json-codec/latest), ...):
> Create a Codec that produces null as JSON and always decodes as the same value.

Do you really want this behavior? If not, you'll need
```elm
serializeProject : Codec String Project
serializeProject =
    record
        (\name scale ->
            { name = name
            , scale = scale
            , selected = NothingSelected
            }
        )
        |> field .name string
        |> field .scale float
        |> finishRecord
```
Why not consistently use this record constructing method?

This will also be used often for versioning
```elm
enum ProjectVersion0 [ ... ]
    |> andThen
        (\version ->
            case version of
                ProjectVersion0 ->
                    record
                        (\name -> { name = name, scale = 1 })
                        |> field .name string
                        |> finishRecord
                    
                ...
        )
```
Again: Why not consistently use this record constructing method?

## suggestions?
→ [contributing](https://github.com/lue-bird/elm-no-record-type-alias-constructor-function/blob/master/contributing.md).

## why a whole package

`RecordWithoutConstructorFunction.elm` can simply be copied to your project.

However, if you want

  - no separate `RecordWithoutConstructorFunction`s hanging around
  - a single place for up to date public documentation
  - a common recognizable name
      - an elm-review rule that adds `RecordWithoutConstructorFunction` (doesn't exist at the time of writing)
  - (additional safety that `RecordWithoutConstructorFunction` will never aliased to a different type)

consider
```monospace
elm install lue-bird/elm-no-record-type-alias-constructor-function
```