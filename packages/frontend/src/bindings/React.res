type element = Jsx.element

external string: string => element = "%identity"

@module("react")
type make<'props> = 'props => Jsx.element

@module("react/jsx-runtime")
external jsx: (make<'props>, 'props) => Jsx.element = "jsx"

