# Create named session
tmux new-session -s myproject

# Attach to session
tmux attach -t myproject

# List all sessions
tmux ls

# Smart attach-or-create
tmux new -A -s dev