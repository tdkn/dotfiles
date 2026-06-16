ghq-clone() {
  (( $# <= 1 )) || { print -u2 "usage: ghq-clone [owner]"; return 2; }

  local cmd
  for cmd in gh ghq fzf; do
    command -v "$cmd" >/dev/null || { print -u2 "ghq-clone: missing $cmd"; return 1; }
  done

  local owner="$1" repo fzf_status
  if [[ -z "$owner" ]]; then
    local owners candidate
    local -a unique_owners
    local -A seen_owners

    owners="$(gh api graphql --paginate -f query='
      query($endCursor: String) {
        viewer {
          login
          organizations(first: 100) { nodes { login } }
          repositories(first: 100, affiliations: [OWNER, COLLABORATOR, ORGANIZATION_MEMBER], after: $endCursor) {
            nodes { owner { login } }
            pageInfo { hasNextPage endCursor }
          }
        }
      }' \
      --jq '.data.viewer | .login, .organizations.nodes[].login, .repositories.nodes[].owner.login')"
    local gh_status=$?
    (( gh_status == 0 )) || return "$gh_status"

    while IFS= read -r candidate; do
      [[ -n "$candidate" && -z "${seen_owners[$candidate]}" ]] || continue
      seen_owners[$candidate]=1
      unique_owners+=("$candidate")
    done <<< "$owners"
    (( ${#unique_owners[@]} )) || { print -u2 "ghq-clone: no GitHub owners found"; return 1; }

    owner="$(fzf --prompt='GitHub owner> ' --height=40% --reverse <<< "${(F)unique_owners}")"
    fzf_status=$?
    case "$fzf_status" in
      0) ;;
      1|130) return 0 ;;
      *) return "$fzf_status" ;;
    esac
  fi
  [[ -n "$owner" ]] || return 0

  local repos
  repos="$(gh repo list "$owner" --limit 1000 --no-archived --json name --jq '.[].name')"
  local gh_status=$?
  (( gh_status == 0 )) || return "$gh_status"
  [[ -n "$repos" ]] || { print -u2 "ghq-clone: no repositories found for $owner"; return 1; }

  repo="$(fzf --prompt='GitHub repo> ' --height=80% --reverse <<< "$repos")"
  fzf_status=$?
  case "$fzf_status" in
    0) ;;
    1|130) return 0 ;;
    *) return "$fzf_status" ;;
  esac
  [[ -n "$repo" ]] || return 0

  ghq get "$owner/$repo"
}
