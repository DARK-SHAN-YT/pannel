#!/bin/sh

# Set the web panel port to 7860 (required for Hugging Face Spaces)
echo "Setting web panel port to 7860..."
/app/x-ui setting -port 7860

# Optionally, also set the subscription server port to 7860 if needed
echo "Setting subscription server port to 7860..."
/app/x-ui setting -subPort 7860

# Start fail2ban if enabled
[ $XUI_ENABLE_FAIL2BAN == "true" ] && fail2ban-client -x start

# Run x-ui
exec /app/x-ui