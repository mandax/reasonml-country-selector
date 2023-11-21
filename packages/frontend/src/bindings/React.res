type element = Jsx.element

external string: string => element = "%identity"
external array: array<element> => element = "%identity"
@val external null: element = "null"

@module("react")
type make<'props> = 'props => element
type component<'props> = Jsx.component<'props>

@module("react") @val external useState: 'any => ('any, 'any => unit) = "useState"

@module("react") @val external useId: unit => string = "useId"

module Ref = {
  type t<'any> = {mutable current: 'any}

  @module("react") @val external useRef: 'any => t<'any> = "useRef"

  external toDomRef: t<'any> => JsxDOM.domRef = "%identity"

  let useContainsActiveRef = (ref: t<'a>) => {
    switch ref.current->Js.Nullable.toOption {
    | None => false
    | Some(element: Document.element) => element->Document.Element.contains(Document.activeElement)
    }
  }

  let useActiveRef = (ref: t<'a>) => {
    switch ref.current->Js.Nullable.toOption {
    | None => false
    | Some(element: Document.element) => element == Document.activeElement
    }
  }
  let useRefElement = (ref: t<'a>): option<Document.element> => {
    ref.current->Js.Nullable.toOption
  }
}

let option = (element: option<element>): element =>
  switch element {
  | Some(elm) => elm
  | None => null
  }

type reducer<'state, 'action> = ('state, 'action) => 'state
type dispatch<'action> = 'action => unit

@module("react")
external useReducer: (reducer<'state, 'action>, 'state) => ('state, dispatch<'action>) =
  "useReducer"

@module("react")
external useMemo: ('any => unit, _, 'any) => unit = "useMemo"

@module("react")
external // TODO(@mandax): Can break in runtime, research how to better handle useEffect dependencies
useEffect: (unit => unit, _) => unit = "useEffect"

@module("react")
external useEffectWithUnmount: ((unit, unit) => unit, _) => unit = "useEffect"

module Children = {
  @module("react") @scope("Children")
  external each: (element, (Document.element, string) => unit) => unit = "forEach"
}

// TODO(@mandax): Improve this with a functor
module SideEffect = {
  type action<'effects> = CleanEffects | SetEffects(list<'effects>)
  type state<'effects> = {effects: list<'effects>}

  let empty = {effects: list{}}

  let internalReducer = (state, action) =>
    switch action {
    | CleanEffects => {effects: list{}}
    | SetEffects(effects) => {effects: state.effects->List.concat(effects)}
    }

  let useReducer = (reducer, reducerEffect, initState) => {
    let (internalState, internalDispatch) = useReducer(internalReducer, empty)

    let pushEffects = (state, effects: list<'effect>) => {
      internalDispatch(SetEffects(effects))->ignore
      state
    }

    let (state, dispatch) = useReducer(reducer(pushEffects), initState)

    let rec executeEffects = (effects, state, dispatch) =>
      switch effects {
      | list{effect, ..._} =>
        reducerEffect(state, effect, dispatch)
        executeEffects(effects->List.drop(1)->Belt.Option.getWithDefault(list{}), state, dispatch)
      | _ => ()
      }

    useEffect(() => {
      executeEffects(internalState.effects, state, dispatch)
      internalDispatch(CleanEffects)->ignore
    }, (internalState.effects, state, dispatch))
    (state, dispatch)
  }
}

module Form = {
  @scope("target") @get external getTargetValue: JsxEvent.Form.t => string = "value"
}

@module("react/jsx-runtime")
external jsx: (make<'props>, 'props) => element = "jsx"

@module("react/jsx-runtime")
external jsxs: (make<'props>, 'props) => element = "jsxs"

type fragmentProps = {children: array<element>}
@module("react/jsx-runtime")
external jsxFragment: component<fragmentProps> = "Fragment"

@module("react/jsx-runtime")
external jsxKeyed: (make<'props>, 'props, ~key: string, @ignore unit) => element = "jsxs"
