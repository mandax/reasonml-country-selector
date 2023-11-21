@react.component
let make = (~children) => {
  // TODO(@mandax): extract scattered pieces of keyboard control and move it to here
  // NOTE(@mandax): this module relies on element.id, make this smarter

  let (focusableElements, setFocusableElements) = React.useState(list{})

  React.useEffect(() => {
    Document.window->Document.Window.setOnKeyUp(_ => {
      // TODO(@mandax): This is super heavy, should lazy load this list
      // TODO(@mandax): query select only children elements
      Document.querySelectorAll(`a[href], button, input, select, textarea, *[tabindex]`)
      ->Js.Array.from
      ->Belt.List.fromArray
      ->setFocusableElements
    })
  }, [setFocusableElements])

  let rec focusNext = (elements: list<Document.element>) => {
    switch elements {
    | list{element, nextElement, ...rest} =>
      if element.id == Document.activeElement.id {
        nextElement->Document.Element.focus
      } else {
        focusNext(rest)
      }
    | _ => ()
    }
  }

  // ReactUse.useKeyPressEvent("ArrowUp", focusPrevious)
  // ReactUse.useKeyPressEvent("ArrowLeft", focusPrevious)
  ReactUse.useKeyPressEvent("ArrowDown", () => focusNext(focusableElements))
  ReactUse.useKeyPressEvent("ArrowRight", () => focusNext(focusableElements))

  children
}
