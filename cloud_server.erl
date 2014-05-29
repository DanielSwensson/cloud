-module(cloud_server).
-export([start/1]).

start(Port) ->
	catch unregister(cloud_server),	
	Pid = spawn(fun() -> server_start(Port) end),
	register(cloud_server, Pid).

server_start(Port) ->
	{ok, Socket} = gen_udp:open(Port,[binary]),
	io:format("Server has opened socket: ~p ~n",[Socket]),
	ok = file_handler:start(dir()),
	loop(Socket).

loop(Socket) ->
	receive 
		{udp, Socket, Host, Port, Bin} = Req ->
			ReceivedData = binary_to_term(Bin),
			io:format("Server received: ~p ~n ", [ReceivedData]),
			Response = perform_request(ReceivedData,Req),
			gen_udp:send(Socket,Host,Port,term_to_binary(Response)),
			loop(Socket)
	end.

perform_request({create_file, UserName, FileName}, _Req) ->
	case get(UserName) of 
		{name, UserName} ->
			file_handler:create_file(dir() ++ UserName ++ "/",FileName);	
		_Else ->
			{error, "Unknown User: " ++ UserName}
	end;		

perform_request({join, UserName}, _Req) ->
	case get(UserName) of 
		undefined ->
			put(UserName,{name, UserName}),
			file_handler:create_dir(dir() ++ UserName);
		_Else ->
			{user_exists, "Welcome Back " ++ UserName}
	end;

perform_request(_,_Req) -> other.
dir() ->
	"files/".

