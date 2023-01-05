#!/usr/bin/env bash
set -euo pipefail

DRY=false
BRANCH=""
START="2023-01-01"
END="2023-12-31"
MSG="Backdated contribution"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY=true
      shift
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --start)
      START="$2"
      shift 2
      ;;
    --end)
      END="$2"
      shift 2
      ;;
    --message)
      MSG="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1

if [[ -z "$BRANCH" ]]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi

git checkout "$BRANCH" >/dev/null 2>&1 || true

months=(01 02 03 04 05 06 07 08 09 10 11 12)
for m in "${months[@]}"; do
  DATE="2023-${m}-15 12:00:00 +0000"
  if [[ "$DRY" == true ]]; then
    echo "GIT_AUTHOR_DATE='$DATE' GIT_COMMITTER_DATE='$DATE' git commit --allow-empty -m '$MSG ${m}'"
  else
    GIT_AUTHOR_DATE="$DATE" GIT_COMMITTER_DATE="$DATE" git commit --allow-empty -m "$MSG ${m}"
  fi
done

echo "Done. Push with: git push origin $BRANCH"
