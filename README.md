# LogSanity

LogSanity is another attempt at taming Rails logging and making logs more viable in production.

It's quite opinionated (partly intentional, partly a byproduct of being a young project) and yet strives for sane defaults and to play nicely within the natural order of Rails.

At its core, it aggregates various logging variables and then outputs one JSON-formatted, primary request log line. It's quite easy to add extra variables to this output, great for appending info about the authenticated user, active account, etc.

However, just because the primary output is a single line doesn't make it a one-line logging system. Taking inspiration from elsewhere[^1], the intent is for each conceptual event to have its own log entry. The default request line is just an http(s) request event. If the user takes other actions and those should be logged, do so--and give them their own entry. To this end, a small number of default Rails events are logged individually, such as sending an email, some ActiveJob processing, and a few others.

Example output: (Multi-line and extra whitespace added for readability; normally all one line.)

```
{ "at" : "2017-01-18T00:27:50.947Z",
  "event" : "https_get",
  "ip" : "127.0.0.1",
  "rq" : "ec337729-dbf3-4c6f-86b9-8d1a06c2277e",
  "route" : "ArticlesController#index",
  "format" : "html",
  "params" : {"id":"123456"},
  "duration" : {"total":20, "views":9, "activerecord":1},
  "status" : 200
}
```



### Installation

Install the usual way:
```
gem 'log_sanity'
```

By default, LogSanity does not enable itself. To do so, in `config/environments/production.rb` add:
```
config.logsanity.enabled = true
config.log_level = :info
```

You can go less verbose than `:info` (say, `:warn`), but more verbose (ie: `:debug`) is not recommended.


##### A note on initialization order

LogSanity initializes after running `application.rb` and `config/environments/*.rb`, but before `config/initializers/*.rb`. Most `config.logsanity.*` settings must be in one of the former or they will be ignored (`config.logsanity.silence_paths` being an exception).

However, `initializers/*.rb` may be used to reduce the scope of what's logged. For example, to skip logging of ActiveJob requests only:
```ruby
# initializers/logsanity.rb
LogSanity::LogSubscriber::ActiveJob.detach_from :active_job
```


### Usage

Basic usage may require nothing more than enable LogSanity as outlined above. Some common configuration settings include silencing logging for certain paths (like health checks) or adding information about the currently authenticated user.

##### Adding attributes

The most common way to add attributes is via controllers. Helper methods are provided for this. For example, to log the current user's ID, you might add the following to `application_controller.rb`:

```
after_filter do
  if current_user
    log_field 'user', current_user.id
  end
end
```

The syntax is simply `log_field(key, value)`. Since the output is JSON, `value` can even be a hash or array:
```
log_field 'user', {id: current_user.id, name: current_user.name}
```

You can log multiple fields by calling `log_field` multiple times.

If you must, you can get to the full fields hash:
```
LogSanity.fields['user'] ||= {}
LogSanity.fields['user']['id'] = current_user.id
```

It's also possible to add attributes via Rails' existing `log_tags` facility, which is documented more below.


##### Logging complete entries

To log a complete event (a complete log entry), try something like:
```
logger.info 'event'=>'user_signup', 'source'=>'ppc', 'campaign'=>'awesomeness', 'rq'=>request.uuid, 'user'=>current_user.id
```

If you pass in a hash to any `logger` method, it automatically becomes JSON output. The timestamp will be automatically added.



### Configuration options

While the above cover most of it, there are a handful of other potentially useful settings.

##### Silence logging for certain paths

This is particularly useful if you have any kind of health check path, as there's no need to fill up log files with that stuff.

```
config.logsanity.silence_paths += ["/health", %r{^/healthcheck}]
```

Both exact path matches (Strings) and Regex's are supported.


##### Logging of strings

By default, strings are logged as-is and not stuck inside a JSON object. If you prefer the opposite:

```
config.logsanity.json_strings = true
```

With `json_strings` as `false` (default), `logger.info "This is fantastic!"` would normally just output:
```
This is fantastic!
```
However, if `true`, you'll see:
```
{"at":"2017-01-18T00:27:50.947Z","message":"This is fantastic!"}
```


##### String formatting

When LogSanity initializes, it replaces the Rails log formatter with its own, but saves the old one for outputting strings (assuming `json_strings` is `false`). This means you can still configure the formatting of those. For example, to use Logger's default formatting (instead of Rails' default):

```
config.log_formatter = ::Logger::Formatter.new
```


##### Tagged logging

As noted above, you can either add extra attributes directly or via `log_tags`. We discussed direct already. Now let's take a look at tagged logging, which is a bit different in a JSON world.

```
config.log_tags = [ :subdomain ]
```

Just like Rails' support for text-style logs, you may use symbols (which call the named method on the `request` object), strings (logged literally), and Procs (which are passed `request` as a parameter).

LogSanity takes these and adds them to the default request log entry (but _not_ other log entries). If a tagged method (via symbol or Proc) returns a hash, it's merged directly into the output. Otherwise the return value is used as a string and given a key in the form `tag#` where # is automatically calculated.


### Additional notes

LogSanity is intended for production use at log_level info. At level debug, some logs are simply turned off. Others may continue to output as normal strings (such as ActiveRecord).

If not using tags, there is no need to use ActiveSupport::TaggedLogging with your logger. Just set the logger directly (if not using the default):
```
config.logger = ActiveSupport::Logger.new(STDOUT)
```

All default output includes the :uuid/:request_id using the key "rq". There is no need to add \[:uuid] to `config.log_tags`.

`ActionController::RoutingError` exceptions are always silenced and turned into a simple 404 log entry.

The request path is not included, as it mostly just duplicates `route` and `params`. If you need it, you could add it using `config.log_tags = [:filtered_path]`. Alternatively, consider adding X-Request-Id to your `nginx` (or other webserver) logs and correlating to those logs instead.

The `total` duration may be longer than you're used to seeing. By default, Rails only counts the time inside the application controller. In contrast, LogSanity also includes all the middleware between itself and the application controller. While this isn't the entire picture, it is closer to the actual real time elapsed.


### What does it do behind the scenes?

In short:
* Removes all default Rails logging, replacing it with its own
* Replaces Rails::Rack::Logger middleware with its own
* Adds middleware to intercept routing errors
* Replaces the current logger's formatter


### Final notes

There are still some things that could be handled better (such as multi-line strings in json_strings mode).

Pull requests are welcomed and encouraged. The only goal is to avoid making things unnecessarily complex.

Tested on Rails 5.2 through 7.1 (or later). Anything older is untested. Small patches for older compatibility will be considered.

License: MIT


[^1]: Parts [one](https://medium.com/@jlsuttles/structured-logging-part-1-what-s-the-big-deal-b7c6011e2504), [two](https://medium.com/@jlsuttles/structured-logging-part-2-usage-7754db10b6c), and [three](https://medium.com/@jlsuttles/structured-logging-part-3-practical-application-for-ruby-b5023f29f0af).
