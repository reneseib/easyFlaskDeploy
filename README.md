# makeFlaskApp
Bash script to easily set up a blank, serviced Flask app with gunicorn and NGINX on UNIX server (requires sudo rights)

### Creates the following directory and file structure:
- __app__
    - application.py
    - wsgi.py
    - __templates__
        - index.html
    - __static__

### Creates a service file:
- ```/etc/systemd/system/```__appname.service__

### Creates server file:
- ```/etc/nginx/sites-available``` and link to ```/etc/nginx/sites-enabled```


### Required packages:
- awk
- certbot


