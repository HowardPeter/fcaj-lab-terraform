#!/bin/bash

set -e

dnf update -y
dnf install -y git mariadb105

DB_HOST="${db_host}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

echo "Waiting for RDS..."

MAX_RETRIES=60
RETRY=0

until mysql \
  -h "$DB_HOST" \
  -P 3306 \
  -u "$DB_USER" \
  -p"$DB_PASSWORD" \
  -e "SELECT 1;"
do
    RETRY=$((RETRY + 1))

    if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
        echo "ERROR: RDS is not reachable."
        exit 1
    fi

    echo "RDS is not ready yet... ($RETRY/$MAX_RETRIES)"
    sleep 10
done

echo "RDS is ready!"

cat > /tmp/init.sql <<'SQL'
CREATE DATABASE IF NOT EXISTS fcaj;

USE fcaj;

CREATE TABLE IF NOT EXISTS `user`
(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(15) NOT NULL,
    `comments` TEXT NOT NULL,
    `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active'
) ENGINE = InnoDB;

INSERT IGNORE INTO `user`
(`first_name`, `last_name`, `email`, `phone`, `comments`, `status`)
VALUES
('Amanda', 'Nunes', 'anunes@ufc.com', '012345 678910', 'I love FCAJ', 'active'),
('Alexander', 'Volkanovski', 'avolkanovski@ufc.com', '012345 678910', 'I love FCAJ', 'active'),
('Khabib', 'Nurmagomedov', 'knurmagomedov@ufc.com', '012345 678910', 'I love FCAJ', 'active');
SQL

mysql \
  -h "$DB_HOST" \
  -P 3306 \
  -u "$DB_USER" \
  -p"$DB_PASSWORD" \
  < /tmp/init.sql

echo "Database initialized"

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

source $NVM_DIR/nvm.sh

nvm install --lts
nvm alias default 'lts/*'

if ! command -v pm2 &> /dev/null; then
    npm install pm2 -g
fi

git clone https://github.com/thienluhoan/000006-EC2.git /root/000006-EC2

cd /root/000006-EC2

cat > .env <<EOF
DB_HOST="${db_host}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASS="${db_password}"
EOF

if [ ! -f package.json ]; then
    npm init -y
fi

npm install express dotenv express-handlebars body-parser mysql
npm install --save-dev nodemon

npm pkg set scripts.start="pm2 start app.js --name 'app' --watch"
npm pkg set scripts.dev="nodemon app.js"

sudo env PATH=$PATH:$(dirname $(which node)) $(which pm2) startup systemd -u $USER --hp $HOME

pm2 start app.js --name app --watch
pm2 save