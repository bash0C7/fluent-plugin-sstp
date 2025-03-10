# fluent-plugin-sstp

[Fluentd](https://fluentd.org/) output plugin to send messages using Sakura Script Transfer Protocol (SSTP).

This plugin allows you to send SSTP messages to compatible servers such as SSP, which is commonly used for Japanese desktop assistants.

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

```
  @type sstp
  sstp_server                127.0.0.1
  sstp_port                  9801
  request_method             NOTIFY
  request_version            SSTP/1.1
  sender                     カードキャプター
  script_template            \h\s[8]汝のあるべき姿に戻れ。クロウ<%= record['craw_card'] %> \uLD買おか\e
```

### Parameters

- `sstp_server`: Host name or IP address of the SSTP server
- `sstp_port`: Port number of the SSTP server (default: 9801)
- `request_method`: SSTP request method (currently only "NOTIFY" is supported)
- `request_version`: SSTP protocol version (e.g., "SSTP/1.1")
- `sender`: Sender name that appears in the SSTP message
- `option`: Option switch (default: nodescript,notranslate)
- `script_template`: ERB template for the script content, record fields can be referenced with `<%= record['field_name'] %>`

## Copyright

Apache License, Version 2.0

## Releases

- 2025/03/10 0.1.0 Updated to support Fluentd v1.0+ with modern plugin API
- 2014/01/26 0.0.0 1st release
