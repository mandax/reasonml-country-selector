type element = {@optional id: string}

@val @scope("document")
external unsafeGetElementById: string => element = "getElementById"

@val @scope("document")
external querySelectorAll: string => Js.Array.array_like<element> = "querySelectorAll"

module Event = {
  type t
  @get external target: t => element = "target"
  @get external targets: t => Js.Array.t<element> = "target"
  @get external keyPressed: t => string = "key"
}

module Window = {
  type t
  @set external setOnKeyUp: (t, Event.t => unit) => unit = "onkeyup"
  @set external setOnFocusIn: (t, Event.t => unit) => unit = "onfocusin"
}

@val
external window: Window.t = "window"

@val @scope("document")
external activeElement: element = "activeElement"

@val @scope("document")
external addEventListener: (string, Event.t => unit) => unit = "addEventListener"

@val @scope("document")
external removeEventListener: (string, Event.t => unit) => unit = "addEventListener"

module Element = {
  @set external setOnFocus: (element, Event.t => unit) => unit = "onfocus"
  @set external setOnBlur: (element, Event.t => unit) => unit = "onblur"
  @send external contains: (element, element) => bool = "contains"

  @send external focus: element => unit = "focus"
  @send external blur: element => unit = "blur"

  @send
  external querySelectorAll: (element, string) => Js.Array.array_like<element> = "querySelectorAll"
}

module Form = {
  @get external getValue: element => string = "value"
  @set external setValue: (element, string) => unit = "value"
}
