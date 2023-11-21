type key = string
type keydown = unit => unit

@module("react-use")
external useKeyPressEvent: (key, keydown) => unit = "useKeyPressEvent"
