(*
 * Copyright (c) 2009 - 2013 Monoidics ltd.
 * Copyright (c) 2013 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

open! IStd

(** Configuration values: either constant, determined at compile time, or set at startup
    time by system calls, environment variables, or command line options *)


(** Various kind of analyzers *)
type analyzer = Capture | Compile | Infer | Eradicate | Checkers | Tracing
              | Crashcontext | Linters | Quandary | Threadsafety [@@deriving compare]

val equal_analyzer : analyzer -> analyzer -> bool

(** Association list of analyzers and their names *)
val string_to_analyzer : (string * analyzer) list

val string_of_analyzer : analyzer -> string

type language = Clang | Java [@@deriving compare]

val equal_language : language -> language -> bool

val string_of_language : language -> string


val ml_bucket_symbols :
  (string * [ `MLeak_all | `MLeak_arc | `MLeak_cf | `MLeak_cpp | `MLeak_no_arc | `MLeak_unknown ])
    list


type os_type = Unix | Win32 | Cygwin

type dynamic_dispatch_policy = [
  | `None
  | `Interface
  | `Sound
  | `Lazy
]

val env_inside_maven : Unix.env

(** Constant configuration values *)

val allow_missing_index_in_proc_call : bool
val anonymous_block_num_sep : string
val anonymous_block_prefix : string
val assign : string
val attributes_dir_name : string
val backend_stats_dir_name : string
val bin_dir : string
val bound_error_allowed_in_procedure_call : bool
val buck_generated_folder : string
val buck_infer_deps_file_name : string
val captured_dir_name : string
val checks_disabled_by_default : string list
val clang_initializer_prefix : string
val classpath : string option
val cpp_extra_include_dir : string
val relative_cpp_models_dir : string
val csl_analysis : bool
val current_exe : CommandLineOption.exe
val default_failure_name : string
val default_in_zip_results_dir : string
val dotty_output : string
val etc_dir : string
val fail_on_issue_exit_code : int
val frontend_stats_dir_name : string
val global_tenv_filename : string
val idempotent_getters : bool
val incremental_procs : bool
val infer_py_argparse_error_exit_code : int
val inferconfig_file : string
val initial_analysis_time : float
val ivar_attributes : string
val lib_dir : string
val lint_dotty_dir_name : string
val lint_issues_dir_name : string
val load_average : float option
val log_analysis_crash : string
val log_analysis_file : string
val log_analysis_procedure : string
val log_analysis_recursion_timeout : string
val log_analysis_symops_timeout : string
val log_analysis_wallclock_timeout : string
val log_dir_name : string
val max_recursion : int
val meet_level : int
val models_dir : string
val models_jar : string
val models_src_dir : string
val multicore_dir_name : string
val ncpu : int
val nsnotification_center_checker_backend : bool
val os_type : os_type
val patterns_modeled_expensive : string * Yojson.Basic.json
val patterns_never_returning_null : string * Yojson.Basic.json
val patterns_skip_translation : string * Yojson.Basic.json
val perf_stats_prefix : string
val proc_stats_filename : string
val property_attributes : string
val report_condition_always_true_in_clang : bool
val report_custom_error : bool
val report_nullable_inconsistency : bool
val reporting_stats_dir_name : string
val save_compact_summaries : bool
val save_time_in_summaries : bool
val smt_output : bool
val source_file_extentions : string list
val sources : string list
val sourcepath : string option
val specs_dir_name : string
val specs_files_suffix : string
val start_filename : string
val taint_analysis : bool
val trace_absarray : bool
val undo_join : bool
val unsafe_unret : string
val use_jar_cache : bool
val version_string : string
val weak : string
val whitelisted_cpp_methods : string list list
val whitelisted_cpp_classes : string list list
val wrappers_dir : string


(** Configuration values specified by command-line options *)

val anon_args : string list
val rest : string list
val abs_struct : int
val allow_specs_cleanup : bool
val analysis_path_regex_whitelist : analyzer -> string list
val analysis_path_regex_blacklist : analyzer -> string list
val analysis_blacklist_files_containing : analyzer -> string list
val analysis_stops : bool
val analysis_suppress_errors : analyzer -> string list
val analyzer : analyzer
val angelic_execution : bool
val array_level : int
val ast_file : string option
val blacklist : string option
val bootclasspath : string option
val buck : bool
val buck_build_args : string list
val buck_out : string option
val bugs_csv : string option
val bugs_json : string option
val bugs_tests : string option
val bugs_txt : string option
val bugs_xml : string option
val changed_files_index : string option
val calls_csv : string option
val check_duplicate_symbols : bool
val checkers : bool
val checkers_enabled : bool
val checkers_repeated_calls : bool
val clang_biniou_file : string option
val clang_frontend_action_string : string
val clang_frontend_do_capture : bool
val clang_frontend_do_lint : bool
val clang_include_to_override : string option
val cluster_cmdline : string option
val compute_analytics : bool
val continue_capture : bool
val copy_propagation : bool
val crashcontext : bool
val create_harness : bool
val cxx : bool
val debug_mode : bool
val debug_exceptions : bool
val dependency_mode : bool
val developer_mode : bool
val disable_checks : string list
val dotty_cfg_libs : bool
val dynamic_dispatch : [ `None | `Interface | `Sound | `Lazy ]
val enable_checks : string list
val eradicate : bool
val eradicate_condition_redundant : bool
val eradicate_field_not_mutable : bool
val eradicate_field_over_annotated : bool
val eradicate_optional_present : bool
val eradicate_propagate_return_nullable : bool
val eradicate_return_over_annotated : bool
val eradicate_debug : bool
val eradicate_verbose : bool
val err_file_cmdline : string
val fail_on_bug : bool
val failures_allowed : bool
val fcp_apple_clang : string option
val fcp_syntax_only : bool
val filter_paths : bool
val filtering : bool
val flavors : bool
val from_json_report : string option
val frontend_debug : bool
val frontend_tests : bool
val frontend_stats : bool
val generated_classes : string option
val headers : bool
val icfg_dotty_outfile : string option
val infer_cache : string option
val iphoneos_target_sdk_version : string option
val iterations : int
val java_jar_compiler : string option
val javac_classes_out : string
val javac_verbose_out : string
val jobs : int
val join_cond : int
val latex : string option
val linters_def_file : string list
val load_analysis_results : string option
val makefile_cmdline : string
val maven : bool
val merge : bool
val ml_buckets :
  [ `MLeak_all | `MLeak_arc | `MLeak_cf | `MLeak_cpp | `MLeak_no_arc | `MLeak_unknown ] list
val models_mode : bool
val modified_targets : string option
val monitor_prop_size : bool
val nelseg : bool
val no_translate_libs : bool
val objc_memory_model_on : bool
val only_footprint : bool
val out_file_cmdline : string
val pmd_xml : bool
val precondition_stats : bool
val print_logs : bool
val print_builtins : bool
val print_traces_in_tests : bool
val print_types : bool
val print_using_diff : bool
val procs_csv : string option
val procs_xml : string option
val project_root : string
val quandary : bool
val quandary_sources : Yojson.Basic.json
val quandary_sinks : Yojson.Basic.json
val quiet : bool
val reactive_mode : bool
val reactive_capture : bool
val report : string option
val report_hook : string option
val report_runtime_exceptions : bool
val reports_include_ml_loc : bool
val results_dir : string
val save_analysis_results : string option
val seconds_per_iteration : float option
val show_buckets : bool
val show_progress_bar : bool
val skip_analysis_in_path : string list
val skip_clang_analysis_in_path : string list
val skip_translation_headers : string list
val spec_abs_level : int
val specs_library : string list
val stacktrace : string option
val stacktraces_dir : string option
val stats_mode : bool
val subtype_multirange : bool
val svg : bool
val symops_per_iteration : int option
val test : bool
val test_filtering : bool
val testing_mode : bool
val threadsafety : bool
val trace_error : bool
val trace_ondemand : bool
val trace_join : bool
val trace_rearrange : bool
val type_size : bool
val unsafe_malloc : bool
val use_compilation_database : [ `Deps | `NoDeps ] option
val whole_seconds : bool
val worklist_mode : int
val write_dotty : bool
val write_html : bool
val xcode_developer_dir : string option
val xcpretty : bool
val xml_specs : bool


(** Global variables *)

(** [set_reference_and_call_function ref val f x] calls f x with ref set to val.
    Restore the initial value also in case of exception. *)
val set_reference_and_call_function : 'a ref -> 'a -> ('b -> 'c) -> 'b -> 'c

val arc_mode : bool ref

val curr_language : language ref

val curr_language_is : language -> bool

val footprint : bool ref

(** Call f x with footprint set to true.
    Restore the initial value of footprint also in case of exception. *)
val run_in_footprint_mode : ('a -> 'b) -> 'a -> 'b

(** Call f x with footprint set to false.
    Restore the initial value of footprint also in case of exception. *)
val run_in_re_execution_mode : ('a -> 'b) -> 'a -> 'b

val forcing_delayed_prints : bool ref
val pp_simple : bool ref


(** Global variables with initial values specified by command-line options *)

val abs_val : int ref

val reset_abs_val : unit -> unit

(** Call f x with abs_val set to zero.
    Restore the initial value also in case of exception. *)
val run_with_abs_val_equal_zero : ('a -> 'b) -> 'a -> 'b

val allow_leak : bool ref

val clang_compilation_db_files : string list ref

(** Command Line Interface Documentation *)

val print_usage_exit : unit -> 'a
