#!/bin/sh

echo Running pustaka updater script...
program_dir="/mnt/share/collapseTool/Senadina/"
program="$program_dir/senadina-er"
json="$program_dir/metadata.json"

repo_dir="/mnt/share/collapseTool/CollapseLauncher-MetaRepo"
pustaka_dir="$repo_dir/pustaka/"
metadata_url="https://github.com/CollapseLauncher/CollapseLauncher-ReleaseRepo/raw/main/metadata/metadatav2_previewconfig.json"

timestamp=$(date +%s)
echo Starting at "$timestamp"
echo
echo

if [ ! -d "$repo_dir" ]; then 
  echo "Repo directory does not exist"
  exit 1
fi

cd "$repo_dir"

# cleanup and pull
if [ ! -d "$pustaka_dir" ]; then 
  echo "Pustaka directory does not exist"
  exit 1
fi

echo Doing cleanups and update for MetaRepo
if git diff-index --quiet HEAD --; then
  git stash
fi
eval "$(ssh-agent -s)"
git pull origin-ssh main --force
if [ $? -ne 0 ]; then
  echo Pull failed! Please help...
  exit
fi

# Running updater program
if [ ! -f "$program" ]; then 
  echo "Program does not exist"
  exit 1
fi

chmod +x "$program"

# get newest metadata
wget "$metadata_url" -O "$json"

# do command
echo
echo Updating SEA...
region=Hi3SEA
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

echo Updating Global...
region=Hi3Global
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

echo Updating CN...
region=Hi3CN
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

echo Updating TW...
region=Hi3TW
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

echo Updating KR...
region=Hi3KR
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

echo Updating JP...
region=Hi3JP
$program "$region" "$pustaka_dir" "$json"
retval=$?
if [ $retval -eq 0 ]; then
  echo No changes on $region, skipping...
elif [ $retval -eq 1 ]; then
  echo Changes detected for $region!
  git add .
  git commit -m "Update pustaka for $region @$timestamp"
  git push origin
elif [ $retval -eq -2147483648 ]; then
  echo "Error occured for $region, skipping..."
fi
echo

end_timestamp=$(date +%s)
elapsed=$(( $end_timestamp - $timestamp ))
echo Time spent: $elapsed seconds
