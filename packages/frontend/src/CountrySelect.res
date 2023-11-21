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

  let toString = (data: t<'a>) =>
    switch data {
    | Loading => "Loading"
    | Ok(_) => "Ok"
    | Empty => "Empty"
    }

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
  type countries = Async.t<array<Select.Option.t<Api.country>>>
  type selectedCountry = Async.t<Select.Option.t<Api.country>>

  type action =
    | FetchCountries(int)
    | FetchCountry(countryCode)
    | SearchCountries(string)
    | SetSelectedCountry(Async.t<Api.country>)
    | SetCountries(Async.t<Api.countries>)

  type effect = FetchingCountries(int) | FetchingCountry(string) | SearchingCountries(string)

  type t = {
    selectedCountry: selectedCountry,
    countries: countries,
  }

  let initState = {countries: Empty, selectedCountry: Empty}

  let reducerEffect = (_state, effect, dispatch) => {
    open Fetch
    switch effect {
    | SearchingCountries(startsWith) => {
        dispatch(SetCountries(Async.Loading))
        fetch(`http://localhost:4000/countries/search/${startsWith}`, Request.make(~method=#GET))
        ->thenResolve(res => res->Response.getBody)
        ->then((body: Api.countries) => dispatch(SetCountries(Async.Ok(body))))
      }
    | FetchingCountries(count) => {
        dispatch(SetCountries(Async.Loading))
        fetch(`http://localhost:4000/countries/${count->Int.toString}`, Request.make(~method=#GET))
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

  let reducer = (pushEffects, state, action): t =>
    switch action {
    | FetchCountries(count) => state->pushEffects(list{FetchingCountries(count)})
    | FetchCountry(countryCode) => state->pushEffects(list{FetchingCountry(countryCode)})
    | SearchCountries(startsWith) => state->pushEffects(list{SearchingCountries(startsWith)})
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
  let getCode = (country: State.selectedCountry) =>
    switch country {
    | Ok({value: {value: countryCode}}) => countryCode
    | _ => ""
    }

  let make = (
    {selected, option: {label, value: country}}: Select.Option.templateProps<Api.country>,
  ) =>
    <span className={`${selected ? "selected" : ""} countrySelect`}>
      <span className={`countrySelect__icon fi fi-${country.value}`} />
      <span className="countrySelect__label"> {label->React.string} </span>
      {selected
        ? React.null
        : <span className="countrySelect__badge">
            {`${country.rank->Float.toString}K`->React.string}
          </span>}
    </span>
}

module AsyncSelect = {
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
    ~selected: Async.t<Select.Option.t<'a>>,
    ~options: asyncOptions<'a>,
  ) => {
    <Select
      ?placeholder
      ?optionTemplate
      selected={selected->Async.toOption}
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
}

let useSelectedCountry = (state: State.t, dispatch, country) => {
  React.useEffect(() => {
    switch country {
    | Some(countryCode) =>
      if countryCode != state.selectedCountry->Country.getCode {
        dispatch(State.FetchCountry(countryCode))
      }
    | _ => ()
    }
  }, [country])
}

let useCountriesInitialLoad = (state: State.t, dispatch) => {
  React.useEffect(() => {
    switch state.countries {
    | Empty => dispatch(State.FetchCountries(10))
    | _ => ()
    }
  }, [state.countries])
}

@react.component
let make = (~onChange, ~country: option<State.countryCode>) => {
  let (state, dispatch) = React.SideEffect.useReducer(
    State.reducer,
    State.reducerEffect,
    State.initState,
  )

  useSelectedCountry(state, dispatch, country)
  useCountriesInitialLoad(state, dispatch)

  let onTypeSearch = event =>
    switch event->React.Form.getTargetValue {
    | "" => dispatch(SetCountries(Empty))
    | value => dispatch(SearchCountries(value))
    }

  let onChangeHandler = (option: Select.Option.t<Api.country>) => {
    dispatch(SetSelectedCountry(Ok(option.value)))
    onChange(option.value)
  }

  <AsyncSelect
    selected={state.selectedCountry}
    placeholder="Select a country"
    optionTemplate={Country.make}
    onChange={onChangeHandler}
    onTypeSearch
    options={state.countries}
  />
}
