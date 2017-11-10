# Requirements

Set env variable `BIND_ADDRESS` to local server ip address for security reasons it cannot be public.
Enable ports on firewall, application server should have access to monitoring server on this ports:
- 8125/udp (statsd)
- 12201/udp (graylog)

## Usage

`BIND_ADDRESS=192.168.0.1 make run`

- `BIND_ADDRESS=192.168.0.1` is server private ip, visible between application server and this server.


## Add vhost on your www server (+ SSL and + Basic auth)

For example:

```
upstream graylog {
    server 192.168.0.1:9000;
}

# graylog.example.com on port 80 or 443 (if ssl enabled - recommended)
server {
    listen       80
    server_name  graylog.example.com;
    root         /var/www;

    #auth_basic "Restricted";
    #auth_basic_user_file /etc/nginx/.htpasswd;

    #ssl on;
    #ssl_certificate /etc/ssl/example.com.pem;
    #ssl_certificate_key /etc/ssl/example.com.key;

    location / {
        charset UTF-8;

        proxy_pass http://graylog;
        proxy_set_header Host $host;
        # proxy_set_header X-Forwarded-Proto https; # SSL proxy if ssl is configured
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```
upstream grafana {
    server 192.168.0.1:3000;
}

# grafana.example.com on port 80 or 443 (if ssl enabled - recommended)
server {
    listen       80;
    server_name  grafana.example.com;
    root         /var/www;

    #auth_basic "Restricted";
    #auth_basic_user_file /etc/nginx/.htpasswd;

    #ssl on;
    #ssl_certificate /etc/ssl/example.com.pem;
    #ssl_certificate_key /etc/ssl/example.com.key;

    location / {
        charset UTF-8;

        proxy_pass http://grafana;
        proxy_set_header Host $host;
        # proxy_set_header X-Forwarded-Proto https; # SSL proxy if ssl is configured
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```