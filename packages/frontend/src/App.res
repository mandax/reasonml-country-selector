module Content = {
  @react.component
  let make = () => {
    <h1>{"Hello"->React.string}</h1> 
  }
}

Document.unsafeGetElementById("app")->ReactDOM.createRoot->ReactDOM.Container.render(<Content />)
