type asyncOptions<'a> = Async.t<array<Select.Option.t<'a>>>

module Loading = {
  @react.component
  let make = (~asyncOptions: asyncOptions<'a>) =>
    switch asyncOptions {
    | Loading => <div className="progress-bar" />
    | Empty
    | Ok(_) => React.null
    }
}

module Search = {
  @react.component
  let make = (~onChange) => {
    let id = React.useId()
    <div className="search">
      <IconSearch />
      <input id={id} type_="text" onChange placeholder="Search" />
    </div>
  }
}

@react.component
let make = (
  ~optionTemplate=?,
  ~onChange,
  ~onTypeSearch=?,
  ~placeholder=?,
  ~selected,
  ~options: asyncOptions<'a>,
) => {
  <Select
    ?placeholder
    ?optionTemplate
    selected
    onChange
    prependChildren={<>
      {switch onTypeSearch {
      | Some(onTypeSearch) => <Search onChange={onTypeSearch} />
      | None => React.null
      }}
      <Loading asyncOptions={options} />
    </>}
    options={options->Async.someWithDefault([])}
  />
}
