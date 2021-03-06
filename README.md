# LL::WK::Api

## Roughly how works:
```
require 'll_wk_api'
api = LL::WK::API.connect(url: 'api_url', username: 'username', password: 'password')
context = { date_from: Time.now.to_i -7200
  date_to: Time.now.to_i,
  per_page: 1000
}
api.from_api('users', context) do |u|
  puts u['id']
end
api.search_for_users(1533824907) #Some random time ago
api.search_for_user_album_items(some_user_id) # returns the array of user

```
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'll_wk_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ll_wk_api

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ll_wk_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LL::WK::API project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ll_wk_api/blob/master/CODE_OF_CONDUCT.md).
