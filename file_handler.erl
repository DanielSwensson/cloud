-module(file_handler).
-export([start/1, create_dir/1]).

start(DirName) ->
	Pid = spawn(fun() -> loop() end),
	register(file_handler, Pid),
	create_dir("./" ++ DirName),
	ok.

loop() ->
	receive
		{From,{create_dir, DirName}} ->
			From ! {create_dir(DirName, server)},
			loop()		
	end.
create_dir(DirName) ->
	rpc({create_dir,DirName}).
create_dir(DirName,server) ->
	catch file:make_dir(DirName),
	file_created.

rpc(Msg) ->
		file_handler ! {self(),Msg},
	       	receive 
			Reply ->
				Reply
		end.	       
		
