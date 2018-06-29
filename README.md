# h5ai-base

[h5ai project](https://larsjung.de/h5ai/)

```
docker container run -it -p 80:80 -v $PWD/sharing-file:/share akit042/docker-h5ai
```

for overide options.json

```
docker container run -it -p 80:80 \
  -v $PWD/sharing-file:/share \
  -v $PWD/options.json:/usr/share/h5ai/_h5ai/private/conf/options.json \
  akit042/docker-h5ai
```
