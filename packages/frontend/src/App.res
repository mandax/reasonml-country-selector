module Content = {
  @react.component
  let make = () => {
    let onChange = val => Js.log(val)
    let options: array<Select.Option.t<string>> = [
      {label: "opt1", value: "any"},
      {label: "opt2", value: "any"},
      {label: "opt3", value: "any"},
      {label: "opt4", value: "any"},
      {label: "opt5", value: "any"},
      {label: "opt6", value: "any"},
      {label: "opt7", value: "any"},
    ]

    module Template = {
      let make = ({label}: Select.Option.templateProps) =>
        <span> {`alou teste ${label}`->React.string} </span>
    }

    <main>
      <h1> {"Rescript Country Selector"->React.string} </h1>
      <CountrySelect country={Some("us")} onChange={c => Js.log(c)} />
    </main>
  }
}

Document.unsafeGetElementById("app")->ReactDOM.createRoot->ReactDOM.Container.render(<Content />)
