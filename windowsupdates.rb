#
# Author:: Tim Smith <tsmith@chef.io>
# Copyright:: 2017, Chef Software, Inc <legal@chef.io>
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

Ohai.plugin :WindowsPatches do
  provides "windowspatches"

  collect_data :windows do
    windowspatches Mash.new

    patch_data = shell_out('powershell.exe -NoLogo -NonInteractive -NoProfile -command "Get-HotFix | ConvertTo-Json"')
    parser = FFI_Yajl::Parser.new
    windowspatches["updates"] = []
    windowspatches["details"] = Mash.new
    parser.parse(patch_data.stdout).each do |update|
      windowspatches["updates"] << update["HotFixID"]
      windowspatches["details"][update["HotFixID"]] = Mash.new
      windowspatches["details"][update["HotFixID"]]["description"] = update["Description"]
      windowspatches["details"][update["HotFixID"]]["install_date"] = update["InstalledOn"]["DateTime"]
    end
  end
end
