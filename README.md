## Quickfeed

This is a simple and fast RSS reader, intended to run on your own server and replace Google Reader. It supports multiple users on a single server.

## Getting Started

```
bundle install
```

Create the database and schema, and download all the games for the current year:

```
rake db:create
rake db:migrate
```

And you're going to want to set up the crontab, using whenever:

```
whenever --set environment=development --update-crontab quickfeed
```

It will now run every fifteen minutes, to update any feeds you've added.

And to run the server locally:

```
rails server
```

Now go check it out in your browser at [http://localhost:3000](http://localhost:3000)!
