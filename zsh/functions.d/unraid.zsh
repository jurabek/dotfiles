# Unraid helper functions

# Wake up Unraid server via WOL endpoint
unraid-wake() {
  echo "Waking up Unraid server..."
  curl -s https://wol.home.jurabek.dev/
  echo "WOL signal sent"
}
