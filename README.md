Brightwheel Takehome Project
============================

Hi, thanks for taking the time to check out this submission. I've provided setup using docker, for ease of setup, and
for your security (should you actually want to run this on your machine instead of just reading through it.)

It's a Rack app, using Rails. The application, as well as the routes are defined in `application.rb` -- that's it. Then
we have some controllers. I included puma because I wanted to check concurrency aspects, but yeah, we're only dealing
with threads and not workers. Obviously without using a more complex datastore we can't share the data across workers,
but it is shared across threads.

Let's get started.

## Setup and running

Setup with docker should be as simple as building an image.

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
