type url = string
type method = [#GET | #POST | #PATCH | #DELETE | #HEAD]

module Headers = {
  type t = Js.Dict.t<string>
  type header = ContentType(string) | Accept(string) | Allow(string)

  let make = Js.Dict.empty()

  let add = (headers: t, header: header, value: string) =>
    switch header {
    | Accept(val) => 
    | Allow(val) => 
    | ContentType(val) =>
      headers->Js.Dict.set(header, value)
    | _ => failwith`${header} is not a valid header.`
    }
}

module Request = {
  type option = Method(method) | Headers(Headers.t)
  type t = Js.Dict.t<requestOption>

  let make = Js.Dict.empty()

  let add = (req: t, option: option) =>
    switch option {
    | Method(method) => headers->Js.Dict.set("method", method)
    | Headers(header) =>
      headers->Js.Dict.set("headers", req->Js.Dict.get("headers")->Headers.add(header))
    | _ => failwith`${header} is not a valid header.`
    }
}
