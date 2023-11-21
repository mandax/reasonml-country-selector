open Opium
open Yojson.Basic.Util

module Countries = struct
  type country = { label : string; value : string; rank : float }
  type t = country list

  let random_rank min max =
    Float.round ((min +. Random.float (max -. min)) *. 10.) /. 10.

  let yojson_of_country c =
    `Assoc
      [
        ("label", `String c.label);
        ("value", `String c.value);
        ("rank", `Float c.rank);
      ]

  let yojson_of_t t = `List (List.map yojson_of_country t)

  let country_of_yojson json =
    try
      let label = json |> member "label" |> to_string in
      let value = json |> member "value" |> to_string in
      let rank = random_rank 1.0 300.0 in
      { label; value; rank }
    with _ -> failwith "invalid country json"

  let t_of_yojson yojson =
    try yojson |> to_list |> List.map country_of_yojson
    with _ -> failwith "invalid countries json"

  let pwd = Sys.getcwd ()
  let filepath = Filename.concat pwd "countries.json"
  let countries : t = t_of_yojson (Yojson.Basic.from_file filepath)

  let contains : string -> country -> bool =
   fun str c ->
    StringLabels.starts_with
      ~prefix:(String.lowercase_ascii str)
      (String.lowercase_ascii c.label)
end

let format_error str exn =
  Lwt.return
    (Response.of_json
       (`Assoc
         [
           ( "error",
             `Assoc
               [
                 ("message", `String (Printexc.to_string exn));
                 ("search", `String str);
               ] );
         ]))

let highest_rank : Countries.country -> Countries.country -> int =
 fun a b -> compare (int_of_float b.rank) (int_of_float a.rank)

let country_by_code_handler req =
  try
    let country_code = Router.param req "countryCode" in
    Lwt.return
      (Response.of_json
         (Countries.yojson_of_country
            (Countries.countries
            |> List.find (fun (c : Countries.country) -> c.value = country_code)
            )))
  with exn -> format_error "" exn

let highest_rank_countries_handler req =
  try
    let limit = Router.param req "limit" |> int_of_string in
    Lwt.return
      (Response.of_json
         (Countries.yojson_of_t
            (Countries.countries |> List.sort highest_rank |> List.to_seq
           |> Seq.take limit |> List.of_seq)))
  with exn -> format_error "" exn

let search_countries_handler req =
  try
    let search_for = Router.param req "t" in
    Lwt.return
      (Response.of_json
         (Countries.yojson_of_t
            (List.filter (Countries.contains search_for) Countries.countries)))
  with exn -> format_error (Router.param req "t") exn

let _ =
  App.empty
  |> App.middleware
       (Middleware.allow_cors ~origins:[ "http://localhost:3000"; "http://ahrefs.afp.sh" ] ())
  |> App.get "/country/:countryCode" country_by_code_handler
  |> App.get "/countries/:limit" highest_rank_countries_handler
  |> App.get "/countries/search/:t" search_countries_handler
  |> App.run_command
