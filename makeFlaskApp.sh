#!/bin/bash

echo "Enter the path for your app:"
read BASE_PATH

echo "Enter the app name:"
read APP_NAME

echo "Enter the domain:"
read DOMAIN

# Path variables
APP_PATH="$BASE_PATH/$APP_NAME"
VENV_NAME="${APP_NAME}env"
VENV_PATH="$APP_PATH/$VENV"

# Flask Files
APP_FILE="$APP_PATH/application.py"
WSGI_FILE="$APP_PATH/wsgi.py"
INDEX_FILE="$APP_PATH/templates/index.html"

# Service Variables
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"
SERVICE_NAME=$APP_NAME
CURRENT_USER=$(who am i | awk '{print $1}')

# NGINX Variables
DOMAIN=$DOMAIN
SERVER_FILE="/etc/nginx/sites-available/${DOMAIN}"


mkdir $APP_PATH
mkdir $APP_PATH/templates
mkdir $APP_PATH/static

python3 -m virtualenv $VENV_PATH
source "${VENV_PATH}/bin/activate"
pip install flask gunicorn

# Write the main application file to disk
cat > $APP_FILE << EOF
from flask import Flask, render_template, request
app = Flask(__name__)

@app.route("/")
def hello():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF

# Write the WSGI file to disk
cat > $WSGI_FILE << EOF
from application import app

if __name__ == "__main__":
    app.run()
EOF

cat > $INDEX_FILE << EOF
<html>
<body>
    <h1>Hello World!</h1>
</body>
</html>
EOF


# Setting up the service
sudo cat > $SERVICE_FILE << EOF
[Unit]
Description=Gunicorn instance to serve ${APP_NAME}
After=network.target

[Service]
User=${CURRENT_USER}
Group=www-data
WorkingDirectory=${APP_PATH}
Environment="PATH=${VENV_PATH}bin"
ExecStart=${VENV_PATH}bin/gunicorn --workers 3 --bind unix:application.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME



# Setting up the NGINX server
sudo cat >  $SERVER_FILE << EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        include proxy_params;
        proxy_pass http://unix:${APP_PATH}/application.sock;
    }
}
EOF

sudo ln -s $SERVER_FILE /etc/nginx/sites-enabled
sudo systemctl restart nginx
sudo certbot --nginx -d $DOMAIN
sudo chown -R $CURRENT_USER:www-data $APP_PATH
sudo systemctl restart $SERVICE_NAME
