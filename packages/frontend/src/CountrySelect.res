module Api = {
  type country = {
    label: string,
    value: string,
    rank: float,
  }
  type countries = array<country>
}

module Async = {
  type t<'a> = Loading | Ok('a) | Empty

  let someWithDefault = (a: t<'a>, def: 'a) =>
    switch a {
    | Ok(val) => val
    | _ => def
    }

  let toOption = (opt: t<'a>): option<'a> =>
    switch opt {
    | Ok(val) => Some(val)
    | _ => None
    }
}

module State = {
  type countryCode = string
  type action =
    | FetchCountries
    | FetchCountry(countryCode)
    | SetSelectedCountry(Async.t<Api.country>)
    | SetCountries(Async.t<Api.countries>)
  type effect = FetchingCountries | FetchingCountry(string)
  type state = {
    selectedCountry: Async.t<Select.Option.t<Api.country>>,
    countries: Async.t<array<Select.Option.t<Api.country>>>,
  }

  let initState = {countries: Empty, selectedCountry: Empty}

  let reducerEffect = (_state, effect, dispatch) => {
    open Fetch
    switch effect {
    | FetchingCountries => {
        dispatch(SetCountries(Async.Loading))
        fetch("http://localhost:4000/countries/10", Request.make(~method=#GET))
        ->thenResolve(res => res->Response.getBody)
        ->then((body: Api.countries) => dispatch(SetCountries(Async.Ok(body))))
      }
    | FetchingCountry(countryCode) => {
        dispatch(SetSelectedCountry(Async.Loading))
        fetch(`http://localhost:4000/country/${countryCode}`, Request.make(~method=#GET))
        ->thenResolve(res => res->Response.getBody)
        ->then((body: Api.country) => dispatch(SetSelectedCountry(Async.Ok(body))))
      }
    }
  }

  let reducer = (pushEffects, state, action) =>
    switch action {
    | FetchCountries => state->pushEffects(list{FetchingCountries})
    | FetchCountry(countryCode) => state->pushEffects(list{FetchingCountry(countryCode)})
    | SetSelectedCountry(Async.Ok(country)) => {
        ...state,
        selectedCountry: Async.Ok({label: country.label, value: country}),
      }
    | SetCountries(Async.Ok(countries)) => {
        ...state,
        countries: Async.Ok(
          countries->Array.map((c: Api.country): Select.Option.t<Api.country> => {
            label: c.label,
            value: c,
          }),
        ),
      }
    | SetSelectedCountry(Empty) => {...state, selectedCountry: Empty}
    | SetCountries(Empty) => {...state, countries: Empty}
    | SetSelectedCountry(Loading) => {...state, selectedCountry: Loading}
    | SetCountries(Loading) => {...state, countries: Loading}
    }
}

module Country = {
  let make = (
    {selected, option: {label, value: country}}: Select.Option.templateProps<Api.country>,
  ) =>
    <span className="country">
      <span className={`fi fi-${country.value}`} />
      <span> {label->React.string} </span>
      {selected ? React.null : <span> {`${country.rank->Float.toString}K`->React.string} </span>}
    </span>
}

module AsyncSelect = {
  type asyncOptions<'a> = Async.t<array<Select.Option.t<'a>>>

  module Loading = {
    @react.component
    let make = (~asyncOptions: asyncOptions<'a>) =>
      switch asyncOptions {
      | Loading => React.string("Loading")
      | Empty
      | Ok(_) => React.null
      }
  }

  @react.component
  let make = (
    ~optionTemplate=?,
    ~onChange,
    ~placeholder=?,
    ~selected: Async.t<Select.Option.t<'a>>,
    ~options: asyncOptions<'a>,
  ) => {
    <Select
      ?placeholder
      ?optionTemplate
      selected={selected->Async.toOption}
      onChange
      prependChildren={<Loading asyncOptions={options} />}
      options={options->Async.someWithDefault([])}
    />
  }
}

@react.component
let make = (~onChange, ~country: option<State.countryCode>) => {
  let (state, dispatch) = React.SideEffect.useReducer(
    State.reducer,
    State.reducerEffect,
    State.initState,
  )

  React.useEffect(() => {
    switch country {
    | Some(countryCode) => dispatch(FetchCountry(countryCode))
    | _ => ()
    }
  }, [])

  <AsyncSelect
    selected={state.selectedCountry}
    placeholder="Select a country"
    optionTemplate={Country.make}
    onChange
    options={state.countries}
  />
}
