module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      cwd: './backend',
      script: 'server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      cwd: './frontend',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0',
        FORCE_COLOR: '0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-dashboard',
      cwd: './dashboard',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0',
        FORCE_COLOR: '0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/dashboard-error.log',
      out_file: './logs/dashboard-out.log',
      log_file: './logs/dashboard-combined.log',
      time: true
    }
  ]
};
