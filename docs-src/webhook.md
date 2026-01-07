Webhook Guide for Telegem

This guide explains how to set up and use webhooks with Telegem. Telegram bots require HTTPS webhooks, and this guide covers all setup options.

🎯 Quick Start

Choose your hosting type and follow the appropriate section:

- VPS/Dedicated Server → Use the CLI tool for automatic SSL
- Cloud Platforms (Render, Railway, Heroku) → Use environment variables
- Manual Setup → Provide your own certificates
- Development/Testing → Use polling instead

🔐 SSL Requirements

Important: Telegram requires HTTPS webhooks. HTTP will not work. You must configure SSL using one of these methods:

Method 1: VPS/Dedicated Server (Recommended)

For servers where you have shell access and can run commands:

```bash
# 1. Install Telegem
gem install telegem

# 2. Run the SSL setup tool
telegem-ssl your-domain.com your-email@example.com

# Example:
telegem-ssl bot.myapp.com admin@myapp.com
```

What this does:

- Installs certbot if not present
- Gets a free SSL certificate from Let's Encrypt
- Creates .telegem-ssl configuration file
- Certificates auto-renew every 90 days

Your bot code:

```ruby
require 'telegem'

bot = Telegem.new(ENV['TELEGRAM_BOT_TOKEN'])

# Start webhook - automatically detects .telegem-ssl file
bot.webhook

# Or get the webhook server for more control
server = bot.webhook
server.set_webhook
```

Method 2: Cloud Platforms (Render, Railway, Heroku)

For platforms that provide SSL automatically:

```bash
# Set these environment variables
export TELEGRAM_BOT_TOKEN=your_bot_token
export TELEGEM_WEBHOOK_URL=https://your-app.onrender.com
export WEBHOOK_SECRET_TOKEN=optional_secret_token
```

Your bot code:

```ruby
require 'telegem'

bot = Telegem.new(ENV['TELEGRAM_BOT_TOKEN'])

# Start webhook - detects TELEGEM_WEBHOOK_URL
server = bot.webhook

# Set the webhook with Telegram
webhook_url = server.set_webhook
puts "Webhook URL: #{webhook_url}"
```

Cloud Platform Specifics:

Platform TELEGEM_WEBHOOK_URL Example
Render https://your-app.onrender.com
Railway https://your-app.railway.app
Heroku https://your-app.herokuapp.com
Fly.io https://your-app.fly.dev

Method 3: Manual Certificate Setup

If you already have SSL certificates:

```ruby
require 'telegem'

bot = Telegem.new(ENV['TELEGRAM_BOT_TOKEN'])

# Provide certificate paths
server = bot.webhook(ssl: {
  cert_path: "/path/to/certificate.pem",
  key_path: "/path/to/private-key.pem"
})

server.set_webhook
```

📡 Webhook Server Methods

Once you have a webhook server instance, you can use these methods:

```ruby
server = bot.webhook  # or bot.webhook(options)

# Start the server (runs in background)
server.run

# Get the webhook URL for Telegram
url = server.webhook_url
# => "https://your-domain.com/webhook/abc123def456"

# Set webhook with Telegram (recommended)
server.set_webhook

# Additional options for set_webhook
server.set_webhook(
  max_connections: 40,
  allowed_updates: ["message", "callback_query"]
)

# Check webhook info from Telegram
info = server.get_webhook_info

# Delete webhook
server.delete_webhook

# Stop the server
server.stop

# Check if server is running
server.running?  # => true/false

# Health check endpoint
# Your server automatically provides: /health
```

🔒 Security: Secret Tokens

Telegem automatically generates and uses secret tokens to prevent unauthorized access:

```ruby
# Auto-generated (recommended)
server = bot.webhook
puts server.secret_token  # => "abc123def456"

# Custom token
server = bot.webhook(secret_token: "my_custom_secret")

# Via environment variable
export WEBHOOK_SECRET_TOKEN=my_custom_secret
```

Webhook URL format:

```
https://your-domain.com/abc123def456
```

Only requests to this exact path will be processed. All other paths return 404.

🏥 Health Monitoring

Your webhook server automatically provides a health endpoint:

```bash
curl https://your-domain.com/health
# Returns: {"status":"ok","mode":"cli","ssl":true}
```

Use this for:

- Platform health checks (Render, Railway)
- Load balancer health checks
- Monitoring and alerts

🔧 Configuration Options

Full list of webhook method options:

```ruby
bot.webhook(
  port: 3000,                    # Port to listen on
  host: '0.0.0.0',               # Host to bind to
  secret_token: nil,             # Custom secret token
  logger: custom_logger,         # Custom logger
  ssl: {                         # SSL options
    cert_path: '/path/to/cert.pem',
    key_path: '/path/to/key.pem'
  }
)
```

🚫 Common Errors & Solutions

Error: "No SSL configured"

Solution: Choose one:

1. Run telegem-ssl your-domain.com (VPS)
2. Set TELEGEM_WEBHOOK_URL environment variable (Cloud)
3. Provide certificate paths manually
4. Use bot.start_polling() instead

Error: "Telegram webhook failed"

Solution:

```ruby
# Check current webhook info
info = server.get_webhook_info
puts info.inspect

# Delete and retry
server.delete_webhook
server.set_webhook
```

Error: "Certificate not found"

Solution:

```bash
# Regenerate certificates
telegem-ssl your-domain.com --force

# Or check file permissions
ls -la /etc/letsencrypt/live/your-domain.com/
```

🔄 Polling vs Webhook

When to use each:

-Use Case Recommended Method
Development/Testing bot.start_polling()
-Production (VPS) bot.webhook() with CLI
-Production (Cloud) bot.webhook() with env var
-Limited Resources bot.start_polling()
-High Traffic bot.webhook()

Polling example (for development):

```ruby
bot.start_polling(
  timeout: 30,
  limit: 100,
  allowed_updates: ["message"]
)
```

📋 Complete Example

VPS Production Setup (bot.rb):

```ruby
#!/usr/bin/env ruby
require 'telegem'

bot = Telegem.new(ENV['TELEGRAM_BOT_TOKEN'])

# Command handlers
bot.command("start") do |ctx|
  ctx.reply("Welcome!")
end

bot.command("help") do |ctx|
  ctx.reply("Available commands: /start, /help")
end

# Start webhook
server = bot.webhook

# Set webhook with Telegram
server.set_webhook(
  max_connections: 40,
  allowed_updates: ["message", "callback_query"]
)

puts "✅ Bot running with webhook: #{server.webhook_url}"
puts "🩺 Health check: #{server.webhook_url.gsub(/\/[^\/]+$/, '/health')}"

# Keep the script running
sleep while true
```

Cloud Platform Setup (bot.rb):

```ruby
#!/usr/bin/env ruby
require 'telegem'

bot = Telegem.new(ENV['TELEGRAM_BOT_TOKEN'])

# Add your command handlers here
bot.command("start") { |ctx| ctx.reply("Hello from cloud!") }

# Start webhook (auto-detects cloud mode)
server = bot.webhook

# Output the webhook URL
puts "Webhook URL: #{server.webhook_url}"

# Keep running
sleep while true
```

🚀 Deployment Checklist

Before deploying to production:

- SSL is configured (CLI, Cloud, or Manual)
- TELEGRAM_BOT_TOKEN is set
- WEBHOOK_SECRET_TOKEN is set (optional but recommended)
- TELEGEM_WEBHOOK_URL is set (for cloud platforms)
-  Port is correctly configured (usually ENV['PORT'] on cloud)
-  Health endpoint is responding (/health)
- Webhook is set with Telegram (server.set_webhook)

📞 Getting Help

If you encounter issues:

1. Check the logs: tail -f log/bot.log
2. Verify SSL: curl https://your-domain.com/health
3. Check Telegram webhook: server.get_webhook_info
4. Enable debug logging: Logger.new($stdout, level: :debug)

For more help, visit the Telegem GitLab repository.

---

Next Steps: After setting up your webhook, learn about Middleware, Scenes, and Advanced Features in the Telegem framework.