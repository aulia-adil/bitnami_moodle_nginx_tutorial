YouTube Tutorial

https://youtu.be/dKewlzP2luY

Other sources
1. https://hub.docker.com/r/bitnami/moodle

If you want to use HTTPS, then we can use this

```
nginx:
    image: nginx:1.27
    ports:
      - '80:5000'
      - '443:443'
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./nginx/logs:/var/log/nginx
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot

  certbot:
    image: certbot/certbot
    volumes:
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot
    entrypoint: /bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'

  certbot-init:
    image: certbot/certbot
    volumes:
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot
    entrypoint: /bin/sh -c 'certbot certonly --webroot --webroot-path=/var/www/certbot -d <website name>'
```

And then put this first in nginx `bitnami_moodle_nginx_tutorial/nginx/conf/default.conf`

```
server {
    listen 5000;
    server_name adilmuhammad.site;

    location / {
        proxy_pass http://moodle:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
```

After you run certbot, we can replace `default.conf` with

```
server {
    listen 5000;
    server_name adilmuhammad.site;

    location / {
        proxy_pass http://moodle:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name adilmuhammad.site;

    ssl_certificate /etc/letsencrypt/live/adilmuhammad.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/adilmuhammad.site/privkey.pem;

    location / {
        proxy_pass http://moodle:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
