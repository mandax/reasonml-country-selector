module Option = {
  type t<'any> = {
    id: string,
    label: string, 
    value: 'any
  }

  type onSelect<'a> = (t<'a>, JsxEvent.Mouse.t) => unit

  @react.component
  let make = (~option: t<'a>, ~onSelect: onSelect<'a>,()) => {
    <li onClick={onSelect(option)}>
      {option.label->React.string}
    </li>
  }
}

@react.component
let make = (
  ~onChange: Option.t<'a> => unit, 
  ~selected: option<Option.t<'a>>=?,
  ~placeholder: option<string>=?,
  ~options: array<Option.t<'a>>,
  ~prependChildren=?, 
  ~appendChildren=?,
  ()) => {

  let (isOpen, setOpen) = React.useState(false)
  let onSelectOption = (option, _) => onChange(option)
  let toggleDropdown = _ => setOpen(!isOpen)
  let dropdownElement = React.useRef(Js.Nullable.null)
  
  let renderOption = opt => <Option key={opt.id} option={opt} onSelect={onSelectOption} />

  <div className="select">
    <button onClick={toggleDropdown} className="select__selector">
      {switch selected {
        | None => placeholder->Belt.Option.getWithDefault("Select")
        | Some(opt) => opt.label
      }->React.string}
    </button>
    <div ref={dropdownElement} className={`select__dropdown ${isOpen ? "" : "select__dropdown--close"}`}>
      {prependChildren->Belt.Option.getWithDefault(React.null)}
      <ul>
        {options->Array.map(renderOption)->React.array}
      </ul>
      {appendChildren->Belt.Option.getWithDefault(React.null)}
    </div>
  </div>
}
