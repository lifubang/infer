(*
 * Copyright (c) 2013 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

open! IStd

module F = Format
module L = Logging

(** Annotations. *)

let any_thread = "AnyThread"
let assume_thread_safe = "AssumeThreadSafe"
let bind = "Bind"
let bind_view = "BindView"
let bind_array = "BindArray"
let bind_bitmap = "BindBitmap"
let bind_drawable = "BindDrawable"
let bind_string = "BindString"
let camel_nonnull = "NonNull"
let expensive = "Expensive"
let false_on_null = "FalseOnNull"
let for_ui_thread = "ForUiThread"
let for_non_ui_thread = "ForNonUiThread"
let guarded_by = "GuardedBy"
let ignore_allocations = "IgnoreAllocations"
let initializer_ = "Initializer"
let inject = "Inject"
let inject_view = "InjectView"
let integrity_source = "IntegritySource"
let integrity_sink = "IntegritySink"
let mutable_ = "Mutable"
let nonnull = "Nonnull"
let no_allocation = "NoAllocation"
let nullable = "Nullable"
let on_bind = "OnBind"
let on_event = "OnEvent"
let on_mount = "OnMount"
let on_unbind = "OnUnbind"
let on_unmount = "OnUnmount"
let notnull = "NotNull"
let not_thread_safe = "NotThreadSafe"
let performance_critical = "PerformanceCritical"
let present = "Present"
let privacy_source = "PrivacySource"
let privacy_sink = "PrivacySink"
let strict = "com.facebook.infer.annotation.Strict"
let suppress_lint = "SuppressLint"
let suppress_view_nullability = "SuppressViewNullability"
let thread_confined = "ThreadConfined"
let thread_safe = "ThreadSafe"
let thread_safe_method = "ThreadSafeMethod"
let true_on_null = "TrueOnNull"
let ui_thread = "UiThread"
let verify_annotation = "com.facebook.infer.annotation.Verify"
let visibleForTesting = "VisibleForTesting"
let volatile = "volatile"

(** Method signature with annotations. *)
type annotated_signature = {
  ret : Annot.Item.t * Typ.t; (** Annotated return type. *)
  params: (Mangled.t * Annot.Item.t * Typ.t) list (** Annotated parameters. *)
} [@@deriving compare]

let ia_has_annotation_with (ia: Annot.Item.t) (predicate: Annot.t -> bool): bool =
  IList.exists (fun (a, _) -> predicate a) ia

let ma_has_annotation_with ((ia, ial) : Annot.Method.t) (predicate: Annot.t -> bool): bool =
  let has_annot a = ia_has_annotation_with a predicate in
  has_annot ia || IList.exists has_annot ial

(** [annot_ends_with annot ann_name] returns true if the class name of [annot], without the package,
    is equal to [ann_name] *)
let annot_ends_with annot ann_name =
  match String.rsplit2 annot.Annot.class_name ~on:'.' with
  | None -> String.equal annot.Annot.class_name ann_name
  | Some (_, annot_class_name) -> String.equal annot_class_name ann_name

let class_name_matches s ((annot : Annot.t), _) =
  String.equal s annot.class_name

let ia_ends_with ia ann_name =
  IList.exists (fun (a, _) -> annot_ends_with a ann_name) ia

let ia_contains ia ann_name =
  IList.exists (class_name_matches ann_name) ia

let ia_get ia ann_name =
  try Some (fst (IList.find (class_name_matches ann_name) ia))
  with Not_found -> None

let pdesc_has_parameter_annot pdesc predicate =
  let _, param_annotations = (Procdesc.get_attributes pdesc).ProcAttributes.method_annotation in
  IList.exists predicate param_annotations

let pdesc_has_return_annot pdesc predicate =
  let return_annotation, _ = (Procdesc.get_attributes pdesc).ProcAttributes.method_annotation in
  predicate return_annotation

let pdesc_return_annot_ends_with pdesc annot =
  pdesc_has_return_annot pdesc (fun ia -> ia_ends_with ia annot)

let field_has_annot fieldname (struct_typ : StructTyp.t) predicate =
  let fld_has_taint_annot (fname, _, annot) =
    Ident.equal_fieldname fieldname fname && predicate annot in
  IList.exists fld_has_taint_annot struct_typ.fields ||
  IList.exists fld_has_taint_annot struct_typ.statics

let ia_is_not_thread_safe ia =
  ia_ends_with ia not_thread_safe

let ia_is_thread_safe ia =
  ia_ends_with ia thread_safe

let ia_is_thread_safe_method ia =
  ia_ends_with ia thread_safe_method

let ia_is_assume_thread_safe ia =
  ia_ends_with ia assume_thread_safe

let ia_is_nullable ia =
  ia_ends_with ia nullable

let ia_is_present ia =
  ia_ends_with ia present

let ia_is_nonnull ia =
  IList.exists
    (ia_ends_with ia)
    [nonnull; notnull; camel_nonnull]

let ia_is_false_on_null ia =
  ia_ends_with ia false_on_null

let ia_is_true_on_null ia =
  ia_ends_with ia true_on_null

let ia_is_initializer ia =
  ia_ends_with ia initializer_

let ia_is_volatile ia =
  ia_contains ia volatile

let field_injector_readwrite_list =
  [
    inject_view;
    bind;
    bind_view;
    bind_array;
    bind_bitmap;
    bind_drawable;
    bind_string;
    suppress_view_nullability;
  ]

let field_injector_readonly_list =
  inject
  ::
  field_injector_readwrite_list

(** Annotations for readonly injectors.
    The injector framework initializes the field but does not write null into it. *)
let ia_is_field_injector_readonly ia =
  IList.exists
    (ia_ends_with ia)
    field_injector_readonly_list

(** Annotations for read-write injectors.
    The injector framework initializes the field and can write null into it. *)
let ia_is_field_injector_readwrite ia =
  IList.exists
    (ia_ends_with ia)
    field_injector_readwrite_list

let ia_is_mutable ia =
  ia_ends_with ia mutable_

let ia_get_strict ia =
  ia_get ia strict

let ia_is_verify ia =
  ia_contains ia verify_annotation

let ia_is_expensive ia =
  ia_ends_with ia expensive

let ia_is_performance_critical ia =
  ia_ends_with ia performance_critical

let ia_is_no_allocation ia =
  ia_ends_with ia no_allocation

let ia_is_ignore_allocations ia =
  ia_ends_with ia ignore_allocations

let ia_is_suppress_lint ia =
  ia_ends_with ia suppress_lint

let ia_is_on_event ia =
  ia_ends_with ia on_event

let ia_is_on_bind ia =
  ia_ends_with ia on_bind

let ia_is_on_mount ia =
  ia_ends_with ia on_mount

let ia_is_on_unbind ia =
  ia_ends_with ia on_unbind

let ia_is_on_unmount ia =
  ia_ends_with ia on_unmount

let ia_is_privacy_source ia =
  ia_ends_with ia privacy_source

let ia_is_privacy_sink ia =
  ia_ends_with ia privacy_sink

let ia_is_integrity_source ia =
  ia_ends_with ia integrity_source

let ia_is_integrity_sink ia =
  ia_ends_with ia integrity_sink

let ia_is_guarded_by ia =
  ia_ends_with ia guarded_by

let ia_is_ui_thread ia =
  ia_ends_with ia ui_thread

let ia_is_thread_confined ia =
  ia_ends_with ia thread_confined

type annotation =
  | Nullable
  | Present
[@@deriving compare]

let ia_is ann ia = match ann with
  | Nullable -> ia_is_nullable ia
  | Present -> ia_is_present ia

(** Get a method signature with annotations from a proc_attributes. *)
let get_annotated_signature proc_attributes : annotated_signature =
  let method_annotation = proc_attributes.ProcAttributes.method_annotation in
  let formals = proc_attributes.ProcAttributes.formals in
  let ret_type = proc_attributes.ProcAttributes.ret_type in
  let (ia, ial0) = method_annotation in
  let natl =
    let rec extract ial parl = match ial, parl with
      | ia :: ial', (name, typ) :: parl' ->
          (name, ia, typ) :: extract ial' parl'
      | [], (name, typ) :: parl' ->
          (name, Annot.Item.empty, typ) :: extract [] parl'
      | [], [] ->
          []
      | _ :: _, [] ->
          assert false in
    IList.rev (extract (IList.rev ial0) (IList.rev formals)) in
  let annotated_signature = { ret = (ia, ret_type); params = natl } in
  annotated_signature


(** Check if the annotated signature is for a wrapper of an anonymous inner class method.
    These wrappers have the same name as the original method, every type is Object, and the parameters
    are called x0, x1, x2. *)
let annotated_signature_is_anonymous_inner_class_wrapper ann_sig proc_name =
  let check_ret (ia, t) =
    Annot.Item.is_empty ia && PatternMatch.type_is_object t in
  let x_param_found = ref false in
  let name_is_x_number name =
    let name_str = Mangled.to_string name in
    let len = String.length name_str in
    len >= 2 &&
    String.equal (String.sub name_str ~pos:0 ~len:1) "x" &&
    let s = String.sub name_str ~pos:1 ~len:(len - 1) in
    let is_int =
      try
        ignore (int_of_string s);
        x_param_found := true;
        true
      with Failure _ -> false in
    is_int in
  let check_param (name, ia, t) =
    if String.equal (Mangled.to_string name) "this" then true
    else
      name_is_x_number name &&
      Annot.Item.is_empty ia &&
      PatternMatch.type_is_object t in
  Procname.java_is_anonymous_inner_class proc_name
  && check_ret ann_sig.ret
  && IList.for_all check_param ann_sig.params
  && !x_param_found

(** Check if the given parameter has a Nullable annotation in the given signature *)
let param_is_nullable pvar ann_sig =
  IList.exists
    (fun (param, annot, _) ->
       Mangled.equal param (Pvar.get_name pvar) && ia_is_nullable annot)
    ann_sig.params

(** Pretty print a method signature with annotations. *)
let pp_annotated_signature proc_name fmt annotated_signature =
  let pp_ia fmt ia = if ia <> [] then F.fprintf fmt "%a " Annot.Item.pp ia in
  let pp_annotated_param fmt (p, ia, t) =
    F.fprintf fmt " %a%a %a" pp_ia ia (Typ.pp_full Pp.text) t Mangled.pp p in
  let ia, ret_type = annotated_signature.ret in
  F.fprintf fmt "%a%a %s (%a )"
    pp_ia ia
    (Typ.pp_full Pp.text) ret_type
    (Procname.to_simplified_string proc_name)
    (Pp.comma_seq pp_annotated_param) annotated_signature.params

let mk_ann_str s = { Annot.class_name = s; parameters = [] }
let mk_ann = function
  | Nullable -> mk_ann_str nullable
  | Present -> mk_ann_str present
let mk_ia ann ia =
  if ia_is ann ia then ia
  else (mk_ann ann, true) :: ia
let mark_ia ann ia x =
  if x then mk_ia ann ia else ia

let mk_ia_strict ia =
  if ia_get_strict ia <> None then ia
  else (mk_ann_str strict, true) :: ia
let mark_ia_strict ia x =
  if x then mk_ia_strict ia else ia

(** Mark the annotated signature with the given annotation map. *)
let annotated_signature_mark proc_name ann asig (b, bs) =
  let ia, t = asig.ret in
  let ret' = mark_ia ann ia b, t in
  let mark_param (s, ia, t) x =
    let ia' = if x then mk_ia ann ia else ia in
    (s, ia', t) in
  let params' =
    let fail () =
      L.stdout
        "INTERNAL ERROR: annotation for procedure %s has wrong number of arguments@."
        (Procname.to_unique_id proc_name);
      L.stdout "  ANNOTATED SIGNATURE: %a@." (pp_annotated_signature proc_name) asig;
      assert false in
    let rec combine l1 l2 = match l1, l2 with
      | (p, ia, t):: l1', l2' when String.equal (Mangled.to_string p) "this" ->
          (p, ia, t) :: combine l1' l2'
      | (s, ia, t):: l1', x:: l2' ->
          mark_param (s, ia, t) x :: combine l1' l2'
      | [], _:: _ -> fail ()
      | _:: _, [] -> fail ()
      | [], [] -> [] in
    combine asig.params bs in
  { ret = ret'; params = params'}

(** Mark the return of the annotated signature with the given annotation. *)
let annotated_signature_mark_return ann asig =
  let ia, t = asig.ret in
  let ret' = mark_ia ann ia true, t in
  { asig with ret = ret'}

(** Mark the return of the annotated signature @Strict. *)
let annotated_signature_mark_return_strict asig =
  let ia, t = asig.ret in
  let ret' = mark_ia_strict ia true, t in
  { asig with ret = ret'}

(** Mark the return of the method_annotation with the given annotation. *)
let method_annotation_mark_return ann method_annotation =
  let ia_ret, params = method_annotation in
  let ia_ret' = mark_ia ann ia_ret true in
  ia_ret', params
