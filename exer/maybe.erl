-module(maybe).
-compile(export_all).

% CMSC 124 - ST-1L 
% LEA MARIE SOMONSON - wrote the sending messages feature until 'bye'
% ELYSSE SAMANTHA T. BELTRAN - connected the two nodes and attempted the bonus exercise.

init_chat() -> 
    User2 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    io:format("~p started a chatroom,", [User2]),
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
    spawn(maybe, ping, [User1, Pong_Node, Pong_Node]).

% sending Pid to pong user
ping(User1, [Pong_Node | T], Pong_Nodes) ->
    {pong, Pong_Node} ! self(),
    ping(User1, T, Pong_Nodes);

ping(User1, [], Pong_Nodes) ->
    ping1(User1, Pong_Nodes).

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
    Message = io:get_line("You: "),
    if
        Message == "\n" ->  % ignores the empty message
            ping2(User1, Pong_Node);
        Message == "bye\n" -> pingLeave(Pong_Node);
        Message /= "bye\n" -> 
            sendMessages(User1, Pong_Node, Pong_Node, Message),
            ping2(User1, Pong_Node)                     
    end.

sendMessages(User1, [Pong_Node | T], Pong_Nodes, Message) when T /= [] ->
    {pong, Pong_Node} ! {User1, Message},       % sends message to pong node
    sendMessages(User1, T, Pong_Nodes, Message);

sendMessages(User1, [Pong_Node | []], _, Message) ->
    {pong, Pong_Node} ! {User1, Message}.       % sends message to pong node
    
%% when the message sent is "bye"
pingLeave([Pong_Node | T]) when T /= [] ->
    {pong, Pong_Node} ! bye,
    pingLeave(T);

pingLeave([T | []]) ->
    {pong, T} ! bye,
    io:format("You left the chat~n"),
    halt(1).   % terminate process

init_chat3(Nodes) ->
    User1 = string:strip(io:get_line('Enter your name: '), right, $\n),
    spawn(maybe, ping, [User1, Nodes, Nodes]).