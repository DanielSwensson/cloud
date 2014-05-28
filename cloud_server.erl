-module(cloud_server).
-compile(export_all).

%Start udp server
start() ->
	{ok, Socket} = gen_udp:open(8080,[binary]),
	io:format("Server has opened socket: ~p ~n",[Socket]),
	ok = file_handler:start(dir()),
	loop(Socket).

loop(Socket) ->
	receive 
		{udp, Socket, Host, Port, Bin} = Req ->
			ReceivedData = binary_to_term(Bin),
			io:format("Server received: ~p ~n ", [Bin]),
			Response = perform_request(ReceivedData,Req),
			gen_udp:send(Socket,Host,Port,term_to_binary(Response)),
			loop(Socket)
	end.


perform_request({join, UserName}, _Req) ->
	case get(UserName) of 
		undefined ->
			put(UserName,{name, UserName}),
			file_handler:create_dir(dir() ++ UserName);
		_Else ->
			"Welcome Back " ++ UserName
	end;

perform_request(_,_Req) ->other.
dir() ->
	"files/".
