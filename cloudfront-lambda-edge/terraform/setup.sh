#!/bin/bash
# Dừng ngay khi có lệnh lỗi, log từng lệnh vào /var/log/cloud-init-output.log
set -euxo pipefail

# cloud-init chạy user data dưới quyền root nhưng không set HOME,
# nên PM2 phải dùng chung /root/.pm2 với pm2-root.service
export HOME=/root
APP_DIR=/opt/api

#Update the system and install Node.js
dnf update -y
dnf install -y nodejs

#Install PM2 and Express
npm install pm2@latest -g

mkdir -p $APP_DIR
cd $APP_DIR
npm install express --save

#Create and configure the Express app
cat <<'EOF' > $APP_DIR/app.js
let express = require('express');
let app = express();

app.get('/api', (req, res) => {
  console.log(JSON.stringify(req.headers));
  let message = {
    timestamp: new Date().toISOString(),
    headers: req.headers,
  };
  res.json(message);
});

app.listen(80, () => {
  console.log('api is up!');
});
EOF

#Start the app with PM2
pm2 start $APP_DIR/app.js --name api

#Enable PM2 to start on system boot
pm2 startup systemd -u root --hp /root
pm2 save
