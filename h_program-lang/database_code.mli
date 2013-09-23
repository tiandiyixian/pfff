
type entity_kind = 
  | Function
  | Class of class_type
  | Module | Package
  | Type 
  | Constant | Global
  | Macro
  | Exception
  | TopStmts

  | Field
  | Constructor
  | Method of method_type 
  | ClassConstant

  | Prototype | GlobalExtern

  | Other of string

  | File | Dir | MultiDirs
  and class_type = RegularClass (* or Struct *) | Interface | Trait
  and method_type = RegularMethod | StaticMethod

val string_of_entity_kind: entity_kind -> string
val entity_kind_of_string: string -> entity_kind

type property = 
   (* mostly for Function kind *)
   | ContainDynamicCall
   | ContainReflectionCall

   | TakeArgNByRef of int (* the argument position taken by ref *)

   | UseGlobal of string

   | DeadCode (* the function itself is dead, e.g. never called *)
   | ContainDeadStatements

   | CodeCoverage of int list (* e.g. covered lines by unit tests *)

   | Privacy of privacy
       
   | Required
  and privacy = Public | Protected | Private

type entity_id = int

type entity = {
  e_kind: entity_kind;
  (* needs to be a shortname, e.g. "map", not "List.map", otherwise the
   * highlighter (which uses only a lexer/parser) will not enlarge the
   * corresponding token in the file.
   *)
  e_name: string;
  e_fullname: string; (* can be empty *)
  e_file: Common.filename;
  e_pos: Common2.filepos;
  mutable e_number_external_users: int;
  mutable e_good_examples_of_use: entity_id list;
  e_properties: property list;
}

(* for debugging *)
val json_of_entity: entity -> Json_type.t


(* The dirs and filenames in this database are in readable format
 * so one can use the database generated by another user on
 * its own repository (this also saves some space in the generated
 * JSON file). Only root is in absolute path format.
 *)
type database = {
  root: Common.dirname;

  dirs: (Common.filename * int) list;
  files: (Common.filename * int) list;

  entities: entity array;
}

(* builders *)

val empty_database: unit -> database
val default_db_name: string
(* save either in a (readable) json format or (fast) marshalled form 
 * depending on the extension of the filename 
*)
val load_database: Common.filename -> database
val save_database: database -> Common.filename -> unit
(* when we want to analyze multi-languages projets *)
val merge_databases: database -> database -> database

(* helpers *)

val alldirs_and_parent_dirs_of_relative_dirs: 
  Common.dirname list -> Common.dirname list

(* for displaying a summary of the important functions in a file *)
val build_top_k_sorted_entities_per_file:
  k:int -> entity array -> (Common.filename, entity list) Hashtbl.t

val files_and_dirs_database_from_root:
  Common.dirname -> database

val files_and_dirs_and_sorted_entities_for_completion:
  threshold_too_many_entities:int -> database -> entity list


val adjust_method_or_field_external_users:
  verbose:bool -> entity array -> unit

val entity_kind_of_highlight_category_def: 
  Highlight_code.category -> entity_kind
val entity_kind_of_highlight_category_use: 
  Highlight_code.category -> entity_kind

(* use vs def *)
val entity_and_highlight_category_correpondance:
  entity -> Highlight_code.category -> bool


