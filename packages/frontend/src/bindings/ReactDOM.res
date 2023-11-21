module Container = {
  type t
  @send external render: (t, React.element) => unit = "render"
}

@module("react-dom") @as("ReactDOM")
external findDOMNode: string => Document.element = "findDOMNode"

@module("react-dom/client")
external createRoot: Document.element => Container.t = "createRoot"

external someElement: React.element => option<React.element> = "%identity"

@module("react/jsx-runtime")
external jsx: (string, JsxDOM.domProps) => Jsx.element = "jsx"

@module("react/jsx-runtime")
external jsxs: (string, JsxDOM.domProps) => Jsx.element = "jsxs"

@module("react/jsx-runtime")
external jsxKeyed: (string, JsxDOM.domProps, ~key: string=?, @ignore unit) => Jsx.element = "jsxs"
