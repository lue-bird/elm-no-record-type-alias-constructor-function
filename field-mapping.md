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
