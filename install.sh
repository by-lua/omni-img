#!/usr/bin/env bash
# Install script for omni-img
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR/omni_img"

if [ -w /usr/local/bin ]; then
    cp "$SCRIPT_DIR/omni_img" /usr/local/bin/omni-img
    echo "OK: instalado em /usr/local/bin/omni-img"
else
    sudo cp "$SCRIPT_DIR/omni_img" /usr/local/bin/omni-img
    echo "OK: instalado em /usr/local/bin/omni-img (com sudo)"
fi

echo ""
echo "Proximos passos:"
echo "  omni-img config https://sua-ominiroute.com.br sk-xxx"
echo "  omni-img models"
echo "  omni-img pick"
echo "  omni-img test"
