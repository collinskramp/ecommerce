module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      script: './backend/server.js',
      instances: 1,
      env: { NODE_ENV: 'development', PORT: 5001 }
    },
    {
      name: 'ecommerce-frontend',
      script: 'npm',
      args: 'start',
      cwd: './frontend',
      env: { PORT: 3000, BROWSER: 'none' }
    },
    {
      name: 'ecommerce-dashboard',
      script: 'npm',
      args: 'start',
      cwd: './dashboard',
      env: { PORT: 3001, BROWSER: 'none' }
    }
  ]
};
