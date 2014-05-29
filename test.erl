-module(test).
-export([test/0]).

test() ->
	cloud_server:start(8080),
	timer:sleep(500),
	ok = test_join("Daniel"),
	%ok = test_already_exists_join("Daniel").
	ok = test_create_file("Daniel", "TestFile1.txt").

test_create_file(Name, FileName) ->
	Socket = open_socket(),
	erlang:display(os:cmd("rm -r ./files/" ++ Name ++ "/" ++ FileName)),
	ok = send(Socket, {create_file, Name, FileName}),
	{ok,_} = rcv(Socket),
       	ok.	
test_join(Name) ->
	Socket = open_socket(),
	erlang:display(os:cmd("rm -r ./files/" ++ Name)),
	ok = send(Socket,{join, Name}),
	{ok, _ } = rcv(Socket),
	ok.

test_already_exists_join(Name) ->
	ok = test_join(Name),
	Socket  = open_socket(),
	ok = send(Socket,{join, Name}),
	{user_exists, _} = rcv(Socket),
	ok.
send(Socket,Msg) ->
	gen_udp:send(Socket,"localhost",8080,term_to_binary(Msg)),
	ok.



open_socket() ->
	{ok, Socket} = gen_udp:open(0, [binary]),
	io:format("opened socket: ~p ~n",[Socket]),
	Socket.
rcv(Socket) ->
	Response = receive 
		{udp, Socket, _, _,Bin} ->
			io:format("Got : ~p ~n", [binary_to_term(Bin)]),
			binary_to_term(Bin)
	end,
	gen_udp:close(Socket),
	 Response.
