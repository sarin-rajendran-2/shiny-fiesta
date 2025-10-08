#!/usr/bin/env bash

ENV_FILE="/workspace/.devcontainer/.env"
ENV_EXAMPLE="/workspace/.devcontainer/.env.example"

# Color definitions
reset=$'\033[0m'
bold=$'\033[1m'
dim=$'\033[2m'
blue=$'\033[34m'
green=$'\033[32m'
yellow=$'\033[33m'
cyan=$'\033[36m'
gray=$'\033[90m'

# Icons
icon_info="ℹ️ "
icon_warning="⚠️ "
icon_success="✨"
icon_error="❌"
icon_prompt="❯"
icon_key="🔑"
icon_db="🗃️ "
icon_web="🌐"
icon_book="📚"
icon_gear="⚙️ "
icon_lock="🔒"

# Function to show styled section header with caption
print_header() {
    local icon="$1"
    local text="$2"
    printf "\n%s" "${bold}${blue}$icon $text${reset}"
}

# Function to show description
print_description() {
    printf "%s\n" "${dim}${icon_info}$1${reset}"
}

# Function to show setting description
print_setting() {
    local description="$1"
    # Print description without leading blank line so prompts appear consecutively
    printf "%s\n" "${blue}$description${reset}"
    printf "%s\n" "${gray}────────────────────────────────────────${reset}"
}

# Function to prompt for value with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local description="$3"
    local value
    # Show the prompt on the terminal and read from /dev/tty so the prompt is visible
    {
        print_setting "$description"
        printf "%s" "${cyan}?${reset} ${bold}Enter ${prompt}${reset} ${dim}($default):${reset} "
    } > /dev/tty

    read -r value < /dev/tty

    # Use default if empty
    value=${value:-$default}

    # Return the value
    printf "%s" "$value"
}

# Function to prompt for password with auto-generation option
prompt_for_password() {
    local prompt="$1"
    local var_name="$2"
    local description="$3"
    local value
    
    # Show the prompt on the terminal
    {
        print_setting "$description"
        printf "${cyan}?${reset} ${bold}Enter ${prompt}${reset} ${dim}(press Enter to auto-generate):${reset} "
    } > /dev/tty
    
    # Read password from terminal without echo
    read -s value < /dev/tty
    printf "\n" > /dev/tty
    
    if [ -z "$value" ]; then
        value=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()' | head -c 16)
        generated_values[$var_name]=$value
    fi
    
    # Output the value to stdout for capture
    printf "%s" "$value"
}

# Function to validate email
validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        printf "%s\n" "${yellow}${icon_warning} Invalid email format${reset}" >&2
        return 1
    fi
    return 0
}

# Function to prompt for email
prompt_for_email() {
    local prompt="$1"
    local default="$2"
    local description="$3"
    local email
    
    # Prompt once (no validation per user request)
    {
        print_setting "$description"
        printf "%s" "${cyan}?${reset} ${bold}Enter ${prompt}${reset} ${dim}($default):${reset} " 
    } > /dev/tty
    
    read -r email < /dev/tty
    email=${email:-$default}
    printf "%s" "$email"
}

# Print welcome message
clear
printf "%s\n" "${bold}${green}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
printf "%s\n" "${bold}${green}┃    Environment Configuration Setup    ┃${reset}"
printf "%s\n" "${bold}${green}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"

# Print all instructions upfront
cat << INSTRUCTIONS
${blue}This utility will configure your development environment.${reset}

${bold}Instructions:${reset}
${icon_prompt} Each prompt will show a description and default value
${icon_prompt} Press ${cyan}Enter${reset} to accept the default value
${icon_prompt} For passwords, press ${cyan}Enter${reset} to auto-generate a secure value
${icon_prompt} Press ${cyan}Ctrl+C${reset} to cancel at any time

${yellow}We'll ask for:${reset}
• Project name for Docker Compose
• Database credentials (username/password)
• pgAdmin access (email/password)
• Livebook authentication token
• Application secrets

${blue}All values can be changed later by editing ${cyan}.env${blue} file.${reset}
INSTRUCTIONS

# Function to generate a secure password
generate_password() {
    # Generate a password with 16 characters including uppercase, lowercase, numbers, and symbols
    openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()' | head -c 16
}

# Function to prompt for value with optional auto-generation
prompt_with_generate() {
    local prompt="$1"
    local var_name="$2"
    local value
    
    read -p "$prompt" value
    if [ -z "$value" ]; then
        value=$(generate_password)
        echo "Generated $var_name: $value"
    fi
    echo "$var_name=$value" >> "$ENV_FILE"
}

# Array to store generated values
declare -A generated_values

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    printf "%s\n" "${yellow}${icon_warning} No .env file found. Creating a new one...${reset}"
    
    # Project Configuration
    print_description "Let's start by setting up the basic project information."
    
    COMPOSE_PROJECT_NAME=$(prompt_with_default "project name" "shiny-fiesta" "Project name used by Docker Compose")
    printf "%s\n" "${dim}Using project name: ${reset}${bold}$COMPOSE_PROJECT_NAME${reset}"
    
    # Initialize the .env file with project configuration
    cat > "$ENV_FILE" << EOL
# Docker Compose Configuration
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME

# ==============================================
# Application Secrets
# ==============================================
EOL
    
    # Database Configuration
    postgres_user=""
    while [ -z "$postgres_user" ]; do
    postgres_user=$(prompt_with_default "database username" "postgres" "Database username")
    done
    echo "POSTGRES_USER=$postgres_user" >> "$ENV_FILE"
    
    postgres_pass=""
    while [ -z "$postgres_pass" ]; do
    postgres_pass=$(prompt_for_password "database password" "POSTGRES_PASSWORD" "Database password (Enter to auto-generate)")
    done
    echo
    echo "POSTGRES_PASSWORD=$postgres_pass" >> "$ENV_FILE"
    
    # pgAdmin Configuration
    
    # Email input (no validation)
    pgadmin_email=$(prompt_for_email "admin email" "admin@example.com" "pgAdmin login email")
    echo "${dim}Using pgAdmin email: ${reset}${bold}$pgadmin_email${reset}" > /dev/tty
    echo "PGADMIN_DEFAULT_EMAIL=$pgadmin_email" >> "$ENV_FILE"
    
    # Password input
    pgadmin_pass=$(prompt_for_password "admin password" "PGADMIN_DEFAULT_PASSWORD" "pgAdmin password (Enter to auto-generate)")
    echo "PGADMIN_DEFAULT_PASSWORD=$pgadmin_pass" >> "$ENV_FILE"
    printf "\n" > /dev/tty
    
    # Livebook
    print_description "Livebook settings"

    livebook_token=$(prompt_for_password "auth token" "LIVEBOOK_TOKEN" "Livebook auth token (Enter to auto-generate)")
    echo "LIVEBOOK_TOKEN=$livebook_token" >> "$ENV_FILE"
    printf "\n" > /dev/tty
    
    # Application Security
    print_description "Phoenix application security settings."
    
    # Generate RELEASE_COOKIE
    release_cookie=$(openssl rand -hex 16)
    generated_values["RELEASE_COOKIE"]=$release_cookie
    echo "RELEASE_COOKIE=$release_cookie" >> "$ENV_FILE"
    
    # Generate SECRET_KEY_BASE
    secret_key_base=$(openssl rand -base64 48)
    generated_values["SECRET_KEY_BASE"]=$secret_key_base
    echo "SECRET_KEY_BASE=$secret_key_base" >> "$ENV_FILE"
    
    # Print summary of all generated values
    printf "%s\n" "${yellow}Generated Values:${reset}"
    printf "%s\n" "${dim}────────────────────────────────────────${reset}"
    for key in "${!generated_values[@]}"; do
        printf "${cyan}%-20s${reset} %s\n" "$key" "${generated_values[$key]}"
    done
    printf "%s\n" "${dim}────────────────────────────────────────${reset}"
    
    echo "" >> "$ENV_FILE"
    echo "# ==============================================" >> "$ENV_FILE"
    echo "# Configuration Values" >> "$ENV_FILE"
    echo "# ==============================================" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
    
    # Add non-secret configuration values
    echo "# Database Configuration" >> "$ENV_FILE"
    echo "POSTGRES_DB=exins_dev" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
    echo "# Service Ports" >> "$ENV_FILE"
    echo "PGADMIN_LISTEN_PORT=5050" >> "$ENV_FILE"
    echo "LIVEBOOK_PORT=8080" >> "$ENV_FILE"
    echo "PORT=4000" >> "$ENV_FILE"
    echo "" >> "$ENV_FILE"
    echo "# Application Settings" >> "$ENV_FILE"
    echo "PHX_HOST=localhost" >> "$ENV_FILE"
    
    printf "%s\n" "${bold}${green}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
    printf "%s\n" "${bold}${green}┃         Setup Complete! ${icon_success}         ┃${reset}"
    printf "%s\n" "${bold}${green}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
    
    print_description "Environment configuration has been saved to:
${cyan}$ENV_FILE${reset}

${dim}Note: Development defaults from .env.dev are used until this file is created.${reset}

${bold}Summary of actions:${reset}
${green}✓${reset} Created .env file with configuration values
${green}✓${reset} Set database credentials ${icon_db}
${green}✓${reset} Configured pgAdmin access ${icon_web}
${green}✓${reset} Generated Livebook authentication token ${icon_book}
${green}✓${reset} Generated application secrets ${icon_key}

You can modify these values anytime by editing ${cyan}$ENV_FILE${reset}"
else
    echo ".env file already exists at: $ENV_FILE"
    echo "If you need to regenerate it, delete the existing file and run this script again."
fi

