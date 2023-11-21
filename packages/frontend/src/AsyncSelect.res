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

@react.component
let make = (
  ~optionTemplate=?,
  ~onChange,
  ~onTypeSearch=?,
  ~placeholder=?,
  ~selected=?,
  ~options: asyncOptions<'a>,
) => {
  <Select
    ?placeholder
    ?optionTemplate
    ?selected
    onChange
    prependChildren={<>
      {switch onTypeSearch {
      | Some(onTypeSearch) =>
        <div className="search">
          <IconSearch />
          <input type_="text" onChange={onTypeSearch} placeholder="Search" />
        </div>
      | None => React.null
      }}
      <Loading asyncOptions={options} />
    </>}
    options={options->Async.someWithDefault([])}
  />
}
