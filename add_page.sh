#!/usr/bin/env bash
# ./add_page.sh [Demo --skip-inject]
#
# Example : echo Demo | ./add_page.sh Page1 --skip-inject
#
# Example : echo Login | ./add_page.sh
#

Demo="Demo";
if [ $# != 0 ]; then
  Demo="$1";
fi
demo=$(echo "$Demo" | tr '[:upper:]' '[:lower:]');
DEMO=$(echo "$Demo" | tr '[:lower:]' '[:upper:]');

if [ ! -d "app/pages/$demo" ]; then
  echo "Error : demo page is not exist";
  exit 1;
fi

# input page name
echo "create page base on $Demo";
echo -n "new page name: ";
read Page;
page=$(echo "$Page" | tr '[:upper:]' '[:lower:]');
PAGE=$(echo "$Page" | tr '[:lower:]' '[:upper:]');

if [ -d "app/pages/$page" ]; then
  echo "Error : $Page already exist";
  exit 1
fi

cd "app/pages";

# copy from demo
cp -r "$demo" "$page";

# rename to page name
cd "$page";
rename "$demo" "$page" *;
sed -i "s/$Demo/$Page/g" *;
sed -i "s/$demo/$page/g" *;
sed -i "s/$DEMO/$PAGE/g" *;

cd "../../theme";
echo "" >> app.core.scss
echo "@import \"../pages/$page/$page\";" >> app.core.scss

cd "../../";
if [ "$2" != "--skip-inject" ]; then
  cd "app";
  sed -i "/pages\/$demo\/$demo/i import { $Page } from './pages/$page/$page';" app.ts;
  sed -i "/this.translate.get('$DEMO')/i \    this.translate.get('$PAGE').subscribe(x=>this.pages.push({title: x, component: $Page}));" app.ts;
  cd "../www/assets/i18n";
  sed -i "/$DEMO/a\
\  , \"$PAGE\": \"$Page\"" en.json;
  cd "../../../";
fi
