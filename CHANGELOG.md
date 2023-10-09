#### 2.0.0

- (Breaking) Require Rails 7.1
  For Rails 5.2, 6.x, and 7.0, use log_sanity 1.x
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
