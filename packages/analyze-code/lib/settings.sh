#!/bin/bash
# =============================================================================
# SETTINGS - GLOBAL CONSTANTS
# All paths and configuration constants for the analyze-code tool
# =============================================================================

# Base paths
readonly GIT_BASH_ROOT="c:/App/Git"
readonly ANALYZER_DIR="$GIT_BASH_ROOT/home/portx/packages/analyze-code"

# Tool paths - all relative to GIT_BASH_ROOT
readonly GOJQ_PATH="$GIT_BASH_ROOT/home/portx/packages/gojq/gojq.exe"
readonly RIPGREP_PATH="$GIT_BASH_ROOT/home/portx/packages/ripgrep/rg.exe"
readonly ES_PATH="$GIT_BASH_ROOT/home/portx/packages/everything/es.exe"
readonly CTAGS_PATH="$GIT_BASH_ROOT/home/portx/packages/ctags/ctags.exe"
readonly SCC_PATH="$GIT_BASH_ROOT/home/portx/packages/scc/scc.exe"
readonly SHELLCHECK_PATH="$GIT_BASH_ROOT/home/portx/packages/shellcheck/shellcheck.exe"
readonly AST_GREP_PATH="$GIT_BASH_ROOT/home/portx/packages/ast-grep/ast-grep.exe"
readonly TREESITTER_PATH="$GIT_BASH_ROOT/home/portx/packages/treesitter/portable_treesitter_parser.py"
readonly TRIVY_PATH="$GIT_BASH_ROOT/home/portx/packages/trivy/trivy.exe"
readonly DPRINT_PATH="$GIT_BASH_ROOT/home/portx/packages/dprint/dprint.exe"
readonly RUFF_PATH="$GIT_BASH_ROOT/home/portx/packages/ruff/ruff.exe"
readonly TERRAFORM_PATH="$GIT_BASH_ROOT/home/portx/packages/terraform/terraform.exe"

# Analyzer configuration
readonly ANALYZER_TIMEOUT=30
readonly LOG_LEVEL="${ANALYZE_HOOK_LOG_LEVEL:-DEBUG}"
readonly LOG_MAX_SIZE=1048576

# Export for use by analyzers
export GIT_BASH_ROOT
export GOJQ_PATH
export RIPGREP_PATH
export ES_PATH
export CTAGS_PATH
export SCC_PATH
export SHELLCHECK_PATH
export AST_GREP_PATH
export TREESITTER_PATH
export TRIVY_PATH
export DPRINT_PATH
export RUFF_PATH
export TERRAFORM_PATH
export ANALYZER_TIMEOUT