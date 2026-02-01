#!/bin/sh

# Generate SSL certificates if they don't exist
SSL_DIR="/etc/x-ui/ssl"
PRIVATE_KEY_PATH="$SSL_DIR/private.key"
PUBLIC_KEY_PATH="$SSL_DIR/public.crt"

mkdir -p $SSL_DIR

if [ ! -f "$PRIVATE_KEY_PATH" ] || [ ! -f "$PUBLIC_KEY_PATH" ]; then
    echo "Generating SSL certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$PRIVATE_KEY_PATH" \
        -out "$PUBLIC_KEY_PATH" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

    if [ $? -eq 0 ]; then
        echo "SSL certificates generated successfully"
        echo "Private Key Path: $PRIVATE_KEY_PATH"
        echo "Public Key Path: $PUBLIC_KEY_PATH"

        # Set the certificate paths in the application
        /app/x-ui setting -webCert "$PUBLIC_KEY_PATH" -webCertKey "$PRIVATE_KEY_PATH"
    else
        echo "Failed to generate SSL certificates"
    fi
else
    echo "Using existing SSL certificates"
    echo "Private Key Path: $PRIVATE_KEY_PATH"
    echo "Public Key Path: $PUBLIC_KEY_PATH"

    # Set the certificate paths in the application
    /app/x-ui setting -webCert "$PUBLIC_KEY_PATH" -webCertKey "$PRIVATE_KEY_PATH"
fi

# Set the web panel port to 7860 (required for Hugging Face Spaces)
echo "Setting web panel port to 7860..."
/app/x-ui setting -port 7860

# Set a default username and password (you can customize these)
echo "Setting default username and password..."
/app/x-ui setting -username admin -password admin123

# Wait a moment for settings to be applied
sleep 2

# Start fail2ban if enabled
[ $XUI_ENABLE_FAIL2BAN == "true" ] && fail2ban-client -x start

# Run x-ui
exec /app/x-ui