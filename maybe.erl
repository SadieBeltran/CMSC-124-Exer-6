-module(maybe).
-compile(export_all).

init_chat() -> 
    {ok, Name} = io:read("Enter your Name: "),
    register(pong, spawn(maybe, pong, [Name, _])).

pong(Name, Msg) ->
    {ok, Msg} = io:read("~p: ", [Name]),
    Ping_Pid ! {pong, Name, Msg}
    receive
        finished ->
            io:format("Your partner disconnected");
        {ping, Ping_Pid, Name2, Msg2} ->
            io:format("~p: ~p", [Name2], [Msg2]),
            pong()
    end.

init_chat2(Pong_Node) ->
    {ok, Name} = io:read("Enter your Name: "),
    spawn(maybe, ping, [Pong_Node, Name, _]).

ping(Pong_Node, Name, Msg) ->
    {pong, Pong_Node} ! {ping, self(), Name, Msg},
    receive
        {pong, Name2, Msg2} ->
            io:format("~p: ~p~n",[Name2], [Msg2])
    end,
    ping(Pong_Node, Name, _).

