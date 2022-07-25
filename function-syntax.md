## function declaration

## type declaration

```elm
Translate mapped unmapped =
    In2Ways (unmapped -> mapped) (mapped -> unmapped)
```

to discuss:
- `type alias <type> =` → `<type>`
    - simple
    - less distinct from value, function declarations
- `<type> <arguments> =` → `<type> = \<arguments> ->`
    - symmetrical to function declarations
    - all types must be constructed with specified arguments anyway

## function type

```elm
map :
    ->  (-> element
            elementMapped
        )
        (-> (List element)
            (List elementMapped)
        )
```

  - makes currying more obvious
  - discourages reaching for undescriptive positional arguments too often
  - differentiates function, value types on first glance

to discuss:
  - format `->\n<type>\n<type>` vs `-> <type>\n<type>`

Alternative proposals
```elm
map :
    \   (\  element
         -> elementMapped
        )
    ->  (-> (List element)
         -> (List elementMapped)
        )
```
↓ only fixes ""
```elm
map :
    ->  (-> element
         -> elementMapped
        )
    -> List element
    -> List elementMapped
```
```elm
map :
    ->  (-> element
            elementMapped
        )
        (List element)
        (List elementMapped)
```

