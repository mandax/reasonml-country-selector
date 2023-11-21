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
