open Fetch 

type country = {
  label: string,
  value: string,
  rank: float,
}

type countries = array<country>

module Route = {
  let countriesSearch = startsWith => `${Env.apiUrl}/countries/search/${startsWith}`
  let countriesList = count => `${Env.apiUrl}/countries/${count->Int.toString}`
  let country = countryCode => `${Env.apiUrl}/country/${countryCode}`
}

let countriesSearch = startsWith =>
  fetch(Route.countriesSearch(startsWith), Request.make(~method=#GET))->thenResolve(res =>
    res->Response.getBody
  )

let countriesList = count =>
  fetch(Route.countriesList(count), Request.make(~method=#GET))->thenResolve(res =>
    res->Response.getBody
  )

let country = countryCode =>
  fetch(Route.country(countryCode), Request.make(~method=#GET))->thenResolve(res =>
    res->Response.getBody
  )
