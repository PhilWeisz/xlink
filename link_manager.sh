#!/bin/bash

# Configuration
CONFIG_FILE="/mnt/sda1/link_config.cfg"
EXTRACT_DIR="./extracted_parts"

# Function: Process Configuration File
process_config() {
    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Error: Configuration file not found at $CONFIG_FILE"
        exit 1
    fi

    echo "Processing configuration file: $CONFIG_FILE"

    # Read each line in the configuration file
    while IFS='=' read -r LHS RHS; do
        # Skip empty lines or comments
        [[ -z "$LHS" || -z "$RHS" || "$LHS" == \#* ]] && continue

        # Expand ~ to the user's home directory
        LHS=$(eval echo "$LHS")
        RHS=$(eval echo "$RHS")

        # Check if the source (LHS) exists
        if [[ ! -e $LHS ]]; then
            echo "Warning: Source $LHS does not exist. Skipping."
            continue
        fi

        # Create parent directories for the destination (RHS) if needed
        mkdir -p "$(dirname "$RHS")"

        # Create the link
        if [[ -d $LHS ]]; then
            ln -sfn "$LHS" "$RHS"
            echo "Linked directory $LHS -> $RHS"
        elif [[ -f $LHS ]]; then
            ln -sf "$LHS" "$RHS"
            echo "Linked file $LHS -> $RHS"
        else
            echo "Error: $LHS is neither a file nor a directory. Skipping."
        fi
    done < "$CONFIG_FILE"

    echo "Link setup complete!"
}

# Function: Save Current Configuration and Data
save_session() {
    SAVE_DIR="/mnt/sda1/saved_sessions"
    mkdir -p "$SAVE_DIR"

    # Determine the next session number
    SESSION_NUM=$(ls "$SAVE_DIR" | grep -E '^session[0-9]+$' | sort -V | tail -n 1 | sed 's/session//')
    SESSION_NUM=$((SESSION_NUM + 1))

    SESSION_DIR="$SAVE_DIR/session$SESSION_NUM"
    mkdir -p "$SESSION_DIR"

    echo "Saving current session to $SESSION_DIR..."

    # Backup home directory
    cp -a "$HOME" "$SESSION_DIR/home"
    echo "Home directory saved to $SESSION_DIR/home"

    # Backup /etc
    cp -a /etc "$SESSION_DIR/etc"
    echo "Configuration files saved to $SESSION_DIR/etc"

    echo "Session saved successfully as $SESSION_DIR"
}

# Function: Extract Script Parts
extract_parts() {
    mkdir -p "$EXTRACT_DIR"

    # Create separate scripts for processing configuration, saving sessions, and extracting
    cat > "$EXTRACT_DIR/process_config.sh" << 'EOF'
#!/bin/bash
# This script processes the configuration file and creates links
CONFIG_FILE="/mnt/sda1/link_config.cfg"
process_config() {
    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Error: Configuration file not found at $CONFIG_FILE"
        exit 1
    fi

    while IFS='=' read -r LHS RHS; do
        [[ -z "$LHS" || -z "$RHS" || "$LHS" == \#* ]] && continue
        LHS=$(eval echo "$LHS")
        RHS=$(eval echo "$RHS")
        mkdir -p "$(dirname "$RHS")"
        if [[ -d $LHS ]]; then ln -sfn "$LHS" "$RHS"
        elif [[ -f $LHS ]]; then ln -sf "$LHS" "$RHS"; fi
    done < "$CONFIG_FILE"
}
process_config
EOF

    cat > "$EXTRACT_DIR/save_session.sh" << 'EOF'
#!/bin/bash
# This script saves the current session
SAVE_DIR="/mnt/sda1/saved_sessions"
mkdir -p "$SAVE_DIR"
SESSION_NUM=$(ls "$SAVE_DIR" | grep -E '^session[0-9]+$' | sort -V | tail -n 1 | sed 's/session//')
SESSION_NUM=$((SESSION_NUM + 1))
SESSION_DIR="$SAVE_DIR/session$SESSION_NUM"
mkdir -p "$SESSION_DIR"
cp -a "$HOME" "$SESSION_DIR/home"
cp -a /etc "$SESSION_DIR/etc"
echo "Session saved as $SESSION_DIR"
EOF

    cat > "$EXTRACT_DIR/extract_parts.sh" << 'EOF'
#!/bin/bash
# This script extracts parts of itself into separate scripts
EXTRACT_DIR="./extracted_parts"
mkdir -p "$EXTRACT_DIR"
# (This script would contain its own implementation for extraction)
echo "Scripts extracted to $EXTRACT_DIR"
EOF

    chmod +x "$EXTRACT_DIR"/*.sh
    echo "Scripts extracted to $EXTRACT_DIR"
}

# Main Menu
case "$1" in
    process)
        process_config
        ;;
    save)
        save_session
        ;;
    extract)
        extract_parts
        ;;
    *)
        echo "Usage: $0 {process|save|extract}"
        echo "  process  - Process the configuration file and create links"
        echo "  save     - Save current session data"
        echo "  extract  - Extract parts of this script into separate files"
        exit 1
        ;;
esac
