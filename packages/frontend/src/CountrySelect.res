module Api = {
  type t = {
    label: string,
    value: string,
    rank: float,
  }
  type countries = array<t>

  let make = (~label, ~value, ~rank, ()): t => {
    label,
    value,
    rank,
  }
}

@react.component
let make = (~onChange, ~country) => {
  let options: array<Select.Option.t<Api.t>> = [
    {label: "opt1", value: "any"},
    {label: "opt2", value: "any"},
    {label: "opt3", value: "any"},
    {label: "opt4", value: "any"},
    {label: "opt5", value: "any"},
    {label: "opt6", value: "any"},
    {label: "opt7", value: "any"},
  ]

  module Country = {
    let make = ({option}: Select.Option.templateProps<Api.t>) =>
      <span> {`alou teste ${option.label}`->React.string} </span>
  }
  <Select placeholder="Select a country" optionTemplate={Country} onChange options />
}
