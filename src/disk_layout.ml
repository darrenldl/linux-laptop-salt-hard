type lvm_info = {
  (* vg_pv_map : string list String_map.t; *)
  vg_name : string;
  pv_name : string;
}

type t = {
  root : Storage_unit.t;
  var : Storage_unit.t option;
  home : Storage_unit.t option;
  (* swap : Storage_unit.t option; *)
  boot : Storage_unit.t;
  esp : Storage_unit.t option;
  lvm_info : lvm_info option;
  pool : Storage_unit.pool;
}

type layout_choice =
  | Single_disk
  | Sys_part_plus_boot_plus_maybe_EFI
  | Sys_part_plus_usb_drive

type sys_part_enc_choice =
  [ `None
  | `Passphrase
  | `Keyfile
  ]

(* | Lvm_single_disk
 * | Lvm_boot_plus_maybe_EFI_plus_pv_s
 * | Lvm_usb_drive_plus_pv_s *)

(* let make_lower ~disk ~part_num = {disk; part_num} *)

(* let lower_part_to_cmd_string {disk; part_num} =
 *   sprintf "/dev/%s%d" disk part_num *)

(* let luks_to_mapper_name_cmd_string { mapper_name; _ } =
 *   Printf.sprintf "/dev/mapper/%s" mapper_name *)

(* let luks_open { lower; upper; _ } =
 *   match upper with
 *   | Plain_FS _ -> failwith "LUKS expected"
 *   | Luks luks ->
 *     assert (luks.state = Luks_closed);
 *     let stdin, f =
 *       Printf.sprintf "cryptsetup open --key-file=- %s %s" lower.path
 *         luks.mapper_name
 *       |> exec_with_stdin
 *     in
 *     output_string stdin luks.primary_key;
 *     f ();
 *     luks.state <- Luks_opened *)

(* let luks_close { upper; _ } =
 *   match upper with
 *   | Plain_FS _ -> failwith "LUKS expected"
 *   | Luks luks ->
 *     assert (luks.state = Luks_opened);
 *     Printf.sprintf "cryptsetup close %s" luks.mapper_name |> exec;
 *     luks.state <- Luks_closed *)

(* let mount_part ({ lower; upper; state } as p) ~mount_point =
 *   assert (state = Unmounted);
 *   ( match upper with
 *     | Plain_FS _ -> Printf.sprintf "mount %s %s" lower.path mount_point |> exec
 *     | Luks luks ->
 *       luks_open { lower; upper; state };
 *       Printf.sprintf "mount %s %s"
 *         (luks_to_mapper_name_cmd_string luks)
 *         mount_point
 *       |> exec );
 *   p.state <- Mounted *)

(* let unmount_part ({ lower; upper; state } as p) =
 *   assert (state = Mounted);
 *   ( match upper with
 *     | Plain_FS _ -> Printf.sprintf "umount %s" lower.path |> exec
 *     | Luks luks ->
 *       let mapper_name = luks_to_mapper_name_cmd_string luks in
 *       Printf.sprintf "umount %s" mapper_name |> exec;
 *       p.state <- Unmounted;
 *       luks_close { lower; upper; state } );
 *   p.state <- Unmounted *)

(* let format_cmd fs part =
 *   match fs with
 *   | Fat32 -> Printf.sprintf "mkfs.fat -F32 %s" part
 *   | Ext4 -> Printf.sprintf "mkfs.ext4 %s" part *)

(* let format_part ({ upper; lower; state } as p) =
 *   assert (state = Unformatted);
 *   ( match upper with
 *     | Plain_FS fs -> format_cmd fs lower.path |> exec
 *     | Luks luks ->
 *       let iter_time_ms_opt =
 *         Option.map
 *           (fun x -> [ "--iter-time"; string_of_int x ])
 *           luks.enc_params.iter_time_ms
 *         |> Option.value ~default:[]
 *       in
 *       let key_size_bits_opt =
 *         Option.map
 *           (fun x -> [ "--key-size"; string_of_int x ])
 *           luks.enc_params.key_size_bits
 *         |> Option.value ~default:[]
 *       in
 *       (let stdin, f =
 *          String.concat " "
 *            ( [
 *              "cryptsetup";
 *              "luksFormat";
 *              "-y";
 *              "--key-file=-";
 *              "--type";
 *              Printf.sprintf "luks%d" (luks_version_to_int luks.version);
 *            ]
 *              @ iter_time_ms_opt @ key_size_bits_opt @ [ lower.path ] )
 *          |> exec_with_stdin
 *        in
 *        output_string stdin luks.primary_key;
 *        f ());
 *       ( match luks.secondary_key with
 *         | None -> ()
 *         | Some secondary_key ->
 *           let tmp_path = Filename.temp_file "installer" "secondary_key" in
 *           let tmp_oc = open_out tmp_path in
 *           Fun.protect
 *             ~finally:(fun () -> close_out tmp_oc)
 *             (fun () -> output_string tmp_oc secondary_key);
 *           let stdin, f =
 *             String.concat " "
 *               [
 *                 "cryptsetup";
 *                 "luksAddKey";
 *                 "-y";
 *                 "--key-file=-";
 *                 lower.path;
 *                 tmp_path;
 *               ]
 *             |> exec_with_stdin
 *           in
 *           output_string stdin luks.primary_key;
 *           f () );
 *       luks_open p;
 *       let mapper_name = luks_to_mapper_name_cmd_string luks in
 *       exec (format_cmd luks.inner_fs mapper_name);
 *       luks_close p );
 *   p.state <- Unmounted *)

(* let format layout =
 *   Option.iter format_part layout.esp_part;
 *   format_part layout.boot_part;
 *   format_part layout.sys_part *)

(* let make_luks ~enc_params ?(primary_key = Rand_utils.gen_rand_string ~len:4096)
 *     ?(add_secondary_key = false) ?(version = LuksV2) inner_fs ~mapper_name =
 *   {
 *     enc_params =
 *       Option.value
 *         ~default:{ iter_time_ms = None; key_size_bits = None }
 *         enc_params;
 *     primary_key;
 *     secondary_key =
 *       ( if add_secondary_key then Some (Rand_utils.gen_rand_string ~len:4096)
 *         else None );
 *     version;
 *     inner_fs;
 *     mapper_name;
 *     state = Luks_closed;
 *   } *)

(* let make_part ~path upper =
 *   let lower = { path } in
 *   { lower; upper; state = Unformatted } *)

module Params = struct
  module Esp = struct
    let l1_id = 0

    let l2_id = 0

    let l3_id = 0

    let l4_id = 0
  end

  module Boot = struct
    let l1_id = 1

    let l2_id = 1

    let l3_id = 1

    let l4_id = 1
  end

  module Sys = struct
    let l1_id = 2

    let l2_id = 2
  end

  module Root = struct
    include Sys

    let l3_id = 3

    let l4_id = 3
  end

  module Var = struct
    include Sys

    let l3_id = 4

    let l4_id = 4
  end

  module Home = struct
    include Sys

    let l3_id = 5

    let l4_id = 5
  end
end

let make_esp (pool : Storage_unit.pool) ~path =
  let open Params.Esp in
  Hashtbl.add pool.l1_pool l1_id (Storage_unit.L1.make_clear ~path);
  Hashtbl.add pool.l2_pool l2_id (Storage_unit.L2.make_none ());
  Hashtbl.add pool.l3_pool l3_id (Storage_unit.L3.make_none ());
  Hashtbl.add pool.l4_pool l4_id
    (Storage_unit.L4.make ~mount_point:Config.esp_mount_point `Fat32);
  Storage_unit.make ~l1_id ~l2_id ~l3_id ~l4_id

let make_boot (pool : Storage_unit.pool) ~enc_params ~encrypt ~path =
  let open Params.Boot in
  Hashtbl.add pool.l1_pool l1_id
    (if encrypt then
       let primary_key =
         Misc_utils.ask_string_confirm
           ~is_valid:(fun x -> x <> "")
           ~no_echo:true
           "Please enter passphrase for BOOT (/boot) partition encryption"
       in
       Storage_unit.L1.make_luks ~primary_key ~add_secondary_key:true
         ~version:`LuksV1 ~path ~mapper_name:Config.boot_mapper_name enc_params
     else Storage_unit.L1.make_clear ~path);
  Hashtbl.add pool.l2_pool l2_id (Storage_unit.L2.make_none ());
  Hashtbl.add pool.l3_pool l3_id (Storage_unit.L3.make_none ());
  Hashtbl.add pool.l4_pool l4_id
    (Storage_unit.L4.make ~mount_point:Config.boot_mount_point `Ext4);
  Storage_unit.make ~l1_id ~l2_id ~l3_id ~l4_id

let make_root_var_home (pool : Storage_unit.pool) ~enc_params
    ~(encrypt : sys_part_enc_choice) ~use_lvm path :
  Storage_unit.t * Storage_unit.t option * Storage_unit.t option =
  (* common components - L1, L2 stuff *)
  Hashtbl.add pool.l1_pool Params.Sys.l1_id
    (match encrypt with
     | `None -> Storage_unit.L1.make_clear ~path
     | `Passphrase ->
       let primary_key =
         Misc_utils.ask_string_confirm
           ~is_valid:(fun x -> x <> "")
           ~no_echo:true
           "Please enter passphrase for ROOT (/) partition encryption"
       in
       Storage_unit.L1.make_luks ~primary_key ~path
         ~mapper_name:Config.sys_mapper_name enc_params
     | `Keyfile ->
       Storage_unit.L1.make_luks ~path ~mapper_name:Config.sys_mapper_name
         enc_params);
  (* (if encrypt then
   *    Storage_unit.L1.make_luks ~path ~mapper_name:Config.sys_mapper_name
   *      enc_params
   *  else Storage_unit.L1.make_clear ~path); *)
  Hashtbl.add pool.l2_pool Params.Sys.l2_id
    (if use_lvm then Storage_unit.L2.make_lvm ~vg_name:Config.lvm_vg_name
     else Storage_unit.L2.make_none ());
  let part_size_MiB = Disk_utils.disk_size_MiB path in
  (* root specific *)
  let root, root_size_MiB =
    let open Params.Root in
    let size_MiB_float =
      min
        (Config.lvm_lv_root_frac *. part_size_MiB)
        Config.lvm_lv_root_max_size_MiB
    in
    let size_MiB = int_of_float size_MiB_float in
    Hashtbl.add pool.l3_pool l3_id
      (if use_lvm then
         Storage_unit.L3.make_lvm ~lv_name:Config.lvm_lv_root_name
           ~vg_name:Config.lvm_vg_name ~size_MiB:(Some size_MiB)
       else Storage_unit.L3.make_none ());
    Hashtbl.add pool.l4_pool l4_id
      (Storage_unit.L4.make ~mount_point:Config.root_mount_point `Ext4);
    (Storage_unit.make ~l1_id ~l2_id ~l3_id ~l4_id, size_MiB_float)
  in
  (* var specific *)
  let var, var_size_MiB =
    if use_lvm then (
      let open Params.Var in
      let size_MiB_float =
        min
          (Config.lvm_lv_var_frac *. part_size_MiB)
          Config.lvm_lv_var_max_size_MiB
      in
      let size_MiB = int_of_float size_MiB_float in
      Hashtbl.add pool.l3_pool l3_id
        (Storage_unit.L3.make_lvm ~lv_name:Config.lvm_lv_var_name
           ~vg_name:Config.lvm_vg_name ~size_MiB:(Some size_MiB));
      Hashtbl.add pool.l4_pool l4_id
        (Storage_unit.L4.make ~mount_point:Config.var_mount_point `Ext4);
      (Some (Storage_unit.make ~l1_id ~l2_id ~l3_id ~l4_id), Some size_MiB_float))
    else (None, None)
  in
  (* home specific *)
  let home =
    if use_lvm then (
      let used_space = root_size_MiB +. Option.value ~default:0. var_size_MiB in
      let free_space = part_size_MiB -. used_space in
      (* use 80% of remaining space for /home,
         20% is reserved for snapshot volumes *)
      let size_MiB =
        free_space *. Config.lvm_lv_home_frac_of_leftover
        |> int_of_float
        |> Option.some
      in
      let open Params.Home in
      Hashtbl.add pool.l3_pool l3_id
        (Storage_unit.L3.make_lvm ~lv_name:Config.lvm_lv_home_name
           ~vg_name:Config.lvm_vg_name ~size_MiB);
      Hashtbl.add pool.l4_pool l4_id
        (Storage_unit.L4.make ~mount_point:Config.home_mount_point `Ext4);
      Some (Storage_unit.make ~l1_id ~l2_id ~l3_id ~l4_id))
    else None
  in
  (root, var, home)

let make_layout ~esp_part_path ~boot_part_path ~boot_part_enc_params
    ~boot_encrypt ~sys_part_path ~sys_part_enc_params
    ~(sys_encrypt : sys_part_enc_choice) ~use_lvm =
  let pool = Storage_unit.make_pool () in
  let esp = Option.map (fun path -> make_esp pool ~path) esp_part_path in
  let boot =
    make_boot pool ~enc_params:boot_part_enc_params ~encrypt:boot_encrypt
      ~path:boot_part_path
  in
  let root, var, home =
    make_root_var_home pool ~enc_params:sys_part_enc_params ~encrypt:sys_encrypt
      ~use_lvm sys_part_path
  in
  let lvm_info =
    if use_lvm then
      if sys_encrypt <> `None then
        Some
          {
            vg_name = Config.lvm_vg_name;
            pv_name = Printf.sprintf "/dev/mapper/%s" Config.sys_mapper_name;
          }
      else Some { vg_name = Config.lvm_vg_name; pv_name = sys_part_path }
    else None
  in
  { root; var; home; esp; boot; lvm_info; pool }

let mount layout =
  Misc_utils.print_boxed_msg "Mounting root";
  Storage_unit.mount layout.pool layout.root;
  Option.iter
    (fun var ->
       Misc_utils.print_boxed_msg "Mounting var";
       Storage_unit.mount layout.pool var)
    layout.var;
  Option.iter
    (fun home ->
       Misc_utils.print_boxed_msg "Mounting home";
       Storage_unit.mount layout.pool home)
    layout.home;
  Storage_unit.mount layout.pool layout.boot;
  Option.iter
    (fun esp ->
       Misc_utils.print_boxed_msg "Mounting esp";
       Storage_unit.mount layout.pool esp)
    layout.esp

let unmount layout =
  Option.iter
    (fun esp ->
       Misc_utils.print_boxed_msg "Unmounting esp";
       Storage_unit.unmount layout.pool esp)
    layout.esp;
  Misc_utils.print_boxed_msg "Unmounting boot";
  Storage_unit.unmount layout.pool layout.boot;
  Option.iter
    (fun home ->
       Misc_utils.print_boxed_msg "Unmounting home";
       Storage_unit.unmount layout.pool home)
    layout.home;
  Option.iter
    (fun var ->
       Misc_utils.print_boxed_msg "Unmounting var";
       Storage_unit.unmount layout.pool var)
    layout.var;
  print_endline "Unmounting root";
  Storage_unit.unmount layout.pool layout.root

let set_up layout =
  (* ESP *)
  Option.iter
    (fun esp ->
       Misc_utils.print_boxed_msg "Setting up ESP";
       Storage_unit.set_up layout.pool esp)
    layout.esp;
  (* boot *)
  Misc_utils.print_boxed_msg "Setting up boot";
  Storage_unit.set_up layout.pool layout.boot;
  (* system *)
  Misc_utils.print_boxed_msg "Setting up system volume(s)";
  (* root *)
  Misc_utils.print_boxed_msg "Setting up root";
  Storage_unit.set_up layout.pool layout.root;
  (* var *)
  Option.iter
    (fun var ->
       Misc_utils.print_boxed_msg "Setting up var";
       Storage_unit.set_up layout.pool var)
    layout.var;
  (* home *)
  Option.iter
    (fun home ->
       Misc_utils.print_boxed_msg "Setting up home";
       Storage_unit.set_up layout.pool home)
    layout.home

let get_esp t = Option.map (Storage_unit.instantiate_from_pool t.pool) t.esp

let get_boot t = Storage_unit.instantiate_from_pool t.pool t.boot

let get_root t = Storage_unit.instantiate_from_pool t.pool t.root

let get_var t = Option.map (Storage_unit.instantiate_from_pool t.pool) t.var

let get_home t = Option.map (Storage_unit.instantiate_from_pool t.pool) t.home

let reset layout =
  Option.iter (Storage_unit.reset layout.pool) layout.esp;
  Storage_unit.reset layout.pool layout.boot;
  Storage_unit.reset layout.pool layout.root;
  Option.iter (Storage_unit.reset layout.pool) layout.var;
  Option.iter (Storage_unit.reset layout.pool) layout.home
