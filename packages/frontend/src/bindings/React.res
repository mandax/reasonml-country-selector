type element = Jsx.element

external string: string => element = "%identity"
external array: array<element> => element = "%identity"
@val external null: element = "null"

@module("react")
type make<'props> = 'props => element
type component<'props> = Jsx.component<'props>

@module("react") 
@val external useEffect2: (unit => option<unit => unit>, ('a, 'b)) => unit = "useEffect"

@module("react")
@val external useState: 'any => ('any, 'any => unit) = "useState"

@module("react")
@val external useRef: Js.Nullable.t<Document.element> => JsxDOM.domRef  = "useRef" 

let option = (element: option<element>): element => switch element {
  | Some(elm) => elm
  | None => null
}

module Context = {
  type t<'context>
  type props<'context> = {
    value: 'context,
    children: Jsx.element
  }

  @get external provider: t<'context> => make<props<'context>> = "Provider"
}

@module("react")
@val external createContext: 'any => Context.t<'any> = "createContext"

module Ref = {
  @get external current: JsxDOM.domRef => Document.element = "current" 
}

@module("react/jsx-runtime")
external jsx: (make<'props>, 'props) => element = "jsx"

@module("react/jsx-runtime")
external jsxs: (make<'props>, 'props) => element = "jsxs"

@module("react/jsx-runtime")
external jsxKeyed: (make<'props>, 'props, ~key: string, @ignore unit) => element = "jsxs"

