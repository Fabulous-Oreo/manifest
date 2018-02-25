#!/bin/bash
#
# Copyright 2017 Kshitij Gupta
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function patch()
{
  branch=oreo-mr1
  # ==================================================
  # Repos synced from local_manifest
  whitelist=(
    manifest
    device_oneplus_bacon
    device_oppo_common
    device_sony_taoshan
    external_sony_boringssl-compat
    hardware_qcom_camera
    hardware_qcom_audio-caf
    hardware_qcom_media-caf
    kernel_oneplus_msm8974
    kernel_sony_msm8930
    packages_apps_Snap-bacon
    vendor_oneplus
    vendor_sony
  )
  # ==================================================
  # Repo root
  
  if [ !$(declare -f croot > /dev/null; echo $?) ]; then
    while [ ! -e './build/envsetup.sh' ]; do
      cd ../;
    done;
    source ./build/envsetup.sh;
  fi;
  croot;
  # ==================================================
  # CAF HAL detection
  if [ ! -d "hardware/qcom/audio/.git" ]; then
    echo -e "CAF Audio HAL detected. Whitelisting hardware/qcom/audio";
    whitelist+=('hardware_qcom_audio');
  fi
  if [ ! -d "hardware/qcom/display/.git" ]; then
    echo -e "CAF Display HAL detected. Whitelisting hardware/qcom/display";
    whitelist+=('hardware_qcom_display');
  fi
  if [ ! -d "hardware/qcom/media/.git" ]; then
    echo -e "CAF Media HAL detected. Whitelisting hardware/qcom/media";
    whitelist+=('hardware_qcom_media');
  fi
  # ==================================================
  # Rebase
  for repo in $(curl -s https://api.github.com/orgs/Fabulous-Oreo/repos\?per_page\=200 | grep html_url | awk 'NR%2 == 0' | cut -d ':' -f 2-3 | tr -d '",'); do
  {
    for clone_repo in ${whitelist[@]}; do
    { 
      if [ "$(echo $repo | cut -d '/' -f 5)" = "$clone_repo" ]
      then
        echo ""; 
        echo -e "\e[0;36mIgnoring whitelisted repo! ($(echo $repo | cut -d '/' -f 5))\e[0m";
        echo "";
        continue 2
      fi
    }
    done; 
    echo "";
    echo -e "\e[1;32mRebasing $(echo $repo | cut -d '/' -f 5)...\e[0m";
    cd $(echo $repo | cut -d '/' -f 5 | sed 's/_/\//g');
    git pull $repo $branch --rebase;
    croot;
  }
  done;
  # ==================================================
  unset whitelist;
  unset branch;
  # ==================================================
}
