Brightwheel Takehome Project
============================

## Setup and running

Setup with docker should be as simple as building an image.

```shell
docker build -t takehome -f ./Dockerfile .
```

I've chosen port 8000 because you probably have that available, as port 3000 might already be taken.

```shell
docker run -it -p 8000:8000 takehome
```