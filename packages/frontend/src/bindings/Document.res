type element

@val @scope("document") 
external unsafeGetElementById: string => element = "getElementById"

module Event = {
  type t
  @get external target: t => Js.Array.t<element> = "target"
}

@val @scope("document") 
external addEventListener: (string, Event.t => unit) => unit = "addEventListener"

@val @scope("document") 
external removeEventListener: (string, Event.t => unit) => unit = "addEventListener"


