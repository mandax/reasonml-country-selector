type url = string
type method = [#GET | #POST | #PATCH | #DELETE | #HEAD]

module Request = {
  type t
  @obj external make: (~method: method) => t = ""
}

module Response = {
  type t
  @send external getBody: t => promise<'any> = "json"
}

@val external fetch: (url, Request.t) => promise<Response.t> = "fetch"

@send external then: (promise<'a>, 'a => unit) => unit = "then"
@send external thenResolve: (promise<'a>, 'a => promise<'b>) => promise<'b> = "then"
