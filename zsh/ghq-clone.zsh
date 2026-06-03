ghq-clone() {
  if [ "$#" -gt 1 ]; then
    print -u2 "usage: ghq-clone [owner]"
    return 2
  fi

  local command_name
  local missing_commands=""
  for command_name in gh ghq fzf; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      missing_commands="$missing_commands $command_name"
    fi
  done

  if [ -n "$missing_commands" ]; then
    print -u2 "ghq-clone: missing required command(s):$missing_commands"
    return 1
  fi

  local owner="$1"
  if [ -z "$owner" ]; then
    local viewer
    viewer="$(gh api user --jq .login)" || return 1

    local owners
    owners="$(
      {
        printf '%s\n' "$viewer"
        gh org list --limit 100
        gh api --paginate '/user/repos?affiliation=owner,collaborator,organization_member&per_page=100' --jq '.[].owner.login'
      } | awk '!seen[$0]++'
    )" || return 1

    owner="$(
      printf '%s\n' "$owners" |
        fzf \
          --prompt='GitHub owner> ' \
          --height=40% \
          --reverse \
          --preview='gh repo list {} --limit 20 --no-archived' \
          --preview-window=down:40%:wrap
    )"
  fi

  if [ -z "$owner" ]; then
    return 0
  fi

  local repo_rows
  repo_rows="$(
    gh repo list "$owner" \
      --limit 1000 \
      --no-archived \
      --json nameWithOwner,url,visibility,isFork,pushedAt,description \
      --jq '.[] | [.nameWithOwner, .url, .visibility, (if .isFork then "fork" else "source" end), .pushedAt, (.description // "")] | @tsv'
  )" || return 1

  if [ -z "$repo_rows" ]; then
    print -u2 "ghq-clone: no repositories found for owner: $owner"
    return 1
  fi

  local selected_repo
  selected_repo="$(
    printf '%s\n' "$repo_rows" |
      fzf \
        --prompt='GitHub repo> ' \
        --height=80% \
        --reverse \
        --delimiter=$'\t' \
        --with-nth=1,3,4,6.. \
        --preview='gh repo view {1}' \
        --preview-window=right:60%:wrap
  )"

  if [ -z "$selected_repo" ]; then
    return 0
  fi

  local repo_url
  repo_url="$(printf '%s\n' "$selected_repo" | cut -f2)"
  ghq get "$repo_url"
}
