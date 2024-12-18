#### 2.3.0

- Support Rails 8.0

#### 2.2.0

- Add DB query counts for ActiveRecord 7.2
  Only real queries are reported; cached queries are excluded

#### 2.1.2

- In ActiveJob logs, output gid:// when available instead of using .to_json

#### 2.1.1

- Report correct request method when Rails handles an exception

#### 2.1.0

- Require Rails 7.1.2
- Remove BroadcastLogger extension

#### 2.0.0

- (Breaking) Require Rails 7.1
  For Rails 5.2, 6.x, and 7.0, use log_sanity 1.x
- (Potentially breaking) Remove RoutingErrorCatcher middleware
  Shouldn't break unless directly referenced during app's middleware setup
  Mostly not needed on Rails 7.1, but for an alternative, see [rails-hush](https://github.com/zarqman/rails-hush) gem
- Handle new events and updated payloads for Rails 7.1
- Use updated instrumentation API in request_logger
- Refactor initializer to use on_load

#### 1.3.2

- Fix logging on Rails 7.1 due to default use of BroadcastLogger

#### 1.3.1

- Handle updated show_exceptions values in Rails 7.1

#### 1.3.0

- Fix timing of gem initialization
- Support Rails 7.1
- Ensure ActionCable's logger level isn't made more permissive

#### 1.2.0

- Add support for ActionCable logs
- Fix :at on Rails 7

#### 1.1.1

- Support Rails 7.0

#### 1.1.0

- Include tags when rendering formatted strings
- Preserve string_formatter as disabled
- Place :at at the front of messages

#### 1.0.0 and prior

(see git history)
