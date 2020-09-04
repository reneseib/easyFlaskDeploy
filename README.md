# makeFlaskApp
Bash script to easily set up a blank, serviced Flask app with gunicorn and NGINX on UNIX server

### Creates the following directories:
- app
    - templates
    - static

### Creates the following files:
- application.py
- wsgi.py
- (appname).service (```in /etc/systemd/system/```)
- server file (in /etc/nginx/sites-available and links to /etc/nginx/sites-enabled)


### Required packages:
- awk
- certbot


