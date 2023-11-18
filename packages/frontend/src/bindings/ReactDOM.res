module Container = {
  type t 
  @send external render: (t, React.element) => unit = "render"
}

@module("react-dom/client")
external createRoot: (Document.element) => Container.t = "createRoot"

external someElement: React.element => option<React.element> = "%identity"

@module("react/jsx-runtime")
external jsx: (string, JsxDOM.domProps) => Jsx.element = "jsx"
