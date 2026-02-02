#!/bin/sh

# Check if Let's Encrypt certificates exist, otherwise use self-signed
LETSENCRYPT_CERT="/etc/letsencrypt/live/kushansewmina7-pannel.hf.space/fullchain.pem"
LETSENCRYPT_KEY="/etc/letsencrypt/live/kushansewmina7-pannel.hf.space/privkey.pem"

# Set certificate paths
if [ -f "$LETSENCRYPT_CERT" ] && [ -f "$LETSENCRYPT_KEY" ]; then
    # Use Let's Encrypt certificates
    PUBLIC_KEY_PATH="$LETSENCRYPT_CERT"
    PRIVATE_KEY_PATH="$LETSENCRYPT_KEY"
    echo "Using Let's Encrypt certificates"
    echo "Private Key Path: $PRIVATE_KEY_PATH"
    echo "Public Key Path: $PUBLIC_KEY_PATH"
else
    # Generate self-signed certificates
    SSL_DIR="/etc/x-ui/ssl"
    PRIVATE_KEY_PATH="$SSL_DIR/private.key"
    PUBLIC_KEY_PATH="$SSL_DIR/public.crt"

    mkdir -p $SSL_DIR

    if [ ! -f "$PRIVATE_KEY_PATH" ] || [ ! -f "$PUBLIC_KEY_PATH" ]; then
        echo "Generating self-signed SSL certificates..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$PRIVATE_KEY_PATH" \
            -out "$PUBLIC_KEY_PATH" \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=kushansewmina7-pannel.hf.space"

        if [ $? -eq 0 ]; then
            echo "Self-signed SSL certificates generated successfully"
            echo "Private Key Path: $PRIVATE_KEY_PATH"
            echo "Public Key Path: $PUBLIC_KEY_PATH"
        else
            echo "Failed to generate SSL certificates"
            # Fallback to running without SSL
            PUBLIC_KEY_PATH=""
            PRIVATE_KEY_PATH=""
        fi
    else
        echo "Using existing self-signed SSL certificates"
        echo "Private Key Path: $PRIVATE_KEY_PATH"
        echo "Public Key Path: $PUBLIC_KEY_PATH"
    fi
fi

# Set the certificate paths in the application if they exist
if [ -n "$PUBLIC_KEY_PATH" ] && [ -f "$PUBLIC_KEY_PATH" ] && [ -n "$PRIVATE_KEY_PATH" ] && [ -f "$PRIVATE_KEY_PATH" ]; then
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