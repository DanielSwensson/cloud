-module(cloud_server).
-compile(export_all).


%Start udp server
start() ->
	{ok, Socket} = gen_udp:open(8080,[binary]),
	file_handler:start("files"),
	io:format("Server has opened socket: ~p ~n",[Socket]),
	loop(Socket).

loop(Socket) ->
	receive 
		{udp, Socket, Host, Port, Bin} = Req ->
			ReceivedData = binary_to_term(Bin),
			io:format("Server received: ~p ~n ", [Bin]),
		%	Response = perform_request(ReceivedData,Req),
			%gen_udp:send(Socket,Host,Port,term_to_binary(Response)),
			loop(Socket)
	end.

%perform_request({join, UserName}, Req) ->
	
