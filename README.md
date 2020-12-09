# docker-ocserv
AnyConnect VPN Docker image based on CentOS

## How to use this image

Run `ocserv` in a new container:

```sh
docker run --privileged -p 8443:443 -p 8443:443/udp -d --name ocserv ocserv
```

Generate the client certificates:

```sh
docker exec -it ocserv ocuser add john
```

Copy the client certificate from docker to local:

```sh
docker cp ocserv:/etc/pki/ocserv/users/john/user.p12 ./
```

Import the `user.p12` file to you client app.
