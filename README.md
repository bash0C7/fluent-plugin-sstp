# fluent-plugin-sstp

[Fluentd](https://fluentd.org/) output plugin to do send server using Sakura Script Transfer Protocol(SSTP)

TODO: write description for you plugin.

## Installation

### RubyGems

```
$ gem install fluent-plugin-sstp
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-sstp"
```

And then execute:

```
$ bundle
```

## Configuration

````
  type sstp
  sstp_server                127.0.0.1
  sstp_port                  9801
  request_method             NOTIFY
  request_version            SSTP/1.1
  sender                     カードキャプター
  script_template            \0汝のあるべき姿に戻れ。<%= record['craw_card'] %>\e
````

## Copyright

* Copyright(c) 2025- bash0C7
* License
  * Apache License, Version 2.0

## releases

- 2025/03/xx 0.1.0 reboot
- 2014/01/26 0.0.0 1st release
