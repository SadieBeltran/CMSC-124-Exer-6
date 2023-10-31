-module(test).
-compile(export_all).

%trying to do an infinite pingpong

init_chat() ->
    register(pong, spawn(test, pong, [])).

pong() ->
	receive
		finished ->
			io:format("Pong finished ~n");
		{ping, Ping_Pid} ->
			io:format("Pong got ping ~n"),
			Ping_Pid ! pong,
			pong()
	end.

init_chat2(Pong_Node) ->
    spawn(test, ping, [3, Pong_Node]).


%find a way to send nonode@nohost
ping(0, Pong_Node) ->
    {pong, Pong_Node} ! finished,
    io:format("Ping finished");

ping(N, Pong_Node) ->
    {pong, Pong_Node} ! {ping, self()},
	receive
		pong ->
			io:format("Ping got pong~n")
	end,
	ping(N-1, Pong_Node).