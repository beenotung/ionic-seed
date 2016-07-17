#!/usr/bin/env bash
# Name
#   seed.sh
#
# Usage
#   ./seed.sh [Option]
#
# Help
#   ./seed.sh --help
#
# Convention
#   the packages are concat line by line for better source control (e.g. git)

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Name : seed.sh";
  echo "";
  echo "Usage : ./seed.sh [Option]";
  echo "";
  echo "Default : install npm local packages";
  echo "";
  echo "Options";
  echo "  -h | --help           show this help message";
  echo "  -f | --full-install   install npm global and local packages";
  exit 0;
fi;

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

# ---- main body ----

# download ionic see
wget https://github.com/driftyco/ionic2-app-base/archive/master.zip -O base.zip
wget https://github.com/driftyco/ionic2-starter-sidemenu/archive/master.zip -O sidemenu.zip
unzip base.zip
unzip sidemenu.zip
rm -rf base.zip sidemenu.zip
mv ionic2-app-base-master/* ./
mv ionic2-app-base-master/.editorconfig ./
mv ionic2-app-base-master/.gitignore ./
rm -rf ionic2-starter-sidemenu-master
rm -rf ionic2-app-base-master

if [ ! -f package.json ]; then
  echo "Warning : there is no package.json";
  echo "  you might use 'npm init' to create it";
  echo -n "continue? (y/n): ";
  read line;
  if [ "$line" != "y" ]; then
    # cancel by user
    exit 1;
  else
    # create npm project
    npm init;
  fi;
fi;

echo "installing npm global packages...";
installIfNotExistNpm "bower";
echo "finish, installed npm global packages";

echo "installing npm local packages...";
cmd="npm install --save-dev";
# concat a list of npm local packages
cmd="$cmd bower";
cmd="$cmd gulp"
cmd="$cmd gulp-clean";
cmd="$cmd gulp-filesize";
cmd="$cmd gulp-sourcemaps";
cmd="$cmd gulp-babel";
#cmd="$cmd babel";
cmd="$cmd babel-preset-es2015";
#cmd="$cmd babel-plugin-transform-runtime";
#cmd="$cmd babel-plugin-transform-es2015-modules-amd";
#cmd="$cmd babel-plugin-transform-es2015-modules-umd";
cmd="$cmd gulp-concat";
cmd="$cmd merge2";
cmd="$cmd gulp-typescript";
cmd="$cmd gulp-sass";
cmd="$cmd gulp-minify-css";
cmd="$cmd gulp-uglify";
cmd="$cmd gulp-rename";
cmd="$cmd gulp-replace";
cmd="$cmd gulp-webserver";
cmd="$cmd ionic@beta";
echo "$cmd";
echo "$cmd" | sh;
echo "finish, installed npm local packages";

echo "installing bower packages...";
if [ ! -f "bower.json" ]; then
  bower init
fi
cmd="bower install"
cmd="$cmd babel-polyfill";
#cmd="$cmd angular";
#cmd="$cmd angular-animate";
cmd="$cmd angular-sanitize";
cmd="$cmd angular-translate";
#cmd="$cmd angular-ui-router";
cmd="$cmd angular-moment";
cmd="$cmd moment";
cmd="$cmd ngCordova";
cmd="$cmd ionic";
#cmd="$cmd ionic-service-core";
cmd="$cmd jquery";
cmd="$cmd jquery-md5";
cmd="$cmd browser";
echo "$cmd";
echo "$cmd" | sh;
echo "finish, installed bower packages";

echo "setting git submodules...";
git submodule init
git submodule update
echo "finish, set git submodules";

#echo "buliding project";
#sh build.sh
#echo "finish, built project";

echo "All finished.";
