#!/bin/sh

echo "Running pustaka updater script..."
program_dir="/workspace"
program="$program_dir/senadina-er"

repo_dir="/workspace/CollapseLauncher-MetaRepo"
metadataV3_dir="/workspace/metadatav3"
json="$metadataV3_dir"
pustaka_dir="$repo_dir/pustaka"

timestamp=$(date +%s)
echo "Starting at $timestamp"
echo

# Ensure required directories exist
if [ ! -d "$repo_dir" ]; then
  echo "Repo directory does not exist"
  exit 1
fi

if [ ! -d "$pustaka_dir" ]; then
  echo "Pustaka directory does not exist"
  exit 1
fi

# Pull latest changes from the repository
echo "Doing cleanups and updating MetaRepo..."
cd "$repo_dir" || exit 1
if git diff-index --quiet HEAD --; then
  git stash
fi

eval "$(ssh-agent -s)"
git pull origin main --force
git checkout main || { echo "Pull failed! Please help..."; exit 1; }

# Ensure program exists and is executable
if [ ! -f "$program" ]; then
  echo "Program does not exist"
  exit 1
fi
chmod +x "$program"

# Download metadata files
echo "Fetching the latest metadata files..."
for file in config_master.json config_Hi3SEA.json config_Hi3CN.json config_Hi3Global.json config_Hi3JP.json config_Hi3KR.json config_Hi3TW.json stamp.json; do
  wget "https://github.com/CollapseLauncher/CollapseLauncher-ReleaseRepo/raw/refs/heads/main/metadata/v3/preview/$file" -O "$metadataV3_dir/$file"
done

# Function to update a region
update_region() {
  region="$1"

  echo "Updating $region..."

  echo "Running command: $program \"$region\" \"$pustaka_dir\" \"$json\" $2 $3 $4"
  $program "$region" "$pustaka_dir" "$json" $2 $3 $4

  # Check if there are any staged or unstaged changes
  if [ "$(git status --porcelain)" != "" ]; then
    echo "Changes detected for $region!"
    git add .
    git commit -m "Update pustaka for $region @$timestamp"
    git push origin
  else
    echo "No changes on $region, skipping..."
  fi

  echo
}

# Update all regions
update_region "Hi3SEA" "" "" ""
update_region "Hi3Global" "" "" ""
update_region "Hi3CN" "" "" ""
update_region "Hi3TW" "" "" ""
update_region "Hi3KR" "" "" ""
update_region "Hi3JP" "" "" ""

# Force git push in the end just to make sure everything is clean
git add .
git commit -m "Leftovers from run @$timestamp"
git push origin

# Script completion
end_timestamp=$(date +%s)
elapsed=$((end_timestamp - timestamp))
echo "Time spent: $elapsed seconds"
