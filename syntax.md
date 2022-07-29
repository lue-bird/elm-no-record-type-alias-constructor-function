### syntax for record, choice, function

```elm
Result value error =
    ( Failure error
    | Success value
    )

case result of
    Failure error ->
        error.Expected.Minimum
    
    Success value ->
        value

Code code =
    ( code
    , Imports Imports
    , Range (Range2d Int)
    )

countInitial : ( Count0 Int, Count1 Int )
countInitial =
    ( Count0 0, Count1 0 )

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
  - leading symbol per tag (variant `|`, field `.` vs `,` vs `&`, function `->`)
    vs `open symbol ... symbol closed` like `( , , )`/`( | | )`/`( -> -> )`
      - not requiring a leading symbol unifies 1-field records and 1-variant choices
          - allows reusing `.Tag` to access the value
            (and `!Tag` to map the value if it gets implemented)
          - adding another variant in another branch is easier
      - (subjective)
        only leading symbol without open-closed looks confusing
        ```elm
        -> | Ok Int | Err (List DeadEnd) -> | Ok Int | Err String
        -> , Count0 Int , Count1 Int -> , Count0 Int , Count1 Int
        ```
      - a unique leading symbol makes it easy to differentiate record, choice, function
          - even without, it's probably obvious enough (see function types currently)
      - `open symbol ... symbol closed` is already used for arrays
  - same vs different brackets for record and choice
      - we don't have separate bracket symbols for functions as well
      - different brackets makes it easy to differentiate record from choice
      - different brackets means `< Tag value >  /=  { Tag value }`
          - `<>` becomes the never type
          - `{}` becomes the unit type
          - can't reuse .Tag to access the value
      - same brackets make `()` invalid syntax
          - ```elm
            Blank = Blank
            Never = OneMore Never
            ```
            have to be declared as separate types
  - `<ext> ||/& ( |/, )` vs `( <ext> |/, |/, )`
      - `,`/`|` is faster to type than `&`/`||`
      - `||`/`&` as extra symbols seem unnecessary
      - `,`/`|` might be understood as "another single element"
        `&`/`||` might be understood as "and"
  - `fieldTag` → `FieldTag`
      - symmetrical to `VariantTag`
      - allows reusing `.Tag` to access the value
        (and `!Tag` to map the value if it gets implemented)
      - distinct in types, less easy to mix up with variables
      - forbids field punning
          - points in earlier discussion;
            basically improves descriptiveness and scales better
      - having fields like `( Camera Camera, Mood Mood, Lighting Lighting, Rules Rules )`
        _might_, even though it's unambiguous, be confusing: "which is the type, what's the type?"
  - `<Tag> : <constructor> <arguments>` vs `<Tag> (<constructor> <arguments>)` and
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
  - force `( ... )`
      - more consistent and obvious
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
            |> (\mapped -> ( InsideStructure mapped ))
            |> (\mapped -> ( List mapped ))
            |> (\mapped -> ( Structure mapped ))
        ```
          - you could argue that constructors shouldn't be applied in pipeline style (I disagree)
          - we could make an exception for these cases (variants and 1-field records)

### type declaration

```elm
Translate mapped unmapped =
    ( In2Ways
        ( Map ( unmapped -> mapped )
        , Unmap ( mapped -> unmapped )
        )
    )
```

To discuss
- `type alias <type> =` → `<type>`
    - simple
    - less distinct from value, function declarations
