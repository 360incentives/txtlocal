# txtlocal.co.uk API Wrapper

This gem is intended to provide a simple API for sending text messages via txtlocal's API.

## Installing

Add the gem to your gemfile
```ruby
gem 'txtlocal', git: 'git://github.com/davidtengeri/txtlocal.git'
```

## Usage

Configure the default settings
```ruby
Txtlocal.config do |c|
    c.from = "My App"
    c.username = "txtlocal_username"
    c.password = "txtlocal_password"
end
```
Or you can use an API key as well
```ruby
Txtlocal.config do |c|
    c.from = "My App"
    c.api_key = "txtlocal_api_key"
end
```

Use Txtlocal.send_message to send messages
```ruby
Txtlocal.send_message("You have 1 new friend request!", "07729435xxx")
```

Or create a message manually
```ruby
msg = Txtlocal::Message.new
msg.body = "Tickets will be available tomorrow morning at 9am"
msg.recipients = ["0712 3893 xxx", "447923176xxx"]
msg.add_recipient "+447729435xxx"
msg.send!
```

You can override the sender on a per message basis
```ruby
Txtlocal.send_message("You have 1 new friend request!", "07729435xxx", from: "someone")

msg = Txtlocal::Message.new
msg.from = "a mystery"
```

## Testing

Set test = true in the configuration to use the API's test mode
```ruby
Txtlocal.config.test = true
Txtlocal.config.testing?
 => true
```
