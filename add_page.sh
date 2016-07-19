#!/usr/bin/env bash

Demo="Demo";
if [ $# == 1 ]; then
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

cd app/pages;

# copy from demo
cp -r "$demo" "$page";

# rename to page name
cd "$page";
rename "$demo" "$page" *;
sed -i "s/$Demo/$Page/g" *;
sed -i "s/$demo/$page/g" *;
sed -i "s/$DEMO/$PAGE/g" *;

cd ../../theme;
echo "" >> app.core.scss
echo "@import \"../pages/$page/$page\";" >> app.core.scss
