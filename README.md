# BW Emailer

This Rails application implements a small REST API that sends an email using a configurable email service: `spendgrid` or `snailgun`.

## API Definition

### `POST` `/email`

Request Body:
```
{
    "to": "fred@test.com",
    "to_name": "fred",
    "from": "ashley@test.com",
    "from_name": "ashley",
    "subject": "my sub",
    "body": "<h1>my body</h1>"
}
```

Response:
```
{
    "id": 1,
    "status": "queued"
}
```

### `GET` `/email/:id`

Response:
```
{
    "id": 1,
    "status": "queued" // 'queued', 'sent', 'failed'
}
```

## Local Development Setup

* Install Ruby 2.7.2 via [Rbenv](https://github.com/rbenv/rbenv#installation)
```
rbenv install
```

* Install PostgreSQL
  * OSX: https://www.postgresql.org/download/macosx/
  * Ubuntu: https://www.postgresql.org/download/linux/ubuntu/

* Install [Bundler](https://bundler.io/)
```
gem install bundler
```

* Install Gems
```
bundle install
```

* Prepare the Database
```
bundle exec rails db:setup
```

* Create `.env` from `.env.example`
```
cp .env.example .env
```

* Run the Server
```
bundle exec rails server
```

## Setting the Emailer Service

This is configurable using an environment variable (in `.env`):
```
# spendgrid or snailgun
EMAIL_SERVICE=
```
Defaults to `spendgrid`.

## Setting other Environment Variables

The following `ENV` variables are used to communicate with `spendgrid` and `snailgun` respectively (in `.env`):
```
SPENDGRID_API_KEY=
SPENDGRID_API_URL=
```

```
SNAILGUN_API_KEY=
SNAILGUN_API_URL=
```
The values for these were included in the email for the takehome, but I omitted them from the codebase.


## Technical Decisions

### Why Ruby on Rails?

It's a bit overkill of a framework for this, but [Rails](https://rubyonrails.org/) is what I'm most familiar with right now.

### Why the EmailMessage model and an asynch ActiveJob?

At first, I considered just delegating the email-sending logic _directly_ to one of the external emailer services from the controller, but I didn't want the API response time to depend on the success/failure of a third-party integration.

Rather, I create an internal record of the email message and send the _actual_ email in a background task. Then update the record with the status of the job.

This also explains why there's a `POST` _and_ `GET` implemented for `/email`.

Another reason for this is the asynchronous nature of `snailgun`, which requires a `POST` and subsequent `GET` to determine the status of the email. A background job seemed like a better way to "poll" `snailgun`.

### Why environment variables to set the emailer?

In [Heroku](https://www.heroku.com/), setting an `ENV` variable doesn't require a _full on_ redeploy of the code. Seemed like the easiest way to flip between two emailer services.

Heroku aside, I used [`dotenv`](https://github.com/bkeepers/dotenv) to control these `ENV` variables during local development.

## Future Plans

### More Comprehensive Tests

There are some happy-path tests, but the test suite doesn't cover some edge cases. Some are omitted entirely. For example, `EmailJob` is untested due to my inability to figure out how to mock `ENV` properly.

### Index API for `/email`

Add a way to see _all_ emails sent and their statuses. Maybe a way to filter by `status`.

### Dockerize Local Development Setup

Manually installing application dependencies on a laptop is messy. Using a [`Dockefile`](https://www.docker.com/) and [`docker-compose`](https://docs.docker.com/compose/) would help.

### Add Docs

It's a small API, but I'd consider getting started with something like [`apipie`](https://github.com/Apipie/apipie-rails) to generate docs.

### CI through Github Actions

There's tons of different ways to build and incorporate CI into a project. Since I'm most familiar with Github, I'd use [Github Actions](https://github.com/features/actions) to automatically run the test suite.

### Get a Working Example in Heroku

Since I'm most familiar hosting on Heroku, it would be cool to get a working example of this repo a "production" environment.
