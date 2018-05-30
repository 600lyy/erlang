-module(kitty_server).
-behaviour(gen_server).
-compile(export_all).


-record(cat, {name, color, description}).


%%% client API
start_link() ->
    gen_server:start_link(?MODULE, [], []).


%% Synchronous call
order_cat(Pid, Requset={order, Name, Color, Description}) ->
    gen_server:call(Pid, Requset).


close_shop(Pid) ->
    gen_server:call(Pid, terminate).


%% Asynchronous call
return_cat(Pid, Cat=#cat{}) ->
    gen_server:cast(Pid, {return, Cat}).


%%% Server functions
init([]) -> {ok, []}.


handle_call({order, Name, Color, Description},_From, Cats) ->
    if Cats =:= [] ->
        {reply, make_cat(Name, Color, Description), Cats};
       Cats =/= [] ->
        {reply, hd(Cats), tl(Cats)}
    end.


handle_cast({return, Cat=#cat{}}, Cats) ->
    {noreply, [Cat|Cats]}.


handle_info(_Msg, Cats) ->
    {noreply, Cats}.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
    

%%% private functions
make_cat(Name, Color, Description) ->
    #cat{name=Name, color=Color, description=Description}.


terminate(normal, Cats) ->
    [io:format("~p was set free~n", [Cat]) || Cat <-Cats],
    ok.


