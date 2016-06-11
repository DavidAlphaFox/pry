-module(pry_utils).

-export([
         find_mfa/2,
         get_mfa_from_process_info/1,
         default/3
        ]).

-spec default(atom(), pry:info(), term()) -> term().
default(Key, Options, Default) ->
  case proplists:lookup(Key, Options) of
    none -> Default;
    {Key, Val} -> Val
  end.

find_mfa({'$initial_call', MFA}, Info) ->
  find_mfa(MFA, Info);
find_mfa({dictionary, Dict}, Info) ->
  find_mfa(proplists:lookup('$initial_call', Dict), Info);
find_mfa({initial_call, {proc_lib, init_p, 5}}, Info) ->
  find_mfa(proplists:lookup(dictionary, Info), Info);
find_mfa({initial_call, MFA}, Info) ->
  find_mfa(MFA, Info);

find_mfa({supervisor, Module, 1}, _) -> {Module, start_link, 0};
find_mfa({_M,_F,_A}=MFA, _) -> MFA;
find_mfa(_, _) -> none.

-spec get_mfa_from_process_info(pry:info()) -> none | mfa().
get_mfa_from_process_info(ProcessInfo) when is_list(ProcessInfo) ->
  find_mfa(proplists:lookup(initial_call, ProcessInfo), ProcessInfo);
get_mfa_from_process_info(_) -> none.
