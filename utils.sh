yes_no() {
  local message="${1}"
  local func_name="${2}"
  
  while true; do
      read -p "${message}" yn
      case $yn in
          [Yy]* ) make install; break;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}
