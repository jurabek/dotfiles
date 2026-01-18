#!/bin/bash
set -e

cd "$(dirname "$0")"

# Create venv if not exists
[ -d .venv ] || python -m venv .venv
source .venv/bin/activate

mkdir -p ~/tmp

echo "Installing torch..."
TMPDIR=~/tmp pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/rocm7.1

echo "Installing torchvision torchaudio..."
TMPDIR=~/tmp pip install --pre torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm7.1

echo "Installing whisper..."
pip install openai-whisper


echo ""
echo "Setup complete. Test with:"
echo "  source .venv/bin/activate"
echo "  python test_rocm.py"
