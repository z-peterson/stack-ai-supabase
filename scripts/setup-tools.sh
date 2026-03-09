#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking and installing required tools..."

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect package manager
if command_exists brew; then
  PKG_MANAGER="brew"
elif command_exists apt-get; then
  PKG_MANAGER="apt"
else
  echo "Error: No supported package manager found (brew or apt)"
  exit 1
fi

install_tool() {
  local tool="$1"
  local brew_name="${2:-$1}"
  local apt_name="${3:-$1}"

  if command_exists "$tool"; then
    echo "  [OK] $tool already installed"
  else
    echo "  [INSTALL] Installing $tool..."
    if [ "$PKG_MANAGER" = "brew" ]; then
      brew install "$brew_name"
    else
      sudo apt-get install -y "$apt_name"
    fi
  fi
}

# Core tools
install_tool "terraform" "hashicorp/tap/terraform" "terraform"
install_tool "helm" "helm" "helm"
install_tool "kubectl" "kubernetes-cli" "kubectl"
install_tool "tflint" "tflint" "tflint"
install_tool "kubeconform" "kubeconform" "kubeconform"
install_tool "shellcheck" "shellcheck" "shellcheck"
install_tool "aws" "awscli" "awscli"

# Helm repos
echo "==> Adding Helm repositories..."
helm repo add supabase-community https://supabase-community.github.io/supabase-kubernetes 2>/dev/null || true
helm repo update

echo "==> All tools installed and configured."
