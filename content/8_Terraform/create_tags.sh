counter=/tmp/counter
echo 0 > /tmp/counter
for file in *md; do

  w=$(cat $counter)
  cat << EOF > $file
---
title: ${file/.md/}
weight: $w
---

## Objectifs
-
-
-



## Rappel des objectifs
-
-
-


EOF
  
let $(( w++ ))
echo -n $w > $counter
done 


