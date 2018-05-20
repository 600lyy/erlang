-module(tut1).
-export([start_ping/1, start_pong/0,
          ping/2, pong/0]).

fac(1) ->
  1;
fac(N) ->
  N * fac(N-1).

ping(0, Pong_Node) ->
  {pong, Pong_Node} ! finished,  
  io:format("ping finished~n", []);
ping(N, Pong_Node) ->
  {pong, Pong_Node} ! {ping, self()},
  receive
    pong ->
      io:format("Ping received pong~n", [])
  end,
  ping(N-1, Pong_Node).

pong() ->
  receive
    finished ->
      io:format("Pong finished~n", []);
    {ping, Ping_PID} ->
      io:format("Pong received ping~n", []),
      Ping_PID ! pong,
      pong()
  end.

start_ping(Pong_Node) ->
  spawn(tut1, ping, [3, Pong_Node]).

start_pong() ->
  register(pong, spawn(tut1, pong, [])).

    



