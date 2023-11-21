type element = Jsx.element

external string: string => element = "%identity"
external array: array<element> => element = "%identity"
@val external null: element = "null"

@module("react")
type make<'props> = 'props => element
type component<'props> = Jsx.component<'props>

@module("react") @val
external useEffect2: (unit => option<unit => unit>, ('a, 'b)) => unit = "useEffect"

@module("react") @val external useState: 'any => ('any, 'any => unit) = "useState"

@module("react") @val external useRef: Js.Nullable.t<Document.element> => JsxDOM.domRef = "useRef"

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

@module("react") @variadric
external useEvent: (array<'any> => unit) => unit = "useEvent"

@module("react")
external // TODO(@mandax): Can break in runtime, research how to better handle useEffect dependencies
useEffect: (unit => unit, _) => unit = "useEffect"

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

module Ref = {
  @get external current: JsxDOM.domRef => Document.element = "current"
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
