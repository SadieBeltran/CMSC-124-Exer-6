-module(maybe).
-compile(export_all).

init_chat() -> 
    {ok, Name} = io:read("Enter your Name: "),
    register(pong, spawn(maybe, pong, [Name, ""])).

pong(Name, Msg) ->
    {ok, Msg} = io:read("~p: ", [Name]),
    Ping_Pid ! {pong, Name, Msg},
    receive
        {ping, Ping_Pid, Name2, "bye"} ->
            io:format("~p: bye", [Name2]),
            io:format("Your partner disconnected");
        {ping, Ping_Pid, Name2, Msg2} ->
            io:format("~p: ~p", [Name2], [Msg2]),
            pong(Name, Msg)
    end.

init_chat2(Pong_Node) ->
    {ok, Name} = io:read("Enter your Name: "),
    spawn(maybe, ping, [Pong_Node, Name, ""]).

ping(Pong_Node, Name, Msg) ->
    {ok, Msg} = io:read("~p: ", [Name]),
    {pong, Pong_Node} ! {ping, self(), Name, Msg},
    receive
        {pong, Name2, Msg2} ->
            io:format("~p: ~p~n",[Name2], [Msg2]),
            ping(Pong_Node, Name, Msg);
        {pong, Name2, "bye"} ->
            io:format("~p: bye", [Name2]),
            io:format("Your partner disconnected")
    end.

