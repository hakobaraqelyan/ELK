

check_container_workers() {
  local container="$1"
  local status_working="$2"
  
  echo "status working container: $status_working"

  status=$(curl "$status_working" 2>/dev/null)

  if [[ "$status" ]]; then
    echo "container is ready with status: ${status_working}"
    return 0
  fi
  
  return 1
}
