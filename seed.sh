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
  cmd="$cmd install -g $1";
  echo "$cmd";
  echo "$cmd" | bash;
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
#rm -rf "$app_name";
#cp -rf seed "$app_name";

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
sed -i "/templateUrl: /a \  , pipes: [TranslatePipe]" app.ts;
echo "ionicBootstrap(MyApp, [[provide(TranslateLoader, {
  useFactory: (http:Http) => new TranslateStaticLoader(http, 'assets/i18n', '.json'),
  deps: [Http]
}), TranslateService]], {});" >> app.ts;
sed -i "s/constructor(private platform: Platform)/constructor(\
\n    private platform:Platform\
\n    , public translate:TranslateService\
\n  )/" app.ts;
sed -i "/this.initializeApp();/a \ \ \ \ this.translateConfig();" app.ts;
sed -i "/ initializeApp/i \  translateConfig() {\
\n    let userLang = navigator.language.split('-')[0];\
\n    userLang = /(zh|ch|en)/gi.test(userLang) ? userLang : 'en';\
\n\
\n    this.translate.setDefaultLang('en');\
\n    this.translate.use(userLang);\
\n\
\n    console.log('userLang', userLang);\
\n  }\n" app.ts;
cd "../";

# init demo page
echo "Demo" | ./add_page.sh "Page1" --skip-inject;
cd "app/pages/demo";
sed -i 's/Page Uno/{{ "DEMO" | translate }}/' demo.html;
cd "../../";
sed -i "/import { Page2 }/a import { Demo } from './pages/demo/demo';" app.ts;
sed -i "/this.pages/i \    this.translate.get('DEMO').subscribe(x=>this.pages.push({title: x, component: Demo}));" app.ts;
exit 0;
cd "../";

echo "";
echo "All Done.";
