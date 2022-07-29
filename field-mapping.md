### field mapping
Introducing syntax for changing one specific field value

```elm
!Name :
    (value -> valueMapped)
    -> ( record, Name value )
    -> ( record, Name valueMapped )
```

which one previously had to write as

```elm
(\alter -> \record -> { record | name = record.name |> alter }) :
    (value -> valueMapped)
    -> ( record, Name value )
    -> ( record, Name valueMapped )
```

  - verbose
  - really hard to scale (nested lambdas, branching modifying different fields, indentation 🚀)
  - possibly confusing for beginners (what does `|` mean? why are consecutive fields updated with `,`, nested updates look awful, ...)


```elm
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


Apart from syntax, the proposed syntax also allows changing the field value's type

```elm
Blank =
    Blank

succeed ( Name Blank, Status Blank, Metadata metadataDefault )
    |> field !Name "name" string
    |> field !Status "status" string
```

  - simple
  - declarative `succeed` showing the final shape
  - field value changes are drastically simpler and less verbose

To discuss
  - symbol `!` vs `/`
      - `!`, `/` look like "action"
      - `!` looks like `.` (field access) with something else on top
      - (subjective) `/` is hard and confusing to read with lambdas
  - function vs `infix`
      - `infix` is slightly more compact
      - function reads better alongside other transformations
      - `infix` can't be curried
      - all `infix`es are just symbols, `!<Name>` would be confusing
      - → a function solves the problems well enough
        to not need a more complex system around it

Small extra!
If 1-field records and 1-variant choices unify:
```elm
Pet specificProperties =
    ( specificProperties
    , Name String
    , Hunger Progress
    )

Cat =
    ( Cat ( NapsPerDay Float ) )

Dog =
    ( Dog ( BarksPerDay Float ) )

sit : ( Dog -> Dog )
sit =
    !Dog (!Hunger (Progress.by 0.01))

howdy =
    ( Cat ( Name "Howdy", Hunger Progress.begin, NapsPerDay 2.2 ) )

howdy |> sit -- error
```
removing the intermediate need for boilerplate.
