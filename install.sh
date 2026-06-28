#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo; ui_note "Installation cancelled."; exit 130' INT

# --------------------------------------------------
# Theme
# --------------------------------------------------

THEME_PURPLE="#a78bfa"
THEME_BLUE="#7dd3fc"
THEME_NOTE="#93c5fd"
THEME_GREEN="#86efac"
THEME_YELLOW="#fbbf24"
THEME_RED="#f87171"
THEME_MUTED="#94a3b8"
THEME_WHITE="#ffffff"
THEME_BORDER_DIM="#475569"

TOTAL_STEPS=14

init_theme() {
  export GUM_CHOOSE_CURSOR_FOREGROUND="$THEME_PURPLE"
  export GUM_CHOOSE_HEADER_FOREGROUND="$THEME_BLUE"
  export GUM_CHOOSE_SELECTED_FOREGROUND="$THEME_GREEN"

  export GUM_CONFIRM_PROMPT_FOREGROUND="$THEME_PURPLE"
  export GUM_CONFIRM_SELECTED_FOREGROUND="$THEME_GREEN"
  export GUM_CONFIRM_UNSELECTED_FOREGROUND="$THEME_MUTED"

  export GUM_INPUT_HEADER_FOREGROUND="$THEME_BLUE"
  export GUM_INPUT_PROMPT_FOREGROUND="$THEME_PURPLE"
  export GUM_INPUT_CURSOR_FOREGROUND="$THEME_PURPLE"
  export GUM_INPUT_PLACEHOLDER_FOREGROUND="$THEME_MUTED"

  export GUM_FILTER_HEADER_FOREGROUND="$THEME_BLUE"
  export GUM_FILTER_CURSOR_FOREGROUND="$THEME_PURPLE"
  export GUM_FILTER_MATCH_FOREGROUND="$THEME_GREEN"

  export GUM_SPIN_SPINNER_FOREGROUND="$THEME_PURPLE"
  export GUM_SPIN_TITLE_FOREGROUND="$THEME_BLUE"
}

step_label() {
  local current="$1"
  local label="$2"
  printf "Step %s of %s · %s" "$current" "$TOTAL_STEPS" "$label"
}

ui_main_header() {
  local step="$1"
  local header

  clear

  header="$(printf "Linux Game Box Installer\n%s" "$step")"

  gum style \
    --foreground "$THEME_WHITE" \
    --border-foreground "$THEME_PURPLE" \
    --border double \
    --bold \
    --align center \
    --width 70 \
    --margin "1 2 0 2" \
    "$header"

  echo
}

ui_page_header() {
  gum style \
    --foreground "$THEME_PURPLE" \
    --bold \
    --width 70 \
    --margin "0 3 1 3" \
    "$1"
}

ui_section_header() {
  gum style \
    --foreground "$THEME_BLUE" \
    --bold \
    --margin "0 3" \
    --width 70 \
    "$1"
}

ui_text() {
  gum style \
    --foreground "$THEME_BLUE" \
    --width 70 \
    --margin "0 3" \
    "$1"
}

ui_box() {
  gum style \
    --foreground "$THEME_WHITE" \
    --border-foreground "$THEME_PURPLE" \
    --border rounded \
    --width 70 \
    --margin "0 2" \
    --padding "1 2" \
    "$1"
}

ui_note() {
  gum style \
    --foreground "$THEME_NOTE" \
    --width 70 \
    --margin "0 3 1 3" \
    "$1"
}

ui_current_values_box() {
  gum style \
    --foreground "$THEME_NOTE" \
    --border-foreground "$THEME_NOTE" \
    --border normal \
    --width 70 \
    --padding "1 1" \
    --margin "0 2 1 2" \
    "$1"
}

ui_note_box() {
  gum style \
    --foreground "$THEME_NOTE" \
    --border-foreground "$THEME_NOTE" \
    --border rounded \
    --margin "1 2" \
    --padding "1 2" \
    "$1"
}

ui_help() {
  gum style \
    --foreground "$THEME_MUTED" \
    --width 70 \
    --margin "0 3"\
    "$1"
}

ui_info_box() {
  gum style \
    --foreground "$THEME_BLUE" \
    --border-foreground "$THEME_BORDER_DIM" \
    --border rounded \
    --margin "1 2" \
    --padding "1 2" \
    "$1"
}

ui_summary_box() {
  local width="$1"
  local borderType="$2"
  local text="$3"

  local rightMargin=$(( (70 - width) / 2 ))
  local leftMargin=$(( rightMargin + 2 ))

  gum style \
    --foreground "$THEME_BLUE" \
    --border-foreground "$THEME_BLUE" \
    --border $borderType \
    --width "$width" \
    --margin "0 $rightMargin 1 $leftMargin" \
    --padding "1 2" \
    "$text"
}


ui_danger_box() {
  local width="$1"
  local borderType="$2"
  local text="$3"

  local rightMargin=$(( (70 - width) / 2 ))
  local leftMargin=$(( rightMargin + 2 ))

  gum style \
    --foreground "$THEME_RED" \
    --border-foreground "$THEME_RED" \
    --border $borderType \
    --width "$width" \
    --bold \
    --margin "0 $rightMargin 1 $leftMargin" \
    --padding "1 2" \
    "$text"
}

ui_success() {
  gum style \
    --foreground "$THEME_GREEN" \
    --border-foreground "$THEME_GREEN" \
    --bold \
    --margin "0 3 1 3" \
    "$1"
}

ui_warn() {
  gum style \
    --foreground "$THEME_RED" \
    --border-foreground "$THEME_RED" \
    --bold \
    --align center \
    --width 70 \
    --border normal \
    --margin "0 2" \
    --padding "0 1" \
    "$1"
}

ui_error() {
  gum style \
    --foreground "$THEME_RED" \
    --bold \
    "$1"
}

ui_divider() {
  gum style \
    --foreground "$THEME_BORDER_DIM" \
    "────────────────────────────────────────────────────────────"
}

ui_confirm() {
  local prompt="$1"
  gum confirm --padding "0 2" "$prompt"
}

ui_confirm_danger() {
  local prompt="$1"
  gum confirm --padding "0 2" "$prompt"
}

run_step() {
  local title="$1"
  shift
  gum spin --spinner minidot --padding "0 2 0 0" --title "$title" -- "$@"
}

# --------------------------------------------------
# Initial system state
# --------------------------------------------------
UEFI_SUPPORT=false
BT_SUPPORT=false
CPU_TYPE=""
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

KEYMAP=""
PRIMARY_LOCALE=""
ENABLED_LOCALES=()
TIME_ZONE=""
UTC_TIME=""
HOST_NAME=""

ADMIN_USER=""
ADMIN_FULL_NAME=""
ADMIN_PW=""

RUNTIME_USER=""
RUNTIME_PW=""

ROOT_PW=""

DISK=""
PARTITION_PREFIX=""
BOOT_PARTITION=""
ROOT_PARTITION=""
ROOT_FS="ext4"

UPDATE_MIRRORS=true
MIRROR_COUNTRY="Worldwide"

GPU_TYPE=""

SYSTEM_PACKAGES=()
CORE_PACKAGES=()
CORE_AUR_PACKAGES=()
STEAM_PACKAGES=()
INSTALL_STEAM=false
ENABLE_MULTILIB=false

BASE_PACKAGES=(
  'base'
  'base-devel'
  'linux'
  'linux-firmware'
  'networkmanager'
  'iw'
  'iputils'
  'pacman-contrib'
  'bash-completion'
  'tree'
  'sudo'
  'nano'
  'vim'
  'e2fsprogs'
  'fastfetch'
  'openssh'
  'wget'
  'man-db'
  'man-pages'
  'texinfo'
  'git'
  'ufw'
  'rsync'
  'p7zip'
  'pipewire'
  'pipewire-pulse'
  'pipewire-jack'
  'wireplumber'
  'wayland'
  'xorg-xwayland'
  'sway'
  'ttf-roboto'
  'libinput'
  'joyutils'
  'smbclient'
  'libva-utils'
  'vulkan-icd-loader'
  'vulkan-tools'
  'retroarch'
  'retroarch-assets-ozone'
  'retroarch-assets-xmb'
  'libretro-core-info'
  'libretro-shaders-slang'
  'libretro-overlays'
)

ENABLE_SSH=false
ENABLE_UFW=false


# --------------------------------------------------
# Helper functions
# --------------------------------------------------
detect_system_capabilities() {
  if [[ -d /sys/firmware/efi ]]; then
    UEFI_SUPPORT=true
  fi

  if dmesg 2>/dev/null | grep -iq "bluetooth"; then
    BT_SUPPORT=true
  fi

  local cpu_vendor
  cpu_vendor="$(lscpu | awk -F: '/Vendor ID:/ {gsub(/^[ \t]+/, "", $2); print $2}')"

  case "$cpu_vendor" in
    AuthenticAMD|AMD)
      CPU_TYPE="amd"
      ;;
    GenuineIntel|Intel)
      CPU_TYPE="intel"
      ;;
    *)
      ui_error "Unsupported CPU vendor detected: ${cpu_vendor:-unknown}"
      ui_note "This installer only supports only Intel and AMD systems."
      exit 1 
      ;;
  esac
}

prompt_username() {
  local __var_name="$1"
  local label="$2"
  local current_value="${3:-}"
  local disallowed_value="${4:-}"
  local input
  local reserved_file="$SCRIPT_DIR/config/reserved_usernames"

  while true; do
    ui_main_header "$(step_label 7 "Account Configuration")"

    ui_page_header "Configure the administrator account, the runtime gaming account, and the root password"
    ui_page_header "Administrator account: used for SSH, sudo, and maintenance tasks"
    ui_page_header "Runtime account: used for auto-login and running the gaming environment"

    if [[ -n "$current_value" ]]; then
      ui_note "Current value: $current_value"
      echo
    fi

    input="$(gum input \
      --header "Enter a username for the ${label}:" \
      --padding "0 3" \
      --value "$current_value" \
      --placeholder ""
    )"

    if [[ -z "${input:-}" ]]; then
      ui_warn "Username cannot be empty."
      sleep 3
      continue
    fi

    if ! [[ "$input" =~ ^[a-z][a-z0-9-]{0,31}$ ]]; then
      ui_danger_box 36 double "Invalid username format.

A username must:
- begin with a lowercase letter
- contain only lowercase letters, numbers, or dashes
- be no more than 32 characters long"
      sleep 5
      continue
    fi

    if [[ -f "$reserved_file" ]] && grep -Fxq "$input" "$reserved_file"; then
      ui_danger_box 36 double "The username \"$input\" is reserved for system use. Please choose a different username."
      sleep 3
      continue
    fi

    if [[ -n "$disallowed_value" && "$input" == "$disallowed_value" ]]; then
      ui_danger_box 36 double "This username must be different from \"$disallowed_value\"."
      sleep 3
      continue
    fi

    printf -v "$__var_name" '%s' "$input"
    return 0
  done
}

prompt_password() {
  local __var_name="$1"
  local account_label="$2"
  local pw1
  local pw2

  while true; do
    ui_main_header "$(step_label 7 "Account Configuration")"

    pw1="$(gum input \
      --header "Enter a password for the ${account_label}:" \
      --padding "0 3" \
      --password \
      --placeholder ""
    )"

    if [[ -z "${pw1:-}" ]]; then
      ui_warn "Password cannot be empty."
      sleep 3
      continue
    fi

    ui_main_header "$(step_label 7 "Account Configuration")"

    pw2="$(gum input \
      --header "Confirm the password for the ${account_label}:" \
      --padding "0 3" \
      --password \
      --placeholder ""
    )"

    if [[ "$pw1" != "$pw2" ]]; then
      ui_danger_box 36 double "Passwords did not match. Please try again."
      sleep 3
      continue
    fi

    printf -v "$__var_name" '%s' "$pw1"
    return 0
  done
}

dedupe_array() {
  local -n arr_ref="$1"
  local -a deduped=()
  local item

  for item in "${arr_ref[@]}"; do
    [[ -n "$item" ]] || continue
    if [[ ! " ${deduped[*]} " =~ [[:space:]]${item}[[:space:]] ]]; then
      deduped+=("$item")
    fi
  done

  arr_ref=("${deduped[@]}")
}




# --------------------------------------------------
# Installer screens
# -------------------------------------------------- 
welcome() {
  ui_main_header "$(step_label 1 "Welcome")"

  ui_page_header "Welcome to the installation wizard for your standalone Retro Gaming Box. This script will guide you through system setup step by step."

  ui_section_header "Navigation"
  ui_text "• Use the arrow keys to move through menus"
  ui_text "• Press Enter to confirm a selection"
  ui_text "• Some menus allow multiple selections"
  echo

  ui_warn "This installer formats disks and overwrites system settings. Review each choice carefully before continuing!"
  echo

  if ! ui_confirm "Start the installer?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

preflight_checks() {
  local boot_mode
  local bluetooth_status

  if [[ "$UEFI_SUPPORT" == true ]]; then
    boot_mode="UEFI"
  else
    boot_mode="BIOS"
  fi

  if [[ "$BT_SUPPORT" == true ]]; then
    bluetooth_status="Detected"
  else
    bluetooth_status="Not detected"
  fi

  ui_main_header "$(step_label 2 "Preflight Checks")"

  ui_page_header "The installer will now verify network access and show the detected system environment before continuing."

  ui_summary_box 36 thick "Detected system state

Boot mode         : $boot_mode
CPU type          : $CPU_TYPE
Bluetooth support : $bluetooth_status"

  ui_section_header "Network Check"

  if ! run_step "Checking internet connectivity..." bash -c '
    curl --silent --fail --max-time 5 https://archlinux.org >/dev/null
  '; then
    echo
    ui_danger_box 36 double "No working internet connection was detected.

Ensure your ethernet cable is securely connected.

If you are using Wi-Fi, connect first using:
iwctl

After correcting the connection issue, run the installer again."
    exit 1
  fi

  echo
  ui_success "Internet connectivity check passed."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

set_keymap() {
  : "${KEYMAP:=us}"

  local selection
  local selected_keymap

  while true; do
    ui_main_header "$(step_label 3 "Keyboard Layout")"

    ui_page_header "Select the keyboard layout to use for the installed system."

    selection="$(gum choose \
      --header "Choose Layout (Current: $KEYMAP)" \
      --padding "0 3" \
      "us - US English" \
      "uk - UK English" \
      "ca - Canadian Multilingual" \
      "fr - French" \
      "de - German" \
      "gr - Greek" \
      "it - Italian" \
      "pl - Polish" \
      "ru - Russian" \
      "other - Browse all available layouts")"

    if [[ "$selection" == "other - Browse all available layouts" ]]; then
      ui_main_header "$(step_label 3 "Keyboard Layout")"
      ui_page_header "Search and select a keyboard layout from the full system list."

      selected_keymap="$(localectl list-keymaps | gum filter --placeholder "Type to search keymaps...")"

      if [[ -z "${selected_keymap:-}" ]]; then
        continue
      fi
    else
      selected_keymap="${selection%% -*}"
    fi

    ui_summary_box 36 thick "Selected keymap: $selected_keymap"

    if ui_confirm "Use this keyboard layout?"; then
      KEYMAP="$selected_keymap"
      break
    fi
  done

  echo
  ui_success "Keyboard layout saved as $KEYMAP."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

set_locale() {
  : "${PRIMARY_LOCALE:=en_US.UTF-8}"

  if [[ ${#ENABLED_LOCALES[@]} -eq 0 ]]; then
    ENABLED_LOCALES=("en_US.UTF-8")
  fi

  local selection
  local primary_choice
  local locale_list
  local -a selected_locales
  local -a common_locales
  local -a extra_locales
  local -a all_locales

  while true; do
    ui_main_header "$(step_label 4 "Locale Settings")"

    ui_page_header "Press 'x' to select one or more locales to generate for the installed system, then choose which one should be the primary system locale."

    ui_text "Currently enabled locales: $(IFS=', '; echo "${ENABLED_LOCALES[*]}")"
    ui_text "Current primary locale: $PRIMARY_LOCALE"
    echo

    selection="$(gum choose --no-limit \
      --header "Choose locale:" \
      --padding "0 3" \
      "en_US.UTF-8 - English (United States)" \
      "en_CA.UTF-8 - English (Canada)" \
      "zh_CN.UTF-8 - Chinese (Simplified)" \
      "zh_TW.UTF-8 - Chinese (Taiwan)" \
      "fr_FR.UTF-8 - French (France)" \
      "de_DE.UTF-8 - German (Germany)" \
      "ja_JP.UTF-8 - Japanese (Japan)" \
      "ko_KR.UTF-8 - Korean (Korea)" \
      "ru_RU.UTF-8 - Russian (Russia)" \
      "other - Browse all available locales")"

    if [[ -z "${selection:-}" ]]; then
      ui_warn "No locales selected. Press x to mark one or more locales, then press Enter."
      sleep 3
      continue
    fi

    common_locales=()
    extra_locales=()

    if grep -qx "other - Browse all available locales" <<< "$selection"; then
      mapfile -t all_locales < <(
        grep -E '^#?[a-z].*UTF-8' /etc/locale.gen \
          | sed -e 's/^#//' -e 's/[[:space:]].*$//' \
          | sort -u
      )

      mapfile -t common_locales < <(
        printf '%s\n' "$selection" \
          | sed '/^other - Browse all available locales$/d' \
          | sed 's/ - .*//'
      )

      ui_main_header "$(step_label 4 "Locale Settings")"

      selection="$(printf '%s\n' "${all_locales[@]}" | gum filter \
        --no-limit \
        --header "Select additional locales · Type to filter · Tab to select · Enter to confirm" \
        --placeholder "Type to search locales...")"

      if [[ -z "${selection:-}" && ${#common_locales[@]} -eq 0 ]]; then
        ui_warn "No locales selected. Type to search, press Tab to mark one or more locales, then press Enter."
        sleep 3
        continue
      fi

      if [[ -n "${selection:-}" ]]; then
        mapfile -t extra_locales <<< "$selection"
      fi

      mapfile -t selected_locales < <(
        printf '%s\n' "${common_locales[@]}" "${extra_locales[@]}" | awk 'NF && !seen[$0]++'
      )
    else
      mapfile -t selected_locales < <(
        printf '%s\n' "$selection" | sed 's/ - .*//'
      )
    fi

    if [[ ${#selected_locales[@]} -eq 0 ]]; then
      continue
    fi

    ui_main_header "$(step_label 4 "Locale Settings")"

    primary_choice="$(printf '%s\n' "${selected_locales[@]}" | \
      gum choose \
      --header "Choose which locale should be the primary system locale:" \
      --padding "0 3" \
      )"

    if [[ -z "${primary_choice:-}" ]]; then
      continue
    fi

    locale_list="$(IFS=', '; echo "${selected_locales[*]}")"

    ui_summary_box 36 thick "Selected locale configuration

Primary locale: $primary_choice

Enabled locales: 
$locale_list"

    if ui_confirm "Use these locale settings?"; then
      PRIMARY_LOCALE="$primary_choice"
      ENABLED_LOCALES=("${selected_locales[@]}")
      break
    fi
  done

  echo
  ui_success "Primary locale set to $PRIMARY_LOCALE."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

set_timezone() {
  : "${TIME_ZONE:=UTC}"
  : "${UTC_TIME:=true}"

  local selection
  local utc_choice
  local -a all_timezones

  while true; do
    ui_main_header "$(step_label 5 "Time Zone")"

    ui_page_header "Select the time zone for the installed system, then choose whether the hardware clock should use UTC."

    ui_current_values_box "Current time zone: $TIME_ZONE
Hardware clock uses UTC: $UTC_TIME"
    echo

    selection="$(gum choose \
      --header "Choose a time zone:" \
      --padding "0 3" \
      "UTC - Coordinated Universal Time" \
      "America/Halifax - Atlantic Time" \
      "America/New_York - Eastern Time" \
      "America/Chicago - Central Time" \
      "America/Denver - Mountain Time" \
      "America/Los_Angeles - Pacific Time" \
      "other - Browse all available time zones")"

    if [[ "$selection" == "other - Browse all available time zones" ]]; then
      mapfile -t all_timezones < <(
        find /usr/share/zoneinfo \
          -type f \
          ! -path '*/posix/*' \
          ! -path '*/right/*' \
          ! -name 'iso3166.tab' \
          ! -name 'leapseconds' \
          ! -name 'leapseconds.list' \
          ! -name 'posixrules' \
          ! -name 'tzdata.zi' \
          ! -name 'zone.tab' \
          ! -name 'zone1970.tab' \
          -printf '%P\n' \
          | sort
      )

      ui_main_header "$(step_label 5 "Time Zone")"

      selection="$(printf '%s\n' "${all_timezones[@]}" | gum filter \
        --header "Select a timezone (type to filter)" \
        --placeholder "Type to search time zones...")"

      if [[ -z "${selection:-}" ]]; then
        continue
      fi
    else
      selection="${selection%% -*}"
    fi

    ui_main_header "$(step_label 5 "Time Zone")"

    if ui_confirm "Use UTC for the hardware clock?"; then
      utc_choice=true
    else
      utc_choice=false
    fi

    ui_summary_box 36 thick "Selected time settings

Time zone: $selection

Hardware clock UTC: $utc_choice"

    if ui_confirm "Use these time settings?"; then
      TIME_ZONE="$selection"
      UTC_TIME="$utc_choice"
      break
    fi
  done

  echo
  ui_success "Time settings saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

set_hostname() {
  : "${HOST_NAME:=retrobox}"

  local input

  while true; do
    ui_main_header "$(step_label 6 "Hostname")"

    ui_page_header "Enter the hostname for the installed system."

    ui_note "Current hostname: $HOST_NAME"
    echo

    input="$(gum input \
      --padding "0 3" \
      --value "$HOST_NAME" \
      --placeholder "Enter hostname")"

    if [[ -z "${input:-}" ]]; then
      ui_warn "Hostname cannot be empty."
      ui_text "Press enter to try again"

      read -r -s _
      continue
    fi

    if [[ ${#input} -le 63 ]] \
      && [[ "$input" =~ ^[a-zA-Z0-9-]+$ ]] \
      && [[ "${input:0:1}" != "-" ]] \
      && [[ "${input: -1}" != "-" ]]; then

      ui_summary_box 42 thick "Selected hostname: $input"

      if ui_confirm "Use this hostname?"; then
        HOST_NAME="$input"
        break
      fi
    else
      ui_danger_box 36 double "Invalid hostname format.

A hostname must:
- be between 1 and 63 characters
- contain only letters, numbers, or dashes
- not begin with a dash
- not end with a dash"

      ui_text "Press enter to try again"
      read -r -s _

      continue
    fi
  done

  echo
  ui_success "Hostname saved as $HOST_NAME."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_accounts() {
  while true; do
    ui_main_header "$(step_label 7 "Account Configuration")"

    prompt_username ADMIN_USER "administrator account" "${ADMIN_USER:-}"
    prompt_password ADMIN_PW "administrator account"

    ui_main_header "$(step_label 7 "Account Configuration")"

    ADMIN_FULL_NAME="$(gum input \
      --header "Optional: Enter a display name for the administrator account" \
      --padding "0 3" \
      --value "${ADMIN_FULL_NAME:-}" \
      --placeholder ""
    )"

    prompt_username RUNTIME_USER "runtime gaming account" "${RUNTIME_USER:-}" "$ADMIN_USER"
    prompt_password RUNTIME_PW "runtime gaming account"

    prompt_password ROOT_PW "root account"

    ui_main_header "$(step_label 7 "Account Configuration")"

    ui_summary_box 60 double "Selected account configuration

Administrator user: $ADMIN_USER
Admin display name: ${ADMIN_FULL_NAME:-<not set>}
Admin groups: wheel, audio, input, video

Runtime user: $RUNTIME_USER
Runtime groups: games, audio, input, storage, video

Root account: Password set"

    if ui_confirm "Use these account settings?"; then
      break
    fi
  done

  echo
  ui_success "Account settings saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_storage() {
  local drive_name
  local drive_size
  local selection
  local selected_disk
  local selected_size
  local boot_mode
  local -a drives

  while true; do
    drives=()

    while IFS= read -r drive_name; do
      drive_size="$(lsblk -dnr -o SIZE "$drive_name")"
      drives+=("$drive_name - $drive_size")
    done < <(lsblk -dnpr -e 7,11 -o NAME)

    if [[ ${#drives[@]} -eq 0 ]]; then
      ui_main_header "$(step_label 8 "Storage Configuration")"
      ui_danger_box 36 double "No eligible installation disks were detected."
      exit 1
    fi

    if [[ "$UEFI_SUPPORT" == true ]]; then
      boot_mode="UEFI"
    else
      boot_mode="BIOS"
    fi

    ui_main_header "$(step_label 8 "Storage Configuration")"

    ui_page_header "Select the disk that will be used for installation.

The disk will be erased later during the installation after final confirmation."

    ui_note "Detected boot mode: $boot_mode"

    echo

    selection="$(gum choose \
      --header "Choose from available disks:" \
      --padding "0 3" \
      "${drives[@]}")"

    if [[ -z "${selection:-}" ]]; then
      continue
    fi

    selected_disk="${selection%% - *}"
    selected_size="${selection#* - }"

    if [[ "$selected_disk" == *"nvme"* ]]; then
      PARTITION_PREFIX="p"
    else
      PARTITION_PREFIX=""
    fi

    ui_summary_box 40 thick "Selected storage configuration

Install disk        : $selected_disk
Disk size           : $selected_size
Boot mode           : $boot_mode
Filesystem          : $ROOT_FS"

    if ui_confirm_danger "Use this disk for installation?"; then
      DISK="$selected_disk"
      break
    fi
  done

  echo
  ui_success "Storage configuration saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_mirrors() {
  local optimize_choice
  local country_choice
  local mirrorlist_data
  local -a mirror_regions

  while true; do
    ui_main_header "$(step_label 9 "Mirror Configuration")"

    ui_page_header "Choose whether to optimize the pacman mirror list before package installation."

    ui_summary_box 64 double "Updating mirrors can improve package download speed during installation. 

If enabled, reflector will be run later during installation execution."
    echo

    if ui_confirm "Optimize the mirror list before installation?"; then
      optimize_choice=true
    else
      optimize_choice=false
    fi

    if [[ "$optimize_choice" == false ]]; then
      UPDATE_MIRRORS=false
      MIRROR_COUNTRY=Worldwide
      break
    fi

    country_choice="Worldwide"

    ui_main_header "$(step_label 9 "Mirror Configuration")"
    ui_box "Retrieving available mirror regions..."

    if ! mirrorlist_data="$(curl -fsSL https://archlinux.org/mirrorlist/all/https/)"; then
      ui_danger_box 36 double "Failed to retrieve the Arch Linux mirror list.

Please verify your internet connection and try again."
      sleep 3
      continue
    fi

    mapfile -t mirror_regions < <(
      printf '%s\n' "$mirrorlist_data" \
        | sed -n 's/^## //p' \
        | grep -Ev '^(Arch|Generated)\b' \
        | awk 'NF && !seen[$0]++'
    )

    if [[ ${#mirror_regions[@]} -eq 0 ]]; then
      ui_danger_box 36 double "No mirror regions could be parsed from the downloaded mirror list."
      sleep 3
      continue
    fi

    ui_main_header "$(step_label 9 "Mirror Configuration")"

    ui_box "Select the preferred mirror country or region."
    ui_note "Choose Worldwide, or select a country near you."
    echo

    country_choice="$(printf '%s\n' "${mirror_regions[@]}" | \
      gum filter \
      --header "Select your country from the mirrorlist" \
      --placeholder "Type to search countries...")"

    if [[ -z "${country_choice:-}" ]]; then
      continue
    fi

    ui_main_header "$(step_label 9 "Mirror Configuration")"

    ui_summary_box 36 thick "Selected mirror configuration

Optimize mirrors : $optimize_choice
Preferred region : $country_choice"

    if ui_confirm "Use these mirror settings?"; then
      UPDATE_MIRRORS=true
      MIRROR_COUNTRY="$country_choice"
      break
    fi
  done

  echo
  ui_success "Mirror configuration saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_gpu_type() {
  local gpu_choice

  while true; do
    SYSTEM_PACKAGES=()
    ui_main_header "$(step_label 10 "GPU Configuration")"

    ui_page_header "Choose what type of GPU your system has - this will ensure the proper packages/drivers are installed on your system."
    echo

    gpu_choice="$(gum choose \
      --padding "0 3" \
      "Intel integrated graphics" \
      "AMD integrated graphics" \
      "Intel Arc" \
      "AMD Radeon" \
      "NVIDIA" \
    )"

    if [[ -z "${gpu_choice:-}" ]]; then
      continue
    fi

    GPU_TYPE="${gpu_choice}"

    case "$GPU_TYPE" in
      *Intel*)
        SYSTEM_PACKAGES+=(
          "mesa"
          "vulkan-intel"
          "intel-media-driver"
        )
        ;;
      *AMD*)
        SYSTEM_PACKAGES+=(
          "mesa"
          "vulkan-radeon"
          "libva-mesa-driver"
        )
        ;;
      *NVIDIA*)
        ui_main_header "$(step_label 10 "GPU Configuration")"
        ui_danger_box 36 double "NVIDIA graphics are not supported by this installer yet.

Please choose an Intel or AMD graphics option to continue."
        sleep 2
        continue
        ;;
    esac

    ui_main_header "$(step_label 10 "GPU Configuration")"

    ui_summary_box 40 thick "You have selected $gpu_choice. Please confirm this is correct" 

    if ui_confirm "Use this package configuration?"; then
      break
    fi
  done

  echo
  ui_success "Installation package configuration saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_emulators() {
  local selected
  local pkg
  local line
  local core_list
  local aur_list
  local steam_list
  local -a base_system_packages
  local -a emulator_options=(
    "Game Boy (libretro-sameboy)"
    "Game Boy/GB Color (libretro-gambatte)"
    "Game Boy Advance (libretro-mgba)"
    "MAME (libretro-mame)"
    "NEC PC Engine/SuperGrafx/CD (libretro-beetle-pce)"
    "NEC PC Engine (libretro-beetle-pce-fast)"
    "NEC SuperGrafx (libretro-beetle-supergrafx)"
    "Nintendo DS (libretro-desmume)"
    "Nintendo DS (libretro-melonds)"
    "Nintendo NES (libretro-mesen)"
    "Nintendo NES (libretro-nestopia)"
    "Nintendo SNES (libretro-mesen-s)"
    "Nintendo SNES (libretro-snes9x)"
    "Nintendo SNES (libretro-bsnes)"
    "Nintendo SNES (libretro-bsnes-hd)"
    "Nintendo Virtual Boy (libretro-beetle-vb-git)"
    "Nintendo 64 (libretro-mupen64plus-next)"
    "Nintendo 64 (libretro-parallel-n64)"
    "Nintendo GameCube/Wii (libretro-dolphin)"
    "ScummVM (libretro-scummvm)"
    "Sega MS/GG/MD/CD (libretro-genesis-plus-gx)"
    "Sega MegaDrive (libretro-blastem)"
    "Sega 32X (libretro-picodrive)"
    "Sega Saturn (libretro-kronos)"
    "Sega Saturn (libretro-yabause)"
    "Sega Dreamcast (libretro-flycast)"
    "Sony PlayStation (libretro-beetle-psx)"
    "Sony PlayStation (libretro-beetle-psx-hw)"
    "Sony PlayStation 2 (libretro-play)"
    "Sony PSP (libretro-ppsspp)"
  )

  base_system_packages=("${SYSTEM_PACKAGES[@]}")

  while true; do
    SYSTEM_PACKAGES=("${base_system_packages[@]}")
    INSTALL_STEAM=false
    ENABLE_MULTILIB=false
    STEAM_PACKAGES=()
    CORE_PACKAGES=()
    CORE_AUR_PACKAGES=()

    ui_main_header "$(step_label 11 "Emulator Configuration")"

    ui_page_header "Select the emulator cores you'd like to install. Press x to select the emulators you wish to install, then press Enter to submit."

    selected="$(gum choose \
            --padding "0 3" \
            --height 15 \
            --no-limit "${emulator_options[@]}"
    )"

    if [[ -z "${selected:-}" ]]; then
      ui_warn "No emulator cores were selected."
      if ! ui_confirm "Continue without installing any emulator cores?"; then
        continue
      fi
    else
      while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        pkg="${line##*(}"
        pkg="${pkg%)}"

        if [[ "$pkg" == "libretro-beetle-vb-git" ]]; then
          CORE_AUR_PACKAGES+=("$pkg")
        else
          CORE_PACKAGES+=("$pkg")
        fi
      done <<< "$selected"
    fi

    echo
    if ui_confirm "Do you also want to install Steam?"; then
      INSTALL_STEAM=true
      ENABLE_MULTILIB=true
      STEAM_PACKAGES+=("steam" "gamescope")
      case "$GPU_TYPE" in
        *Intel*)
          SYSTEM_PACKAGES+=(
            'lib32-mesa'
            'lib32-vulkan-intel'
          )
          ;;
        *AMD*)
          SYSTEM_PACKAGES+=(
            'lib32-mesa'
          )
          ;;
      esac
    fi

    dedupe_array CORE_PACKAGES
    dedupe_array CORE_AUR_PACKAGES
    dedupe_array STEAM_PACKAGES
    dedupe_array SYSTEM_PACKAGES

    core_list="$(IFS=', '; echo "${CORE_PACKAGES[*]:-<none>}")"
    aur_list="$(IFS=', '; echo "${CORE_AUR_PACKAGES[*]:-<none>}")"
    steam_list="$(IFS=', '; echo "${STEAM_PACKAGES[*]:-<none>}")"


    ui_main_header "$(step_label 11 "Emulator Configuration")"

    ui_summary_box 64 thick "Selected emulator configuration

Core packages   : $core_list
AUR packages    : $aur_list
Install Steam   : $INSTALL_STEAM
Steam packages  : $steam_list"

    echo
    if ui_confirm "Use this emulator configuration?"; then
      break
    fi
  done

  echo
  ui_success "Emulator configuration saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

configure_remote_and_firewall() {
  local ssh_choice
  local ufw_choice

  while true; do
    ui_main_header "$(step_label 12 "Remote Access and Firewall")"

    ui_page_header "Choose whether to enable SSH remote access and the UFW firewall on the installed system."

    ui_note_box "SSH allows remote administration of the system.

UFW enables a firewall.

Important:
If you enable both SSH and UFW, SSH access will not work until you allow it through UFW rules.
"

    echo

    if ui_confirm "Enable SSH on the installed system?"; then
      ssh_choice=true
    else
      ssh_choice=false
    fi

    echo

    if ui_confirm "Enable UFW on the installed system?"; then
      ufw_choice=true
    else
      ufw_choice=false
    fi

    ui_main_header "$(step_label 12 "Remote Access and Firewall")"

    ui_summary_box 56 thick "Selected service configuration

Enable SSH : $ssh_choice
Enable UFW : $ufw_choice"

    if [[ "$ssh_choice" == true && "$ufw_choice" == true ]]; then
      echo
      ui_danger_box 52 double "SSH and UFW are both enabled.

Remote SSH access will be blocked until you allow SSH through UFW."
    fi

    if ui_confirm "Use these service settings?"; then
      ENABLE_SSH="$ssh_choice"
      ENABLE_UFW="$ufw_choice"
      break
    fi
  done

  echo
  ui_success "Service configuration saved."

  if ! ui_confirm "Continue to the next step?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}


format_disk() {
  ui_main_header "$(step_label 12 "Disk Preparation")"

  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    ui_danger_box 36 double "This installer must be run as root."
    exit 1
  fi

  ui_main_header "$(step_label 12 "Disk Preparation")"
  ui_danger_box 44 double "The selected disk will now be erased.

Disk: $DISK
Boot mode: $( [[ "$UEFI_SUPPORT" == true ]] && echo UEFI || echo BIOS )
Filesystem: $ROOT_FS"

  if ! ui_confirm_danger "Erase and format this disk?"; then
    ui_note "Installation cancelled."
    exit 0
  fi

  run_step "Unmounting any existing target mounts..." bash -c '
    umount -R /mnt 2>/dev/null || true
  '

  run_step "Partitioning disk..." bash -c "
    set -Eeuo pipefail

    sgdisk --zap-all $(printf '%q' "$DISK")
    wipefs -af $(printf '%q' "$DISK")

    if [[ $(printf '%q' "$UEFI_SUPPORT") == true ]]; then
      sgdisk -n 1:1MiB:+512MiB -t 1:ef00 -c 1:'EFI System' $(printf '%q' "$DISK") 
      sgdisk -n 2:0:0          -t 2:8300 -c 2:'Linux root' $(printf '%q' "$DISK")
    else
      parted -s $(printf '%q' "$DISK") \
        mklabel msdos \
        mkpart primary ext4 1MiB 100% \
        set 1 boot on
    fi

    partprobe $(printf '%q' "$DISK")
    udevadm settle
  "

  if [[ "$UEFI_SUPPORT" == true ]]; then
    BOOT_PARTITION="${DISK}${PARTITION_PREFIX}1"
    ROOT_PARTITION="${DISK}${PARTITION_PREFIX}2"
  else
    BOOT_PARTITION=""
    ROOT_PARTITION="${DISK}${PARTITION_PREFIX}1"
  fi

  run_step "Formatting root filesystem..." mkfs.ext4 -F "$ROOT_PARTITION"

  if [[ -n "$BOOT_PARTITION" ]]; then
    run_step "Formatting EFI system partition..." mkfs.fat -F32 "$BOOT_PARTITION"
  fi

  run_step "Labelling root filesystem..." e2label "$ROOT_PARTITION" RetroBoxFS

  run_step "Mounting filesystems..." bash -c "
    set -Eeuo pipefail

    mount $(printf '%q' "$ROOT_PARTITION") /mnt

    if $(printf '%q' "$UEFI_SUPPORT"); then
      mkdir -p /mnt/boot
      mount $(printf '%q' "$BOOT_PARTITION") /mnt/boot
    fi
  "

  echo
  ui_success "Disk configuration completed"

  if ! ui_confirm "Continue to installation?"; then
    ui_note "Installation cancelled."
    exit 0
  fi
}

install_system() {
  local -a pacstrap_packages=()

  ui_main_header "$(step_label 13 "System Installation")"

  ui_danger_box 46 double "The installer is ready to install Arch Linux to $DISK

This step will install the system to the disk and configure the items you selected throughout the configuration steps."

  if ! ui_confirm_danger "Begin system installation?"; then
    ui_note "Installation cancelled."
    exit 0
  fi

  if [[ "$UPDATE_MIRRORS" == true ]]; then
    if [[ "$MIRROR_COUNTRY" == "Worldwide" ]]; then
      run_step "Optimizing pacman mirrors..." bash -c '
        set -Eeuo pipefail
        pacman -Sy --noconfirm reflector >/dev/null
        reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
      '
    else
      run_step "Optimizing pacman mirrors..." bash -c "
        set -Eeuo pipefail
        pacman -Sy --noconfirm reflector >/dev/null
        reflector --country $(printf '%q' "$MIRROR_COUNTRY") --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
      "
    fi
  fi

  pacstrap_packages=()
  pacstrap_packages+=("${BASE_PACKAGES[@]}")
  pacstrap_packages+=("${SYSTEM_PACKAGES[@]}")
  pacstrap_packages+=("${CORE_PACKAGES[@]}")
  pacstrap_packages+=("${STEAM_PACKAGES[@]}")

  if [[ "$BT_SUPPORT" == true ]]; then
    pacstrap_packages+=("bluez" "bluez-utils")
  fi

  case "$CPU_TYPE" in
    intel)
      pacstrap_packages+=("intel-ucode")
      ;;
    amd)
      pacstrap_packages+=("amd-ucode")
      ;;
  esac

  if [[ "$UEFI_SUPPORT" != true ]]; then
    pacstrap_packages+=('grub')
  fi

  dedupe_array pacstrap_packages

  if [[ "${ENABLE_MULTILIB:-false}" == true ]]; then
    run_step "Enabling multilib repo for Steam..." bash -c '
      set -Eeuo pipefail

      if grep -Eq "^[[:space:]]*\[multilib\]" /etc/pacman.conf; then
        :
      elif grep -Eq "^[[:space:]]*#[[:space:]]*\[multilib\]" /etc/pacman.conf; then
        sed -i "/^[[:space:]]*#[[:space:]]*\[multilib\]/,/^[[:space:]]*#[[:space:]]*Include = \/etc\/pacman\.d\/mirrorlist/s/^[[:space:]]*#[[:space:]]*//" /etc/pacman.conf
      else
        printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf
      fi

      pacman -Sy
    '
  fi

  run_step "Installing packages with pacstrap..." pacstrap -K /mnt "${pacstrap_packages[@]}"

  run_step "Generating fstab..." bash -c '
    set -Eeuo pipefail
    genfstab -U /mnt >> /mnt/etc/fstab
  '

  run_step "Configuring timezone..." bash -c "
    set -Eeuo pipefail
    arch-chroot /mnt ln -sf $(printf '%q' "/usr/share/zoneinfo/$TIME_ZONE") /etc/localtime
  "

  if [[ "$UTC_TIME" == true ]]; then
    run_step "Setting hardware clock to UTC..." arch-chroot /mnt hwclock --systohc --utc
  else
    run_step "Setting hardware clock to local time..." arch-chroot /mnt hwclock --systohc --localtime
  fi

  if [[ "$UPDATE_MIRRORS" == true ]]; then
    run_step "Saving mirror configuration to installed system..." bash -c '
      set -Eeuo pipefail
      mkdir -p /mnt/etc/pacman.d
      cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
    '
  fi

  if [[ "${ENABLE_MULTILIB:-false}" == true ]]; then
    run_step "Saving pacman multilib configuration..." bash -c '
      set -Eeuo pipefail
      cp /etc/pacman.conf /mnt/etc/pacman.conf
    '
  fi

  run_step "Setting keymap..." bash -c "
    set -Eeuo pipefail
    printf 'KEYMAP=%s\n' $(printf '%q' "$KEYMAP") > /mnt/etc/vconsole.conf
  "

  for locale in "${ENABLED_LOCALES[@]}"; do
    run_step "Enabling locale $locale..." sed -i "s/^#\(${locale}[[:space:]].*\)/\1/" /mnt/etc/locale.gen
  done

  run_step "Generating locales..." arch-chroot /mnt locale-gen

  run_step "Setting primary locale..." bash -c "
    set -Eeuo pipefail
    printf 'LANG=%s\n' $(printf '%q' "$PRIMARY_LOCALE") > /mnt/etc/locale.conf
  "
  run_step "Setting hostname..." bash -c "
    set -Eeuo pipefail
    printf '%s\n' $(printf '%q' "$HOST_NAME") > /mnt/etc/hostname
  "

  run_step "Configuring hosts file..." bash -c "
    set -Eeuo pipefail
    cat > /mnt/etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOST_NAME.localdomain $HOST_NAME
EOF
  "

  run_step "Setting up admin account..." bash -c "
    set -Eeuo pipefail

    if [[ -z $(printf '%q' "$ADMIN_FULL_NAME") ]]; then
      arch-chroot /mnt useradd -m -G wheel,audio,input,video $(printf '%q' "$ADMIN_USER")
    else
      arch-chroot /mnt useradd -m -c $(printf '%q' "$ADMIN_FULL_NAME") -G wheel,audio,input,video $(printf '%q' "$ADMIN_USER")
    fi

    printf '%s\n' $(printf '%q' "$ADMIN_USER:$ADMIN_PW") | arch-chroot /mnt chpasswd

    sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)$/\1/' /mnt/etc/sudoers
  "

  run_step "Setting up runtime account..." bash -c "
    set -Eeuo pipefail

    arch-chroot /mnt useradd -m -G games,audio,input,storage,video $(printf '%q' "$RUNTIME_USER")
    printf '%s\n' $(printf '%q' "$RUNTIME_USER:$RUNTIME_PW") | arch-chroot /mnt chpasswd
  "

  run_step "Setting root password..." bash -c "
    set -Eeuo pipefail

    printf '%s\n' $(printf '%q' "root:$ROOT_PW") | arch-chroot /mnt chpasswd
  "

  run_step "Allowing temporary installer sudo..." bash -c "
    set -Eeuo pipefail

    printf '%s\n' $(printf '%q' "$ADMIN_USER ALL=(ALL:ALL) NOPASSWD: ALL") > /mnt/etc/sudoers.d/10-installer-admin
    chmod 440 /mnt/etc/sudoers.d/10-installer-admin
    arch-chroot /mnt visudo -cf /etc/sudoers.d/10-installer-admin
  "

  run_step "Setting up AUR helper..." bash -c "
    set -Eeuo pipefail

    arch-chroot /mnt su - $(printf '%q' "$ADMIN_USER") -c '
      set -Eeuo pipefail
      cd ~
      rm -rf yay-bin
      git clone https://aur.archlinux.org/yay-bin.git
      cd yay-bin
      makepkg -si --noconfirm
    '
  "

  run_step "Installing ES-DE..." bash -c "
    set -Eeuo pipefail

    arch-chroot /mnt su - $(printf '%q' "$ADMIN_USER") -c '
      set -Eeuo pipefail
      yay -S --needed --noconfirm --answerclean None --answerdiff None emulationstation-de
    '
  "

  if ((${#CORE_AUR_PACKAGES[@]} > 0)); then 
    run_step "Installing additional RetroArch cores from the AUR..." bash -c "
      set -Eeuo pipefail

      arch-chroot /mnt su - $(printf '%q' "$ADMIN_USER") -c '
        set -Eeuo pipefail
        yay -S --needed --noconfirm --answerclean None --answerdiff None $(printf '%q ' "${CORE_AUR_PACKAGES[@]}")
      '
    "
  fi

  run_step "Removing temporary installer sudo..." bash -c "
    set -Eeuo pipefail
    rm -f /mnt/etc/sudoers.d/10-installer-admin
  "

  if [[ "$UEFI_SUPPORT" == true ]]; then
    run_step "Installing systemd-boot..." bash -c "
      set -Eeuo pipefail

      arch-chroot /mnt bootctl install

      mkdir -p /mnt/boot/loader/entries

      cat > /mnt/boot/loader/loader.conf <<'EOF'
default arch.conf
timeout 0
console-mode max
editor no
EOF

      cat > /mnt/boot/loader/entries/arch.conf <<EOF
title Arch Linux
linux /vmlinuz-linux
initrd /$(printf '%q' "$CPU_TYPE")-ucode.img
initrd /initramfs-linux.img
options root=LABEL=RetroBoxFS rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 fbcon=nodefer vt.global_cursor_default=0
EOF

      cat > /mnt/boot/loader/entries/arch-fallback.conf <<EOF
title Arch Linux (fallback initramfs)
linux /vmlinuz-linux
initrd /$(printf '%q' "$CPU_TYPE")-ucode.img
initrd /initramfs-linux-fallback.img
options root=LABEL=RetroBoxFS rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 fbcon=nodefer vt.global_cursor_default=0
EOF
    " 
  else
      run_step "Configuring GRUB..." bash -c "
        set -Eeuo pipefail

        arch-chroot /mnt mkdir -p /etc/default/grub.d
        cat > /mnt/etc/default/grub.d/99-silent-boot.cfg <<'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 fbcon=nodefer vt.global_cursor_default=0"
EOF

        arch-chroot /mnt grub-install --target=i386-pc $(printf '%q' "$DISK")
        arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
        sed -i 's/echo/#echo/g' /mnt/boot/grub/grub.cfg
    "
  fi

  run_step "Enabling services..." bash -c "
    set -Eeuo pipefail

    arch-chroot /mnt systemctl enable NetworkManager.service

    if [[ $(printf '%q' "$BT_SUPPORT") == true ]]; then
      arch-chroot /mnt systemctl enable bluetooth.service
    fi

    if [[ $(printf '%q' "$ENABLE_SSH") == true ]]; then
      arch-chroot /mnt systemctl enable ssh.service
    fi

    if [[ $(printf '%q' "$ENABLE_UFW") == true ]]; then
      arch-chroot /mnt ufw --force enable
      arch-chroot /mnt systemctl enable ufw.service
    fi
  "

  echo
  ui_success "Base system installation tasks completed."
}


# Now actually run the functions
init_theme
detect_system_capabilities
welcome
preflight_checks
set_keymap
set_locale
set_timezone
set_hostname
configure_accounts
configure_storage
configure_mirrors
configure_gpu_type
configure_emulators
configure_remote_and_firewall
format_disk
install_system
