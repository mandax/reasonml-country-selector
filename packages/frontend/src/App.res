module Content = {
  @react.component
  let make = () => {
    let onChange = val => Js.log(val)

    <main>
      <h1> {"Rescript Country Selector"->React.string} </h1>
      <CountrySelect country={Some("us")} onChange />
    </main>
  }
}

Document.unsafeGetElementById("app")->ReactDOM.createRoot->ReactDOM.Container.render(<Content />)
