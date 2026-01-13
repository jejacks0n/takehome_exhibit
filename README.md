Takehome Project
================

Hi, thanks for taking the time to check out this submission. I've provided a Dockerfile, for ease of setup, and for your
security (should you actually want to run this on your machine instead of just reading through it.) This assumes you
have [Docker](https://www.docker.com) installed and running.

It's a Rack app, using Rails. The application, as well as the routes are defined in `application.rb` -- that's it. Then
we have some controllers. I included Puma because I wanted to check concurrency aspects, but yeah, we're only dealing
with threads and not workers. Obviously without using a more complex datastore we can't share the data across workers,
but it is shared across threads.

Let's get started.

## Setup and running

Setup with Docker should be as simple as building an image.

```shell
docker build -t takehome -f ./Dockerfile .
```

I've chosen port 8000 because you probably have that available, as port 3000 might already be taken.

```shell
docker run -p 8000:8000 takehome
```

And you can run the specs with the following:

```shell
docker run takehome rspec
```

## API Documentation

Here are a few curl commands to help document, and make testing the API easier, once you have the app up and running.

### Store Readings (POST)

This sends two readings for a device (not in any particular chronological order).

Readings with duplicate or invalid timestamps will be ignored.
Readings with invalid counts will be considered zero.
There are currently no rules for the device ids being UUIDv4.

```shell
curl -X POST http://localhost:8000/readings \
  -H "Content-Type: application/json" \
  -d '{"id": "36d5658a-6908-479e-887e-a949ec199272", "readings": [{"timestamp": "2021-09-29T16:09:15+01:00", "count": 6}, {"timestamp": "2021-09-29T16:08:15+01:00", "count": 5}]}'
```

Expected Response: `{"message":"Readings created"}` (Status 202)

### Get Latest Timestamp (GET)

Retrieve the latest timestamp for the device you just updated.

```shell
curl -X GET http://localhost:8000/devices/36d5658a-6908-479e-887e-a949ec199272/latest_timestamp
```

Expected Response: `{"latest_timestamp":"2021-09-29T16:09:15+01:00"}`

### Get Cumulative Count (GET)

Retrieve the total count.

```shell
curl -X GET http://localhost:8000/devices/36d5658a-6908-479e-887e-a949ec199272/cumulative_count
```

Expected Response: `{"cumulative_count":11}`

## Project Notes & Architectural Decisions

**Technology Choice & Concurrency**

I chose Rails to align with the target stack, though this specific problem set, of handling high-concurrency shared
state without a persistent database, actually maps very well to Elixir's strengths. In an Elixir environment, ETS
(Erlang Term Storage) would be a natural fit here. That said, I enjoyed tackling these constraints within the Rails
ecosystem too.

**Data Storage Strategy**

I initially explored using an in-memory (`:memory:`) SQLite database, as it solves several concurrency and race
condition issues, while offering flexibility for future data modeling and using a persistent datastore. However, I
ultimately decided that using `ActiveRecord` felt like bypassing the spirit of the exercise. I pivoted to `Rails.cache`
to stick closer to "pure" Ruby logic and POROs (Plain Old Ruby Objects), accepting the trade-off of managing data
consistency manually.

**Code Structure & Abstractions**

In a production environment, I would likely encapsulate the caching logic inside a `Device` model to obscure the cache
details, and handle key generation for persistence and retrieval in the same place. For this submission, I intentionally
kept that logic within the controllers to maximize readability and ease of review. I viewed this as a balance between
"Clean Architecture" and YAGNI (You Ain't Gonna Need It) keeping the code trivial until complexity demands otherwise. We
don't know where we'll want to refactor or optimize towards just yet, but there's obvious areas where this starts to
arise, like in the cache key creation, which I've included for the sake of this argument specifically.

**API Design**

I considered combining the endpoints into a single controller given their shared concerns, but settled on separating
them to retain a familiar "RESTful" pattern. I did loosen strict REST enforcement in the route definitions specifically
to prioritize client-friendliness.

**Asynchronous Processing**

For the `readings#create` action, I experimented with backgrounding the processing using `Thread.new` and
`Rails.application.executor.wrap` to return an `:accepted` status immediately. While interesting, I omitted it from the
final submission. It introduced threading complexity that felt premature without clearer requirements on load/latency
targets, and I genuinely wasn't sure about the impacts of doing it because I've not used that in a production
implementation.

**Closing Thoughts**

As I've progressed in my career, I've become less dogmatic about "the one right way" to build a feature. There are many
valid architectural approaches depending on the specific constraints and goals. I opted here for simplicity and
readability, providing a foundation we can iterate on.
