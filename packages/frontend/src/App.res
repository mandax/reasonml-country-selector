module Content = {

  @react.component
  let make = () => {
  
    let onChange = val => Js.log(val)
    let options: array<Select.Option.t<string>> = [
      { id: "1", label: "opt1", value: "any" },
      { id: "2", label: "opt2", value: "any" },
      { id: "3", label: "opt3", value: "any" },
      { id: "4", label: "opt4", value: "any" },
      { id: "5", label: "opt5", value: "any" },
      { id: "6", label: "opt6", value: "any" },
      { id: "7", label: "opt7", value: "any" },
    ] 

    <main>
      <h1>{"Rescript Country Selector"->React.string}</h1> 
      <Select placeholder="Select a country" onChange options />
    </main>
  }
}

Document.unsafeGetElementById("app")
  ->ReactDOM.createRoot
  ->ReactDOM.Container.render(<Content />)
