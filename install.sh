#!/usr/bin/env bash
set -euo pipefail

# ============================================
# Detect OS
# ============================================
detect_os() {
  if [[ "${WSL_DISTRO_NAME:-}" != "" ]]; then
    echo "WSL"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "LINUX"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "MAC"
  else
    echo "UNKNOWN"
  fi
}

# ============================================
# Detect shell + rcfile
# ============================================
detect_shell_rc() {
  local shell_name rcfile

  # 현재 로그인한 쉘
  shell_name="${SHELL##*/}"

  case "$shell_name" in
    bash)
      rcfile="$HOME/.bashrc"
      ;;
    zsh)
      rcfile="$HOME/.zshrc"
      ;;
    fish)
      rcfile="$HOME/.config/fish/config.fish"
      ;;
    *)
      # fallback: 기본은 bash로 가정
      shell_name="bash"
      rcfile="$HOME/.bashrc"
      ;;
  esac

  echo "$shell_name|$rcfile"
}

# ============================================
# Add export line if missing
# ============================================
add_to_rcfile() {
  local line="$1"
  local rcfile="$2"

  echo "will be inject >> $line"

  if grep -Fq "$line" "$rcfile" 2>/dev/null; then
    echo "✅ PATH already configured in $rcfile"
  else
    echo "" >> "$rcfile"
    echo "# Added by rky installer" >> "$rcfile"
    echo "$line" >> "$rcfile"
    echo "✅ Added rky directory to PATH in $rcfile"
  fi
}

# ============================================
# MAIN
# ============================================
main() {
  local os shell_info shell_name rcfile
  os=$(detect_os)
  shell_info=$(detect_shell_rc)
  shell_name="${shell_info%%|*}"
  rcfile="${shell_info##*|}"

  local rky_dir
  rky_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local export_line="export PATH=\"\$PATH:${rky_dir}/bin\""

  echo "🪄 Detected OS: $os"
  echo "🪶 Detected shell: $shell_name"
  echo "📂 rky directory: $rky_dir"
  echo "⚙️ Target RC file: $rcfile"

  add_to_rcfile "$export_line" "$rcfile"

  # 즉시 적용
  export PATH="$PATH:${rky_dir}"
  echo ""
  echo "🔄 Applied for current session"
  echo "🎉 rky installation complete!"
  echo "➡️  Try running: rky version"
}

main "$@"
