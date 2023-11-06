-module(u).
-compile(export_all).

init_chat(Nodes) -> 
    register(pong, spawn(u, pong, [[], Nodes])).

pong(Users, Nodes) ->
    receive
        {bye, User} ->
            io:format("~p has disconnected~n", [User]),
            pang(Users);
        {User, RcvMessage} ->
            io:format("~s: ~s", [User, RcvMessage]);
        {Ping_Pid, User} ->
            spawn(u, sendMessage, [User, Nodes]),
            pong([Users] ++ Ping_Pid)
    end,
    pong(Users)

pingMsg(User, Nodes) ->
    Message = io:get_line("You: "),
    if
        Message == "\n" ->  % ignores the empty message
            pingMsg(User, Pong_Node);
        Message == "bye\n" -> pingLeave(Pong_Node, User);
        Message /= "bye\n" -> 
            sendMessages(User1, Pong_Node, Pong_Node, Message),
            pingMsg(User1, Pong_Node)                     
    end.

sendMessages(User1, [Pong_Node | T], Pong_Nodes, Message) when T /= [] ->
    {pong, Pong_Node} ! {User1, Message},       % sends message to pong node
    sendMessages(User1, T, Pong_Nodes, Message);

sendMessages(User1, [Pong_Node | []], _, Message) ->
    {pong, Pong_Node} ! {User1, Message}.       % sends message to pong node

%% when the message sent is "bye"
pingLeave([Pong_Node | T], User) when T /= [] ->
    {pong, Pong_Node} ! {bye },
    pingLeave(T);

%checks if userlist is empty and halts process.
pang([]) ->
    io:format("Chatroom is empty ~n");
    halt(1).

init_chat2(Nodes) ->
    User1 = string:strip(io:get_line('Enter your name: '), right, $\n),     %% removes '\n' in name (Reference: https://stackoverflow.com/a/18573368)
    spawn(u, ping, [User1, Nodes, Nodes]).

ping(User1, [Pong_Node | T], Nodes) ->
    {pong, Pong_Node} ! self(),
