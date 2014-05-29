-module(file_handler).
-export([start/1, create_dir/1, create_file/2]).

start(DirName) ->
	catch unregister(file_handler),
	Pid = spawn(fun() -> loop() end),
	register(file_handler, Pid),
	create_dir("./" ++ DirName),
	ok.

loop() ->
	receive
		{From,{create_dir, DirName}} ->
			From ! create_dir(DirName, server),
			loop();
		{From, {create_file, Path}} ->
			From ! create_file(Path,server),
			loop()
	end.

create_file(Path,server) ->
	case file:write_file(Path, "")  of
	       	ok ->
			{ok, Path};
		{error, Reason} ->
	 		{error, Reason}
	end;

create_file(DirName,FileName) ->
	rpc({create_file,"./" ++  DirName ++ FileName}).
		
create_dir(DirName) ->
	rpc({create_dir,DirName}).
create_dir(DirName,server) ->
	catch file:make_dir(DirName),
	{ok, DirName}.
rpc(Msg) ->
		file_handler ! {self(),Msg},
	       	receive 
			Reply ->
				Reply
		end.	       
		
