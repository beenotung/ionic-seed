#!/usr/bin/env bash
# ---- util functions ----

function hasCommand {
  if hash $1 2>/dev/null; then
    echo "1"
  else
    echo "0"
  fi
}

function checkCommand {
  res=$(hasCommand "$1");
  if [ "$res" == "0" ]; then
    echo "Error : missing $1";
    echo "  Please install $1 and add the path";
    exit 1;
  fi
};

function installIfNotExistNpm {
  res=$(hasCommand "$1");
  if [ "$res" == "1" ];then
    return 0;
  fi
  cmd="";
  res=$(hasCommand "sudo")
  if [ "$res" == "1" ]; then
    cmd="sudo npm";
  else
    cmd="npm";
  fi
  echo "$cmd install -g $1" | bash;
}

# ---- requirement checking ----

checkCommand "git";
checkCommand "npm";
installIfNotExistNpm "ionic@beta"
installIfNotExistNpm "cordova"

# ---- main body ----
echo -n "app name : ";
read app_name;
ionic start "$app_name" sidemenu --v2
