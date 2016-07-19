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
installIfNotExistNpm "cordova"
res=$(hasCommand "ionic");
if [ "$res" == "1" ]; then
  is_v2=$(ionic -v | grep "^2" | wc -l );
  if [ "$is_v2" != 1 ]; then
    installIfNotExistNpm "ionic@beta";
  fi
else
  installIfNotExistNpm "ionic@beta";
fi

# ---- main body ----
echo -n "app name : ";
read app_name;
ionic start "$app_name" sidemenu --v2

cp add_page.sh "$app_name/";
cd "$app_name"
chmod +x add_page.sh

# set translate stuff
npm install --save ng2-translate
mkdir -p "www/assets/i18n";
cd "www/assets/i18n";
echo "{
  \"DEMO\": \"Demo\"
}" > en.json;
cp en.json zh.json;
cp en.json ch.json;
cd "../../../";
cd "app";
echo "
import {provide} from '@angular/core';
import {Http, HTTP_PROVIDERS} from '@angular/http';
import {TranslateService, TranslatePipe, TranslateLoader, TranslateStaticLoader} from 'ng2-translate/ng2-translate';
" | cat - app.ts | tail -n +2 | head -n -1 > temp && mv temp app.ts;
sed -i "14i  , pipes: [TranslatePipe]" app.ts;
echo "ionicBootstrap(MyApp, [[provide(TranslateLoader, {
  useFactory: (http:Http) => new TranslateStaticLoader(http, 'assets/i18n', '.json'),
  deps: [Http]
}), TranslateService]], {});" >> app.ts
cd "../";

# init demo page
echo "Demo" | ./add_page.sh "Page1";
cd "app/pages/demo";
sed -i 's/Page Uno/{{ "DEMO" | translate }}/' demo.html;
cd "../../../";

echo "";
echo "All Done.";
