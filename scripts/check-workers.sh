

check_container_workers() {
  local container="$1"
  local status_working="$2"
  
  status_es=$(curl "$status_working")

  echo "status working container: $status_working"

  if [[ "$status_working" ]]; then
    echo "container is ready with status: ${status_working}"
    return 0
  fi
  
  return 1
}
