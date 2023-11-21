module Option = {
  type t<'any> = {
    label: string,
    value: 'any,
  }

  type templateProps<'any> = {
    option: t<'any>,
    selected: bool,
  }

  type onSelect<'a> = option<t<'a>> => unit

  @react.component
  let make = (
    ~tabIndex,
    ~option: t<'a>,
    ~optionTemplate: option<React.component<templateProps<'a>>>=?,
    ~onSelect: onSelect<'a>,
    (),
  ) => {
    let ref = React.Ref.useRef(Js.Nullable.null)
    let isActive = React.Ref.useActiveRef(ref)
    let element = React.Ref.useRefElement(ref)
    let id = React.useId()

    let removeFocus = () =>
      switch element {
      | Some(elm) => elm->Document.Element.blur
      | _ => ()
      }

    let selectThisOption = () =>
      if isActive {
        onSelect(Some(option))
      }

    ReactUse.useKeyPressEvent("Enter", selectThisOption)
    ReactUse.useKeyPressEvent("Escape", removeFocus)
    ReactUse.useKeyPressEvent("Delete", removeFocus)

    <li id={id} ref={ref->React.Ref.toDomRef} tabIndex onClick={_ => onSelect(Some(option))}>
      {switch optionTemplate {
      | Some(template) => template({option, selected: false})
      | None => option.label->React.string
      }}
    </li>
  }
}

@react.component
let make = (
  ~onChange: option<Option.t<'a>> => unit,
  ~selected: option<Option.t<'a>>,
  ~placeholder: option<string>=?,
  ~options: array<Option.t<'a>>,
  ~optionTemplate: option<React.component<Option.templateProps<'a>>>=?,
  ~prependChildren=?,
  ~appendChildren=?,
  (),
) => {
  let (isOpen, setOpen) = React.useState(false)
  let selector = React.Ref.useRef(Js.Nullable.null)
  let onSelectOption = (opt: option<Option.t<'a>>) => {
    onChange(opt)
    setOpen(false)
  }
  let toggleDropdown = _ => setOpen(!isOpen)
  let isSelectActive = React.Ref.useContainsActiveRef(selector)
  let renderOption = (opt, i) =>
    <Option
      ?optionTemplate
      tabIndex={0}
      key={`${i->Int.toString}-${opt.label}`}
      option={opt}
      onSelect={onSelectOption}
    />
  let id = React.useId()

  // TODO(@mandax): improve keyboard system with a Context
  ReactUse.useKeyPressEvent("Tab", () => setOpen(isSelectActive))
  ReactUse.useKeyPressEvent("Escape", () => setOpen(false))
  ReactUse.useKeyPressEvent("Delete", () =>
    if isSelectActive {
      onSelectOption(None)
      setOpen(false)
    }
  )

  let renderSelectedOption = opt =>
    switch optionTemplate {
    | Some(template) => template({option: opt, selected: true})
    | None => opt.label->React.string
    }

  <div ref={selector->React.Ref.toDomRef} className="select">
    <button id={id} onClick={toggleDropdown} className="select__selector">
      {switch selected {
      | None => placeholder->Belt.Option.getWithDefault("Select")->React.string
      | Some(opt) => renderSelectedOption(opt)
      }}
    </button>
    <div className={`select__dropdown ${isOpen ? "" : "select__dropdown--close"}`}>
      {prependChildren->Belt.Option.getWithDefault(React.null)}
      <ul> {options->Array.mapWithIndex(renderOption)->React.array} </ul>
      {appendChildren->Belt.Option.getWithDefault(React.null)}
    </div>
  </div>
}
