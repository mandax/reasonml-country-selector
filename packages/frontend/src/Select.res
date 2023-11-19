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
  ~selected: Option.t<'a>=?,
  ~placeholder: string=?,
  ~options: array<Option.t<'a>>,
  ~prependChildren=?, 
  ~appendChildren=?,
  ()) => {

  let onSelectOption = (option, _) => onChange(option)
  let renderOption = opt => <Option key={opt.id} option={opt} onSelect={onSelectOption} />

  <div className="select">
    <button className="selected">
      {switch selected {
        | None => placeholder->Belt.Option.getWithDefault("Select")
        | Some(opt) => opt.label
      }->React.string}
    </button>
    <div className="dropdown">
      {prependChildren->Belt.Option.getWithDefault(React.null)}
      <ul>
        {options->Array.map(renderOption)->React.array}
      </ul>
      {appendChildren->Belt.Option.getWithDefault(React.null)}
    </div>
  </div>
}
