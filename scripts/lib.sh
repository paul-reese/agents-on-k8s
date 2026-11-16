# Shared helpers. Sourced by the other scripts.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT/.env" ]]; then
  set -a; source "$ROOT/.env"; set +a
fi
: "${COLIMA_PROFILE:=agents}"
CTX="colima-${COLIMA_PROFILE}"

need() { command -v "$1" >/dev/null || { echo "Missing: $1 (brew install $1)"; exit 1; }; }
require_var() { [[ -n "${!1:-}" ]] || { echo "Set $1 in .env"; exit 1; }; }
use_ctx() { kubectl config use-context "$CTX" >/dev/null; }
