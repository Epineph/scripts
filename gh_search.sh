#!/usr/bin/env bash

# Function to display usage
show_help() {
  cat << EOF
Usage: $0 [<query>] [flags]

Flags:
      --archived                    Filter based on the repository archived state {true|false}
      --created date                Filter based on created at date
      --followers number            Filter based on number of followers
      --forks number                Filter on number of forks
      --good-first-issues number    Filter on number of issues with the 'good first issue' label
      --help-wanted-issues number   Filter on number of issues with the 'help wanted' label
      --language string             Filter based on the coding language
      --license strings             Filter based on license type
  -L, --limit int                   Maximum number of repositories to fetch (default 30)
      --match strings               Restrict search to specific field of repository: {name|description|readme}
      --number-topics number        Filter on number of topics
      --order string                Order of repositories returned, ignored unless '--sort' flag is specified: {asc|desc} (default "desc")
      --owner strings               Filter on owner
      --size string                 Filter on a size range, in kilobytes
      --sort string                 Sort fetched repositories: {forks|help-wanted-issues|stars|updated} (default "best-match")
      --stars number                Filter on number of stars
      --topic strings               Filter on topic
      --updated date                Filter on last updated at date
      --visibility strings          Filter based on visibility: {public|private|internal}
  -w, --web                         Open the search query in the web browser
  -h, --help                        Show help for command
      --last-modified time          Filter based on last modified time (e.g., 2y for 2 years, 5m for 5 months)

Inherited Flags:
  --help                            Show help for command

Examples:
  # search repositories matching set of keywords "cli" and "shell"
  $0 cli shell
  
  # search repositories matching phrase "vim plugin"
  $0 "vim plugin"
  
  # search repositories public repos in the microsoft organization
  $0 --owner=microsoft --visibility=public
  
  # search repositories with a set of topics
  $0 --topic=unix,terminal
  
  # search repositories by coding language and number of good first issues
  $0 --language=go --good-first-issues=">=10"
  
  # search repositories without topic "linux"
  $0 -- -topic:linux
  
  # search repositories excluding archived repositories
  $0 --archived=false
EOF
}

# Default values
query=""
archived=""
created=""
followers=""
forks=""
good_first_issues=""
help_wanted_issues=""
language=""
license=""
limit=30
match=""
number_topics=""
order="desc"
owner=""
size=""
sort=""
stars=""
template=""
topic=""
updated=""
visibility=""
web=false
last_modified=""


# Function to convert last modified time to GitHub search format
convert_last_modified() {
  local time="$1"
  if [[ "$time" =~ ^([0-9]+)([ym])$ ]]; then
    local amount="${BASH_REMATCH[1]}"
    local unit="${BASH_REMATCH[2]}"
    if [[ "$unit" == "y" ]]; then
      date -d "-${amount} years" +"%Y-%m-%d"
    elif [[ "$unit" == "m" ]]; then
      date -d "-${amount} months" +"%Y-%m-%d"
    fi
  else
    echo ""
  fi
}

# Function to construct the gh command based on the provided parameters
construct_gh_command() {
  cmd="gh search repos $query"
  
  [[ -n "$archived" ]] && cmd+=" --archived=$archived"
  [[ -n "$created" ]] && cmd+=" --created='$created'"
  [[ -n "$followers" ]] && cmd+=" --followers='$followers'"
  [[ -n "$forks" ]] && cmd+=" --forks='$forks'"
  [[ -n "$good_first_issues" ]] && cmd+=" --good-first-issues='$good_first_issues'"
  [[ -n "$help_wanted_issues" ]] && cmd+=" --help-wanted-issues='$help_wanted_issues'"
  [[ -n "$language" ]] && cmd+=" --language='$language'"
  [[ -n "$license" ]] && cmd+=" --license='$license'"
  [[ -n "$limit" ]] && cmd+=" --limit=$limit"
  [[ -n "$match" ]] && cmd+=" --match='$match'"
  [[ -n "$number_topics" ]] && cmd+=" --number-topics='$number_topics'"
  [[ -n "$order" ]] && cmd+=" --order='$order'"
  [[ -n "$owner" ]] && cmd+=" --owner='$owner'"
  [[ -n "$size" ]] && cmd+=" --size='$size'"
  [[ -n "$sort" ]] && cmd+=" --sort='$sort'"
  [[ -n "$stars" ]] && cmd+=" --stars='$stars'"
  [[ -n "$template" ]] && cmd+=" --template='$template'"
  [[ -n "$topic" ]] && cmd+=" --topic='$topic'"
  [[ -n "$updated" ]] && cmd+=" --updated='$updated'"
  [[ -n "$visibility" ]] && cmd+=" --visibility='$visibility'"
  [[ "$web" == true ]] && cmd+=" --web"
  
  if [[ -n "$last_modified" ]]; then
    local modified_date
    modified_date=$(convert_last_modified "$last_modified")
    if [[ -n "$modified_date" ]]; then
      cmd+=" --updated=>=$modified_date"
    fi
  fi

  echo "$cmd"
}

# Parse the input parameters
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --archived) archived="$2"; shift ;;
    --created) created="$2"; shift ;;
    --followers) followers="$2"; shift ;;
    --forks) forks="$2"; shift ;;
    --good-first-issues) good_first_issues="$2"; shift ;;
    --help-wanted-issues) help_wanted_issues="$2"; shift ;;
    --language) language="$2"; shift ;;
    --license) license="$2"; shift ;;
    -L|--limit) limit="$2"; shift ;;
    --match) match="$2"; shift ;;
    --number-topics) number_topics="$2"; shift ;;
    --order) order="$2"; shift ;;
    --owner) owner="$2"; shift ;;
    --size) size="$2"; shift ;;
    --sort) sort="$2"; shift ;;
    --stars) stars="$2"; shift ;;
    --template) template="$2"; shift ;;
    --topic) topic="$2"; shift ;;
    --updated) updated="$2"; shift ;;
    --visibility) visibility="$2"; shift ;;
    -w|--web) web=true ;;
    --last-modified) last_modified="$2"; shift ;;
    -h|--help) show_help; exit 0 ;;
    --) shift; break ;;
    -*|--*) echo "Unknown option: $1"; show_help; exit 1 ;;
    *) query="$query $1" ;;
  esac
  shift
done

# Construct the command for sorting by stars
sort_by_stars=$(construct_gh_command)
sort_by_stars+=" --sort=stars"

# Construct the command for sorting by followers
sort_by_followers=$(construct_gh_command)
sort_by_followers+=" --sort=followers"

# Execute the commands and produce tables
echo "Repositories sorted by stars:"
eval "$sort_by_stars | gh json --fields fullName,stargazersCount,followersCount --jq '.data[] | {fullName, stargazersCount, followersCount}'"

echo "Repositories sorted by followers:"
eval "$sort_by_followers | gh json --fields fullName,followersCount,stargazersCount --jq '.data[] | {fullName, followersCount, stargazersCount}'"

# Nested sorting by stars and followers
nested_sort=$(construct_gh_command)
nested_sort+=" --sort=stars --order=desc"

echo "Repositories sorted by stars and then by followers:"
eval "$nested_sort | gh json --fields fullName,stargazersCount,followersCount --jq 'sort_by(.stargazersCount, .followersCount) | .data[] | {fullName, stargazersCount, followersCount}'"

