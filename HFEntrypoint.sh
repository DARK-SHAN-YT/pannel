#!/bin/sh

# Set the web panel port to 7860 (required for Hugging Face Spaces)
echo "Setting web panel port to 7860..."
/app/x-ui setting -port 7860

# Set a default username and password (you can customize these)
echo "Setting default username and password..."
/app/x-ui setting -username admin -password admin123

# Start fail2ban if enabled
[ $XUI_ENABLE_FAIL2BAN == "true" ] && fail2ban-client -x start

# Run x-ui
exec /app/x-ui