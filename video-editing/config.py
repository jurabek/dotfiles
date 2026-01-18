import os

# Paths
RECORDINGS_DIR = os.path.expanduser("~/Videos/Recording")
IMPORT_DIR = os.path.expanduser("~/Videos/Import")

# Silence detection
SILENCE_THRESHOLD_DB = -38
SILENCE_MIN_DURATION = 0.8
SILENCE_START_PAD = 0.05
SILENCE_END_PAD = 0.08

# Bad take detection
BAD_TAKE_PADDING = 2  # seconds
BAD_TAKE_MAX_DISTANCE = 5  # seconds

# Timeline options
# "include" = add silence clips colored orange
# "remove" = skip silence clips entirely
SILENCE_MODE = "include"
