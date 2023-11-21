module Option = {
  type t<'any> = {
    label: string,
    value: 'any,
  }

  type templateProps<'any> = {
    option: t<'any>,
    selected: bool,
  }

  type onSelect<'a> = (t<'a>, JsxEvent.Mouse.t) => unit

  @react.component
  let make = (
    ~option: t<'a>,
    ~optionTemplate: option<React.component<templateProps<'a>>>=?,
    ~onSelect: onSelect<'a>,
    (),
  ) => {
    <li onClick={onSelect(option)}>
      {switch optionTemplate {
      | Some(template) => template({option, selected: false})
      | None => option.label->React.string
      }}
    </li>
  }
}

@react.component
let make = (
  ~onChange: Option.t<'a> => unit,
  ~selected: option<Option.t<'a>>,
  ~placeholder: option<string>=?,
  ~options: array<Option.t<'a>>,
  ~optionTemplate: option<React.component<Option.templateProps<'a>>>=?,
  ~prependChildren=?,
  ~appendChildren=?,
  (),
) => {
  let (isOpen, setOpen) = React.useState(false)
  let onSelectOption = (option, _) => onChange(option)
  let toggleDropdown = _ => setOpen(!isOpen)
  let dropdownElement = React.useRef(Js.Nullable.null)

  let renderOption = (opt, i) =>
    <Option
      ?optionTemplate key={`${i->Int.toString}-${opt.label}`} option={opt} onSelect={onSelectOption}
    />

  let renderSelectedOption = opt =>
    switch optionTemplate {
    | Some(template) => template({option: opt, selected: true})
    | None => opt.label->React.string
    }

  <div className="select">
    <button onClick={toggleDropdown} className="select__selector">
      {switch selected {
      | None => placeholder->Belt.Option.getWithDefault("Select")->React.string
      | Some(opt) => renderSelectedOption(opt)
      }}
    </button>
    <div
      ref={dropdownElement}
      className={`select__dropdown ${isOpen ? "" : "select__dropdown--close"}`}>
      {prependChildren->Belt.Option.getWithDefault(React.null)}
      <ul> {options->Array.mapWithIndex(renderOption)->React.array} </ul>
      {appendChildren->Belt.Option.getWithDefault(React.null)}
    </div>
  </div>
}
