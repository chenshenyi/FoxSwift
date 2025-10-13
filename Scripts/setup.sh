#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking prerequisites..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install it from https://brew.sh/"
    exit 1
fi

# Check for pre-commit
if ! command -v pre-commit &> /dev/null; then
    echo "pre-commit not found. Installing with Homebrew..."
    brew install pre-commit
else
    echo "pre-commit is already installed."
fi

# Check for git-lfs
if ! command -v git-lfs &> /dev/null; then
    echo "git-lfs not found. Installing with Homebrew..."
    brew install git-lfs
else
    echo "git-lfs is already installed."
fi

echo "Prerequisites checked."
echo ""
echo "Initializing project..."

# Install Git LFS hooks
echo "Installing Git LFS hooks..."
git lfs install

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
pre-commit install --config .config/.pre-commit-config.yaml
pre-commit run --all-files --config .config/.pre-commit-config.yaml

echo ""
echo "Project setup complete! ✨"
