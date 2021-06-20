# PSystem

A prototype of a payment system

## Description

That's a quite simple prototype of a payment system with 4 different types of transactions.

- Authorize: hold the money on the customer's account (we mock calls to customer's bank, take a look at ProcessAuthorizeTransactionService)
- Capture: move authorized money from the customer's account to the merchant's account
- Refund: move captured money back from the merchant's account to the customer's account
- Void: invalidate an auhtorize transaction

For now we have web interface at: /admin (use seeds or create an instance of Admin)

## Quick setup

We have a script for quick local deployment.

The quick setup script requires installed `docker` and `docker-compose`.
```
make install
```

And then you're able to run the app:
```
docker-compose up rails sidekiq
```

## API docs

There's a Postman collection [here](docs/postman_collection.json)

Don't forget to use the value from the Access-Token header after authentication request. Put it to the Authorize header for further requests.

## Tests

Use the next command to run usual rspec tests
```
make rspec
```

Use the next command to run feature tests
```
make rspec_features
```

Use the service `runner` to run some development stuff like
```
docker-compose run runner bundle install
```
