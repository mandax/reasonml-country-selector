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
    switch effect {
    | SearchingCountries(startsWith) => {
        dispatch(SetCountries(Async.Loading))
        Api.countriesSearch(startsWith)->Fetch.then((res: Api.countries) =>
          dispatch(SetCountries(Async.Ok(res)))
        )
      }
    | FetchingCountries(count) => {
        dispatch(SetCountries(Async.Loading))
        Api.countriesList(count)->Fetch.then((res: Api.countries) =>
          dispatch(SetCountries(Async.Ok(res)))
        )
      }
    | FetchingCountry(countryCode) => {
        dispatch(SetSelectedCountry(Async.Loading))
        Api.country(countryCode)->Fetch.then((res: Api.country) =>
          dispatch(SetSelectedCountry(Async.Ok(res)))
        )
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
        // TODO(@mandax): Keep countries in state and filter in the ui, lazy loading new countries
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

  let onChangeHandler = (option: option<Select.Option.t<Api.country>>) => {
    switch option {
    | Some(opt) => {
        dispatch(SetSelectedCountry(Ok(opt.value)))
        onChange(opt.value)
      }
    | None => dispatch(SetSelectedCountry(Empty))
    }
  }

  <AsyncSelect
    selected={state.selectedCountry->Async.toOption}
    placeholder="Select a country"
    optionTemplate={Country.make}
    onChange={onChangeHandler}
    onTypeSearch
    options={state.countries}
  />
}
