#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

export FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json"
export FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json"

source scripts/lib/windows.sh
source scripts/lib/displays.sh

chrome_matches="$(match_windows "google chrome")"
[[ "$chrome_matches" == *$'chrome-pricing\tGoogle Chrome\tPricing Page'* ]]
[[ "$chrome_matches" == *$'chrome-docs\tGoogle Chrome\tDocs'* ]]

pricing_matches="$(match_windows "Pricing")"
[[ "$pricing_matches" == $'chrome-pricing\tGoogle Chrome\tPricing Page\t740\t530'* ]]

display_matches="$(match_displays "Studio")"
[[ "$display_matches" == $'studio-display\tStudio Display\t2792\t720'* ]]

no_matches="$(match_displays "Missing")"
[[ -z "$no_matches" ]]
