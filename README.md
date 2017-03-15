## Sinatra sockets

### about

A boilerplate including:

- Sinatra
- Github oAuth
- Faye websockets, with token (not session) based auth so the front-end can be
  on a different host.
- ActiveRecord
- CRUD generator for routes
- Server-push module to alert clients of db updates.

Note that at this point this project is the _exact same_ as the server component
of [vue-sinatra-boiler](http://github.com/maxpleaner/vue-sinatra-boiler).
Originally this included a minimal front-end, but upstream development ended up
happening on an API-only variant, and that was the most full-featured version.

In the future I would like to add generator options for components that are not
necessarily dependent on one another, such as:

- whether or not to include simple (no auth) front end demo page for websockets
- whether or not to include Activerecord with crud generator and server-push module
- Whether or not to add oAuth with token-based websocket credentials

### installing


```sh
$ gem install sinatra_sockets
$ sinatra_sockets generate .
```

It will print the generated directory tree:

```txt
.
├── config.ru
├── crud_generator.rb
├── db
│   ├── migrate
│   │   └── 20170312215739_create_todos.rb
│   └── schema.rb
├── Gemfile
├── Gemfile.lock
├── models.rb
├── Procfile
├── Rakefile
├── README.md
├── server_push.rb
├── server.rb
└── ws.rb

2 directories, 13 files
```

Go to Github settings and create an oAuth application

Set up the server:

```sh
cd server_skeleton
bundle install
bundle exec rake db:create db:migrate
cp .env.example .env
nano .env # add the github credentials here
```

Start the server with thin (port defaults to 3000):

```sh
bundle exec thin start -p 3000
```

### components in detail:

**database / models**

this uses `sinatra-activerecord` and is similar to what's found in rails.

To generate a migration: `bundle exec rake db:create_migration NAME=my_migration_name`

Then customize it and `bundle exec rake db:migrate`.

`server.rb` contains the database configuration inline in the ruby code.

Models are all listed in `models.rb`, but it isn't necessary to do so. There are
no dynamic requires happening in this application - everything is individually
required in `server.rb`.

If using the crud generator or server-push, there is one required method that all
models must respond to: `public_attributes`. It returns a hash which is a filtered
version of `attributes` (suitable to be sent to clients).

**auth**

Here's how the auth flow works (the pieces are in `server.rb` and `ws.rb`):

-
  - Client checks their cookies to see if there's a token.
  - If there's not, one is requested from the server and saved as a cookie.
- Client establishes a websocket connection with server, passing token in query params
-
  - If the client found the token in the query, it will send a websocket request to try and authenticate.
    - If the server had stored credentials for that token, the client get a success response over websockets.
    - otherwise the client will get no response
  - If the client had to fetch a new token, the authentication is put on hold until the user clicks the
    "authenticate with github" button, passing the token to the server
    - The server makes the client through the Github auth flow but stores the token ref.
    - When Github auth is done clients get a ws message (looked up by token) saying they're authenticated.


**crud generator**

In the Sinatra server definition in `server.rb`, it's included with 
`register Sinatra::CrudGenerator`. This exposes one behemoth of a method:
`crud_generate`.

Here's its annotated signature (all the options are keyword args and are optional unless stated)

```rb
def crud_generate(
  
  # String such as "todo" (required).
  # The singular and pluralized forms are used to define routes i.e. /todos or /todo
  resource:,
 
  # Class such as Todo (required)
  resource_class:,

  # String such as '/api/', prefixed on all routes (defaults to '/')
  root_path: '/',

  # Hash. If this is defined, the `cross_origin` method is invoked with it as an arument.
  # e.g. { cross_origin: "http://localhost:8080" }
  # would allow all these CRUD routes to be hit by this origin.
  cross_origin_opts: nil,

  # A Proc which is passed the request and returns something truthy if the auth failed.
  # For example if it returns { error: "bad reqeust" }.to_json that will be the
  # final return value of the route and it will return early. 
  # If provided, this proc will apply to all of the routes, though each route can have
  # it's own proc which will override it (see below)
  auth: nil,

  # Each route has its own option which is a hash for configuration.
  # These are optional and defaults are set (see crud_generator.rb).
  # There are slight differences in the configuration hashes accepted per route,
  # but here is the full list of keys (all are optional):
  #
  #   method: Symbol (i.e. :get or :post, must be supported by Sinatra)
  #
  #   path: String (defaults to "/#{resource}" or "/#{plural_resource}"
  #
  #   auth: Proc with the same signature as the one discussed before
  #
  #   filter: Proc which is used on index route. Is passed an ActiveRecord Query of all records
  #     of the record_class and returns some subset which gets sent to the client.
  #
  #   secure_params: Proc used on create/update which is passed the request object and returns
  #      a list of the accepted param keys (params are filtered to only include these)
  #   

  # Hash with :method, :path, :auth, and :filter keys
  index: nil,

  # Hash with :method, :path, :auth, and :secure_params keys
  create: nil,

  # Hash with :method, :path, and :auth keys
  read: nil,

  # hash with :method, :path, :auth, and :secure_params keys
  update: nil,

  # hash with :method, :path, and :auth keys
  destroy: nil,

  # Array of symbols such as [:create, :update], will skip generating these routes.
  except: []
)
```

**Server push**

This is a module which can be `included` into any model.

It patches three foundational methods in ActiveRecord:

- `save` handles the case of creating new records.
  - although this method is called under the hood by both `create` and `update`,
    only the `create` case is handled here because there's a check whether the record is
    persisted and previously unsaved.
- `update` - handles when existing records are changed
- `destroy` - handles when records are deleted.

So after `include ServerPush` is placed in the model, any calls to `create`
(or `save`) on an unsaved record will trigger a "add_record" ws message to be sent.
Any call to `destroy` will trigger "destroy_record", and similarly `update` triggers
"update_record"

By default all sockets get these messages sent to them, though this can be configured
by defining a `publish_to` method in the model that returns a list of sockets.

All of the outgoing websocket messages in server-push are hashes with this signature:

- action: string ("add_record", "update_record", or "destroy_record")
- type: string i.e. "todo"
- record: Hash with the model's `public_attributes`.

[vue-sinatra-boiler](http://github.com/maxpleaner/vue-sinatra-boiler) has the front-end
API in place to use this.
