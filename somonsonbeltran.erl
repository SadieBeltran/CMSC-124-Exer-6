%% Authors: Beltran, Samantha Elysse
%%          Somoson, Lea Marie
%
%% Contributions:
%% Beltran - Connected two nodes, disconnected two nodes when one node send a message "bye", tried to implement the bonus
%% Somoson - Implemented message sending but waits for the reply of the other node, implemented message sending and does not wai
%%           for the reply of the other node.

-module(somonsonbeltran).
-compile(export_all).

init_chat() -> 
    User2 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    io:format("~p started a chatroom,", [User2]),
    register(pong, spawn(somonsonbeltran, pong, [User2])).

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
pong(User2) ->
    receive
        bye ->
            io:format("Your partner disconnected~n"),
            halt(1);
        {User1, RcvMessage1} -> 
            io:format("~s: ~s", [User1, RcvMessage1]);  %% prints the received message from the other node
        Ping_Pid ->
            Ping_Pid ! pong, %this notifies the other node to start the chatroom.
            spawn(somonsonbeltran, pong, [User2, Ping_Pid])
    end,
    pong(User2).

% when the message sent is "bye"
pongLeave(Ping_Pid) ->
    Ping_Pid ! bye, %sends a signal to the other node and exits the terminal
    io:format("You left the chat~n"),
    halt(1).  % terminate process

init_chat2(Pong_Node) ->
    User1 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    spawn(somonsonbeltran, ping, [User1, Pong_Node, Pong_Node]).

% sending Pid to pong user
% ideally for multiple connected nodes ito, so it basically accepts a list of nodes from nodes() and iterates through the list. Each element is pinged with the process' id number which will let the pong function initiate chat.
ping(User1, [Pong_Node | T], Pong_Nodes) ->
    {pong, Pong_Node} ! self(),
    ping(User1, T, Pong_Nodes);

ping(User1, [], Pong_Nodes) ->
    ping1(User1, Pong_Nodes).

% continuous receiving message
ping1(User1, Pong_Node) ->
    receive
        pong ->
            spawn(somonsonbeltran, ping2, [User1, Pong_Node]);
        bye ->
            io:format("Your partner disconnected~n"),
            halt(1);
        {User2, RcvMessage2} ->
            io:format("~s: ~s", [User2, RcvMessage2])  % prints the received message from the other node
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
            sendMessages(User1, Pong_Node, Pong_Node, Message), %for multiple recepients
            ping2(User1, Pong_Node)                     
    end.

% iterates through the list of connected nodes and sends a message to each.
sendMessages(User1, [Pong_Node | T], Pong_Nodes, Message) when T /= [] ->
    {pong, Pong_Node} ! {User1, Message},       % sends message to pong node
    sendMessages(User1, T, Pong_Nodes, Message);

sendMessages(User1, [Pong_Node | []], _, Message) ->
    {pong, Pong_Node} ! {User1, Message}.       % sends message to pong node
    
%% when the message sent is "bye" also refactored to accommodate multiple nodes
pingLeave([Pong_Node | T]) when T /= [] ->
    {pong, Pong_Node} ! bye,
    pingLeave(T);

pingLeave([T | []]) ->
    {pong, T} ! bye,
    io:format("You left the chat~n"),
    halt(1).   % terminate process

init_chat3(Nodes) ->
    User1 = string:strip(io:get_line('Enter your name: '), right, $\n),
    spawn(somonsonbeltran, ping, [User1, Nodes, Nodes]).