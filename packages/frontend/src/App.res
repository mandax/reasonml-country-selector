module Content = {
  @react.component
  let make = () => {
    let (simpleSelected, setSimpleSelected) = React.useState(None)
    let onChange = value => Js.log(value)

    let options: array<Select.Option.t<string>> = [
      {label: "option 1", value: "opt1"},
      {label: "option 2", value: "opt2"},
      {label: "option 3", value: "opt3"},
      {label: "option 4", value: "opt4"},
      {label: "option 5", value: "opt5"},
      {label: "option 6", value: "opt6"},
      {label: "option 7", value: "opt7"},
      {label: "option 8", value: "opt8"},
    ]

    <KeyboardControl>
      <main>
        <div>
          <div>
            <h1> {"Simple Selector"->React.string} </h1>
            <Select
              options onChange={opt => setSimpleSelected(opt)} selected={simpleSelected}
            />
          </div>
        </div>
        <div>
          <div>
            <h1> {"Rescript Country Selector"->React.string} </h1>
            <CountrySelect country={Some("us")} onChange />
          </div>
        </div>
      </main>
    </KeyboardControl>
  }
}

Document.unsafeGetElementById("app")->ReactDOM.createRoot->ReactDOM.Container.render(<Content />)
