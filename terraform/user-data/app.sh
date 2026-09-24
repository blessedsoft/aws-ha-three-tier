#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/app-bootstrap.log | logger -t app-bootstrap -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y nodejs npm awscli

id nodeapp >/dev/null 2>&1 || useradd --system --home /opt/node-app --shell /sbin/nologin nodeapp
mkdir -p /opt/node-app
cd /opt/node-app

cat >package.json <<'JSON'
{
  "name": "ha-node-app",
  "version": "1.0.0",
  "private": true,
  "main": "app.js",
  "dependencies": {
    "@aws-sdk/client-secrets-manager": "^3.800.0",
    "pg": "^8.13.1"
  }
}
JSON

npm install --omit=dev

cat >app.js <<'NODE'
const http = require("http");
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { Client } = require("pg");

const PORT = 3000;
const secretArn = process.env.DB_SECRET_ARN;
const dbHost = process.env.DB_HOST;
const dbName = process.env.DB_NAME;
let dbClient = null;

async function connectDatabase() {
  const sm = new SecretsManagerClient({});
  const response = await sm.send(new GetSecretValueCommand({ SecretId: secretArn }));
  const secret = JSON.parse(response.SecretString);

  dbClient = new Client({
    host: dbHost,
    port: 5432,
    database: dbName,
    user: secret.username,
    password: secret.password,
    ssl: { rejectUnauthorized: false }
  });

  await dbClient.connect();
}

async function databaseHealthy() {
  if (!dbClient) return false;
  try {
    await dbClient.query("SELECT 1");
    return true;
  } catch (_) {
    return false;
  }
}

const server = http.createServer(async (req, res) => {
  if (req.url === "/health") {
    const dbOk = await databaseHealthy();
    res.writeHead(dbOk ? 200 : 503, {"Content-Type": "application/json"});
    res.end(JSON.stringify({
      status: dbOk ? "ok" : "degraded",
      service: "nodejs-app",
      database: dbOk ? "ok" : "unavailable"
    }));
    return;
  }

  res.writeHead(200, {"Content-Type": "application/json"});
  res.end(JSON.stringify({
    service: "nodejs-app",
    status: "ok",
    database: dbClient ? "connected" : "disconnected"
  }));
});

connectDatabase()
  .catch(err => console.error("Database connection failed:", err.message))
  .finally(() => {
    server.listen(PORT, "0.0.0.0", () => {
      console.log(`Node.js application listening on $${PORT}`);
    });
  });
NODE

cat >/etc/systemd/system/node-app.service <<'UNIT'
[Unit]
Description=HA Three Tier Node.js Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=nodeapp
Group=nodeapp
WorkingDirectory=/opt/node-app
Environment="DB_HOST=${db_host}"
Environment="DB_NAME=${db_name}"
Environment="DB_SECRET_ARN=${db_secret_arn}"
ExecStart=/usr/bin/node /opt/node-app/app.js
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/node-app

[Install]
WantedBy=multi-user.target
UNIT

chown -R nodeapp:nodeapp /opt/node-app
systemctl daemon-reload
systemctl enable --now node-app.service
