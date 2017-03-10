```sh
$ gem install sinatra_sockets
$ sinatra_sockets generate .
```

It will print the generated directory tree:

```txt
Generated directory:
./server_skeleton
├── config.ru
├── Gemfile
├── Gemfile.lock
├── lib
│   ├── routes
│   │   └── ws.rb
│   └── routes.rb
├── README.md
└── server.rb

2 directories, 7 files
```

Start the server with thin:

```sh
cd server_skeleton
bundle exec thin start
# ... listening on localhost:3000
```

Earlier iterations of this had more files, mainly because of front-end stuff. However, I think a boiler is best
if it's kept minimal, so I removed all that and now it's API only. At the same time, though, I added a token-based
credential system as well as Github oAuth. Now it can tie in well with a front-end that's hosted on another server like
Webpack. 

This can be seen in action in another boilerplate, [vue-webpack-coffee-slim-boiler](https://github.com/maxpleaner/vue-webpack-coffee-slim-boiler). sinatra_sockets is used as the server component there. 
