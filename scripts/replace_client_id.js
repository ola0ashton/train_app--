const fs = require('fs');
const path = require('path');

const clientId = process.env.GOOGLE_CLIENT_ID;
if (!clientId) {
  console.error('GOOGLE_CLIENT_ID environment variable is not set');
  process.exit(1);
}

const indexPath = path.join(__dirname, '../web/index.html');
let content = fs.readFileSync(indexPath, 'utf8');
content = content.replace('%GOOGLE_CLIENT_ID%', clientId);
fs.writeFileSync(indexPath, content); 