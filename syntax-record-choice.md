### syntax for record and choice

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
```

To discuss:
  - 1 value per tag, disallowing positional values
  - leading symbol per tag (variant `|`, field `.` vs `,` vs `&`)
    vs `open symbol ... symbol closed` like `( , , )`
      - not requiring leading `|` unifies 1-field records and 1-variant choices
          - allows reusing `.Tag` to access the value
          - adding another variant in another branch is easier
      - (subjective)
        only leading symbol without open-closed looks confusing
        ```elm
        | Ok Int | Err (List DeadEnd) -> | Ok Int | Err String
        , Count0 Int , Count1 Int -> , Count0 Int , Count1 Int
        ```
      - leading `|` makes it easy to differentiate
        record from choice
          - similarly to function types, I don't think you have to,
            plus it's kinda obvious enough.
            If we choose leading symbols,
            I'd be in favor if adding an extra `->`/`>` before functions as well
  - same vs different brackets for record and choice
      - leading `|` makes it easy to differentiate
        record from choice
  - `<ext> ||/& ( |/, )` vs `( <ext> |/, |/, )`
      - `,`/`|` is faster to type than `&`/`||`
      - `||`/`&` as extra symbols seem unnecessary
      - `,`/`|` might be understood as "another single element"
        `&`/`||` might be understood as "and"
  - `fieldTag` → `FieldTag`
      - symmetrical to `VariantTag`
      - distinct in types, less easy to mix up with variables
      - forbids field punning pattern (points in earlier discussion)
  - `<Tag> : <constructor> <arguments>` vs `<Tag> (<constructor> <arguments>)` and
    `<field> = <constructor> <argument>` → `<field> (<constructor> <arguments>)`
      - `:` is more visually obvious, so `: (...)` isn't needed
      - `<Tag>` `:` (of type) `<value>`.
        A tag, just like a variant tag isn't _of a type_, it has a type _attached_
      - (subjective) not having a separator reads cleanly, `=`/`:` stop flow
      - (subjective) not including `(...)` looks like multiple attached values
          - not an issue if variants are forbidden from having multiple arguments
      - (subjective) not including `(...)` is harder to parse visually

### field mapping

```elm
Blank =
    Blank

succeed ( Name Blank, Status Blank, Metadata metadataDefault )
    |> field !Name "name" string
    |> field !Status "status" string

!Name :
    (value -> valueMapped)
    -> ( record, Name value )
    -> ( record, Name valueMapped )

model
    |> !PlayerPosition (!Y (\_ -> 0))
    |> !PlayerVelocity
        (\velocity ->
            velocity
                |> !X (\x -> x * 0.95)
                |> !Y (\y -> y * 0.95)
                |> !Y (\y -> y - 1)
        )
    |> checkForCollision
```

  - simple
  - declarative `succeed` showing the final shape
  - field value changes are drastically simpler and less verbose

to discuss:
  - symbol `!` vs `/`
      - `!`, `/` look like "action"
      - `!` looks like `.` (field access) with something else on top
      - (subjective) `/` is hard and confusing to read with lambdas
  - function vs `infix`
      - `infix` is slightly more compact
      - function reads better alongside other transformations
      - `infix` can't be curried
      - all `infix`es are just symbols, `!<Name>` would be confusing
