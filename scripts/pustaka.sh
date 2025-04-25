#!/bin/sh

echo "Running pustaka updater script..."
program_dir="/mnt/share/collapseTool/Senadina"
program="$program_dir/senadina-er"
json_old="$program_dir/metadata.json"

repo_dir="/mnt/share/collapseTool/CollapseLauncher-MetaRepo"
metadataV3_dir="/mnt/share/collapseTool/metadatav3"
json="$metadataV3_dir"
pustaka_dir="$repo_dir/pustaka"
metadata_url="https://github.com/CollapseLauncher/CollapseLauncher-ReleaseRepo/raw/main/metadata/metadatav2_previewconfig.json"

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
git pull origin-ssh main --force
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
  export XMFKILLA_REF_ASB_PATH=$(readlink -f "$program_dir/../tmp_asb/$region")

  echo "Updating $region..."
  echo "Ensure temp directory..."
  echo "XMFKILLA_REF_ASB_PATH is set to $XMFKILLA_REF_ASB_PATH"
  mkdir -p $XMFKILLA_REF_ASB_PATH
  echo "Running command: $program "$region" "$pustaka_dir" "$json" $2 $3 $4"
  $program "$region" "$pustaka_dir" "$json" $2 $3 $4
  retval=$?
  case $retval in
    0)  echo "No changes on $region, skipping...";;
    1)  
      echo "Changes detected for $region!"
      git add .
      git commit -m "Update pustaka for $region @$timestamp"
      git push origin-ssh
      ;;
    -2147483648) echo "Error occurred for $region, skipping...";;
    *) echo "Unexpected return value $retval for $region";;
  esac
  echo
}

# Update all regions
update_region "Hi3SEA" "" "" ""
update_region "Hi3Global" "" "" ""
update_region "Hi3CN" "" "" ""
update_region "Hi3TW" "" "" ""
update_region "Hi3KR" "" "" ""
update_region "Hi3JP" "" "" ""

# Force git stash then push in the end just to make sure everything is clean
git stash
git push origin-ssh

# Script completion
end_timestamp=$(date +%s)
elapsed=$((end_timestamp - timestamp))
echo "Time spent: $elapsed seconds"
