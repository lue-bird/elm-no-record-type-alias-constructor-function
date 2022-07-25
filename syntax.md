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
            I'd be in favor if adding an extra `->` before functions as well
  - same vs different brackets for record and choice
      - we don't have separate bracket symbols for functions as well
      - different brackets makes it easy to differentiate record from choice
      - different brackets means `< Tag value >  /=  { Tag value }`
          - `<>` becomes the never type
          - `{}` becomes the unit type
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

### type declaration

```elm
Translate mapped unmapped =
    ( In2Ways
        ( Map (unmapped -> mapped)
        , Unmap (mapped -> unmapped)
        )
    )
```

To discuss
- `type alias <type> =` → `<type>`
    - simple
    - less distinct from value, function declarations
