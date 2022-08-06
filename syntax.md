### syntax for record, choice, function

```elm
Result value error =
    ( #Failure error
    | #Success value
    )

case result of
    #Failure error ->
        error.Expected.Minimum
    
    #Success value ->
        value

Code code =
    ( code
    , #Imports Imports
    , #Range (Range2d Int)
    )

countInitial : ( #Count0 Int, #Count1 Int )
countInitial =
    ( #Count0 0, #Count1 0 )

map :
    (  (  element
       -> elementMapped
       )
    -> (  (List element)
       -> (List elementMapped)
       )
    )
```

To discuss
  - 1 value per tag, disallowing positional values
  - leading symbol per tag: different for variant `|`, field `,`/`&` in `(  )`
    vs just one symbol `#`/`-`/`'` in `( | | )` and `( , , )`
    vs just one symbol `#`/`-`/`'` in `< | | >` and `{ , , }`
      - one symbol in `( | | )` and `( , , )` unifies 1-field record and 1-variant choice
          - allows reusing `.Tag` to access the value
            (and `!Tag` to map the value if it gets implemented)
          - adding another variant in another branch is easier
      - different brackets or leading symbols means `< #tag value >  /=  { #tag value }`
          - `<>` becomes the never type
          - `{}` becomes the unit type
          - can't reuse .Tag to access the value
            (nor `!Tag` to map the value if it gets implemented)
      - (subjective)
        only leading symbol without brackets looks confusing
        ```elm
        -> | Ok Int | Err (List DeadEnd) -> | Ok Int | Err String
        -> , Count0 Int , Count1 Int -> , Count0 Int , Count1 Int
        ```
      - unique brackets or leading symbols makes it easy to differentiate record, choice
          - even without, it's probably obvious enough (see function types currently)
      - unique brackets enable `{}` as unit, `<>` as never without separate types
      - same brackets make `{}`/`<>` invalid syntax
          - ```elm
            Blank = #Blank
            Impossible = #Still Impossible

            -- magically: blank = empty record, Impossible = empty choice
            Name = Named Blank
            Weekday = WeekdayAnd Impossible
            ```
            have to be declared as separate types
  - `<ext> ||/& ( |/, )` vs `( <ext> |/, |/, )`
      - `,`/`|` is faster to type than `&`/`||`
      - `||`/`&` as extra symbols seem unnecessary
      - `,`/`|` might be understood as "another single element"
        `&`/`||` might be understood as "and"
  - `#tag` vs `#Tag`
      - symmetrical to `VariantTag`
      - allows reusing `.Tag` to access the value
        (and `!Tag` to map the value if it gets implemented)
      - `#Tag` looks distinct in types, less easy to mix up with variables
      - `#Tag` forbids field punning
          - points in earlier discussion;
            basically improves descriptiveness and scales better
      - having fields like `( #Camera Camera, #Mood Mood, #Lighting Lighting, #Rules Rules )`
        _might_, even though it's unambiguous, be confusing: "which is the type, what's the type?"
      - `#tag` is easier and faster to type
          - gren-format could auto-uppercase the tags
  - `<Tag> : <constructor> <arguments>` vs leading symbol + `<Tag> (<constructor> <arguments>)` and
    `<field> = <constructor> <argument>` → `<field> (<constructor> <arguments>)`
      - `:` is more visually obvious, so `: (...)` isn't needed
      - `<Tag>` `:` (of type) `<value>`.
        A tag isn't _of a type_, it has a type _attached_
      - (subjective) not having a separator reads cleanly, `=`/`:` stop flow
      - (subjective) not including `(...)` looks like multiple attached values
          - not an issue if variants are forbidden from having multiple arguments
      - (subjective) not including `(...)` is harder to parse visually
  - force `->` to have 2 arguments?
      - makes currying extremely obvious and explicit
      - discourages reaching for undescriptive positional arguments too often
  - forcing `( ... )` vs gren-formatting away unnecessary `( ... )`
      - forcing `( ... )` is more consistent and obvious
      - (subjective)
        not forcing `( ... )` _might_ look weird: "Which level deep is the tag, what's the value?"
        ```elm
        ( #Name #Blank, #Status #Blank )
        ```
      - a sign there's more to look for below the first argument
      - (subjective) _strong might_ look confusing as a result for example:
        ```elm
        countInitial : Count0 ( Ok Int | Err DeadEnd ), Count1 ( Ok Int | Err DeadEnd )
        ```
      - forcing `( ... )` for patterns, constructors (1-field record, variant)
        is pointless and complicates code since they aren't functions anymore:
        ```elm
        list |> List.map change |> InsideStructure |> List |> Structure
        ```
        becomes
        ```elm
        list
            |> List.map change
            |> (\mapped -> ( #InsideStructure mapped ))
            |> (\mapped -> ( #List mapped ))
            |> (\mapped -> ( #Structure mapped ))
        ```
          - you could argue that constructors shouldn't be applied in pipeline style (I disagree)
          - we could exclude forcing `( ... )` for variants and 1-field records

### type declaration

```elm
Translate mapped unmapped =
    ( #bothWays
        ( Map ( unmapped -> mapped )
        , Unmap ( mapped -> unmapped )
        )
    )
```

To discuss
- `type alias <type> =` vs `<type>`
    - simple
    - less distinct from value, function declarations
