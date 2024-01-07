# `-L` to make connection to local address forward to remote addr.

e.g. when creating vm via qemu, not easy to configure port forwarding easily
when vm is running. We can use `-L` option to achieve this.

```
-L [bind_address:]port:host:hostport
-L [bind_address:]port:remote_socket
-L local_socket:host:hostport
-L local_socket:remote_socket
```

    Specifies that connections to the given TCP port  or  Unix  socket  on  the  local
    (client)  host  are to be forwarded to the given host and port, or Unix socket, on
    the remote side.

# `-D` to listen on an port, creating an socks5 proxy.

e.g. poor man's fq.

```
-D [bind_address:]port
```

    Specifies  a local “dynamic” application-level port forwarding.
    This works by allocating a socket to listen to port on the local side,
    optionally  bound  to  the specified  bind_address.   Whenever a connection is
    made to this port, the connection is forwarded over the secure channel, and
    the application  protocol  is  then used  to  determine  where  to  connect to
    from the remote machine.
