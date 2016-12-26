This is a gem which is available through rubygems:

> gem install sinatra_sockets

After doing this the `sinatra_sockets generate PATH` shell command can be used.

The generated directory will be called `server_skeleton`. The PATH can be set to `.` for `./server_skeleton` to be created.

The generated code is commented and should be read through and customized. 

In its basic form it's a websocket server using faye-websockets and a very small sinatra front-end with Slim. 

Once generated, `cd server_skeleton` and run `thin start`. Then visit `localhost:3000` and open the dev console.

The client will have pinged a message to the server, and the server responds by saying `got <message>`
