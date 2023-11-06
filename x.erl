-module(x).
-compile(export_all).

func1(List) ->
    io:format("AA"),
    func2(List),
    io:format("BB").

func2([H|T]) ->
    io:format("~w", [H]),
    func2(T);

func2([]) ->
    io:format("DD").

test() ->
    io:format("nodes: ~p", nodes()).