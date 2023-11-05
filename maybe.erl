-module(maybe).
-compile(export_all).

init_chat() -> 
    User2 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    register(pong, spawn(maybe, pong, [User2])).

%% continuous asking for message input
pong(User2, Ping_Pid) ->
    Message = io:get_line("You: "),
    if
        Message == "\n" -> 
            pong(User2, Ping_Pid);
        Message == "bye\n" -> pongLeave(Ping_Pid);
        Message /= "bye\n" -> 
            Ping_Pid ! {User2, Message},
            pong(User2, Ping_Pid)
    end.

%% continuous asking for message input
%% prints the received message from the other node
pong(User2) ->
    receive
        bye ->
            io:format("Your partner disconnected~n"),
            halt(1);
        {User1, RcvMessage1} -> 
            io:format("~s: ~s", [User1, RcvMessage1]);
        Ping_Pid ->
            Ping_Pid ! pong,
            spawn(maybe, pong, [User2, Ping_Pid])
    end,
    pong(User2).

% when the message sent is "bye"
pongLeave(Ping_Pid) ->
    Ping_Pid ! bye,
    io:format("You left the chat~n"),
    halt(1).  % terminate process

init_chat2(Pong_Node) ->
    User1 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    spawn(maybe, ping, [User1, Pong_Node]).

% sending Pid to pong user
ping(User1, Pong_Node) ->
    {pong, Pong_Node} ! self(),  
    ping1(User1, Pong_Node).

% continuous receiving message
% prints the received message from the other node
ping1(User1, Pong_Node) ->
    receive
        pong ->
            spawn(maybe, ping2, [User1, Pong_Node]);
        bye ->
            io:format("Your partner disconnected~n"),
            halt(1);
        {User2, RcvMessage2} ->
            io:format("~s: ~s", [User2, RcvMessage2])
    end,
    ping1(User1, Pong_Node).

% continuous asking for message input
ping2(User1, Pong_Node) -> 
    if
    Message = io:get_line("You: "),
        Message == "\n" ->  % ignores the empty message
            ping2(User1, Pong_Node);
        Message == "bye\n" -> pingLeave(Pong_Node);
        Message /= "bye\n" -> 
            {pong, Pong_Node} ! {User1, Message},       % sends message to pong node
            ping2(User1, Pong_Node)                     
        
    end.
    
%% when the message sent is "bye"
pingLeave(Pong_Node) ->
    {pong, Pong_Node} ! bye,
    io:format("You left the chat~n"),
    halt(1).   % terminate process