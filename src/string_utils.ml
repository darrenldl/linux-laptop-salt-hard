let tail_w_pos ~pos s =
  let s_len = String.length s in
  String.sub s pos (s_len - pos)

let tail_w_len ~len s =
  let s_len = String.length s in
  String.sub s (s_len - len) len

let strip_tail_num s =
  let pos = ref None in
  String.iteri
    (fun i c ->
       if Core_kernel.Char.is_digit c then
         pos := match !pos with None -> Some i | Some x -> Some x)
    s;
  match !pos with None -> s | Some pos -> String.sub s 0 pos

let get_tail_num s =
  let len = String.length s in
  let pos = ref None in
  String.iteri
    (fun i c ->
       if Core_kernel.Char.is_digit c then
         pos := match !pos with None -> Some i | Some x -> Some x)
    s;
  match !pos with
  | None -> None
  | Some pos -> Some (String.sub s pos (len - pos) |> int_of_string)

let strip_prefix ~prefix s =
  let prefix_len = String.length prefix in
  let s_len = String.length s in
  if s_len < prefix_len then s
  else
    let sub = String.sub s 0 prefix_len in
    if sub = prefix then String.sub s prefix_len s_len else s
