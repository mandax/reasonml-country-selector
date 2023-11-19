type element = Jsx.element

external string: string => element = "%identity"
external array: array<element> => element = "%identity"
@val external null: element = "null"

@module("react")
type make<'props> = 'props => element

@module("react/jsx-runtime")
external jsx: (make<'props>, 'props) => element = "jsx"

@module("react/jsx-runtime")
external jsxs: (make<'props>, 'props) => element = "jsxs"

@module("react/jsx-runtime")
external jsxKeyed: (make<'props>, 'props, ~key: string=?, @ignore unit) => element = "jsxs"

