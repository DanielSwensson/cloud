-module(test).
-export([test/0]).

test() ->
	{ok, Socket} = gen_udp:open(0, [binary]),
	io:format("opened socket: ~p ~n",[Socket]),
	ok = gen_udp:send(Socket,"localhost",8080,term_to_binary({join,"Daniel"})),

	receive 
		{udp, Socket, _, _,Bin} ->
			io:format("Got : ~p ~n", [binary_to_term(Bin)])
	end,
	gen_udp:close(Socket).
