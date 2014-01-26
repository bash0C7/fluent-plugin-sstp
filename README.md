# fluent-plugin-sstp

Fluentd output plugin to send server using Sakura Script Transfer Protocol(SSTP)

## Requirement

nc(netcat) command

## config

````
  type sstp
  sstp_server                127.0.0.1
  sstp_port                  9801
  request_method             NOTIFY
  request_version            SSTP/1.1
  sender                     カードキャプター
  script_template            \0汝のあるべき姿に戻れ。<%= record['craw_card'] %>\e
````

Support SSTP request method is `NOTIFY/1.1` only
http://www.ooyashima.net/db/sstp.html#notify11

I'm expecting your contribute!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## releases

- 2014/01/26 0.0.0 1st release
