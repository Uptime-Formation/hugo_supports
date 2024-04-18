#!/bin/bash

which pdfnice || { echo "!!! Missing pdfnice! Please use the bin/pdfnice script at the root of the project" : exit 1 ; }

set -e 

PDF_NAME="Terraform.pdf"
APP_PATH=$( cd $(dirname $0) && pwd )
TMPDIR=$(cd "${APP_PATH}" && mkdir -p _pdf && echo "${APP_PATH}/_pdf")

cd "$APP_PATH"

rm -f "${TMPDIR}"/*md 
cp *md "${TMPDIR}/"
cd "${TMPDIR}"
# ls ../../../static
sed -i -r "s=/img/=../../../static/img/=" *md

DATE=$(date +"%d/%m/%Y")
LIST=()
for file in *\.md; do
  pdfname="${file/.md/}.pdf"
  if [[ "$file" == "01-Introduction.md" ]]; then
    sed -i -r "s=%DATE%=$DATE=" $file
  else
    content=$(cat $file )
    title=$( cat $file | grep '^#' | head -n 1| sed 's/^# //')
    cat <<EOF > $file
---
title: "$title"
author: [Uptime Formation]
date: "$DATE"
keywords: [Teraform, Devops]
titlepage: true
titlepage-text-color: "3366ff"
titlepage-rule-color: "3366ff"
titlepage-rule-height: 4
book: true
...
EOF
    echo "$content" >> $file
  fi
  LIST+=($pdfname)
  echo "Convert $file to $pdfname"
  ~/bin/pdfnice $file $pdfname
done

echo Uniting pdffiles
pdfunite ${LIST[@]} ${PDF_NAME}

mv ${PDF_NAME} "${APP_PATH}"
echo "File available : ${APP_PATH}/${PDF_NAME}"

rm -rf ${TMPDIR}
