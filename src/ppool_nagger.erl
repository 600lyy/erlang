-module(ppool_nagger).
-behaviour(gen_server).
-export([init/1,
         stop/1,
         start_link/4,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         code_change/3,
         terminate/2]).

-record(state, {task, delay, max, sendTo}).


start_link(Task, Delay, Max, SendTo) ->
    State = #state{task=Task, delay=Delay,
                   max=Max, sendTo=SendTo},
    gen_server:start_link(?MODULE, State, []).


stop(Pid) ->
    gen_server:call(Pid, stop).


init(S=#state{delay=Delay}) ->
    {ok, S, Delay}. 


handle_call(stop, _, State) ->
    {stop, normal, ok, State};
handle_call(_Msg, _, State) ->
    {noreply, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.
    

handle_info(timeout, S=#state{
                        task=Task, delay=Delay, 
                        max=Max, sendTo=SendTo}) ->
    SendTo ! {self(), Task},
    if Max =:= infinity ->
           {noreply, S, Delay};
       Max =< 1 ->
           {stop, normal, S#state{max=0}};
       Max > 1 ->
           {noreply, S#state{max=Max-1}, Delay}
    end.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


terminate(_Reason, _State) -> ok.

