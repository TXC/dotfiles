#!/bin/bash

source "${HOME}/bin/colors.sh"

# Ensure two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_truth_dir> <target_compare_dir>"
    exit 1
fi

VERBOSE="0"
SHOW_ALL="0"

TRUTH_DIR=$(realpath "$1")
TARGET_DIR=$(realpath "$2")

echo -e "--- Starting Audit: Comparing ${FG_YELLOW}$TARGET_DIR${RESET} against ${FG_YELLOW}$TRUTH_DIR${RESET} ---"

# Find all Chart.yaml files in the truth directory
find "$TRUTH_DIR" -name "Chart.yaml" | \
while read -r truth_chart_path; do
    # Calculate relative path from the root of the repo
    rel_path="${truth_chart_path#$TRUTH_DIR/}"
    target_chart_path="$TARGET_DIR/$rel_path"
    
    # Get the app name/path for display
    app_context=$(dirname "$(dirname "$rel_path")")
    
    echo -e "\n[ Checking App: ${FG_YELLOW}$app_context${RESET} ]"

    # 1. Check if the file even exists in the target
    if [[ ! -f "$target_chart_path" ]]; then
        echo -e "  ${FG_RED}✖ Missing:${RESET} $rel_path does not exist in target."
        continue
    fi

    # 2. Extract Chart Version
    truth_version=$(yq '.version' "$truth_chart_path")
    target_version=$(yq '.version' "$target_chart_path")

    if [[ "$truth_version" != "$target_version" ]]; then
        echo -e "  ${FG_RED}≠ Chart Version Mismatch:${RESET} Truth ($truth_version) vs Prod ($target_version)"
    else
        echo -e "  ${FG_GREEN}✓ Chart Version Match:${RESET} ($truth_version)"
    fi

    # 3. Extract and Compare Dependencies
    # We use yq to output deps as 'name:version' strings for easy comparison
    truth_deps=$(yq '.dependencies[] | .name + ":" + .version' "$truth_chart_path" 2>/dev/null | sort)
    target_deps=$(yq '.dependencies[] | .name + ":" + .version' "$target_chart_path" 2>/dev/null | sort)

    if [[ "$truth_deps" != "$target_deps" ]]; then
        echo -e "  ${FG_RED}≠ Dependency Mismatch:${RESET}"
        
        # Use diff to show exactly what's wrong with the deps
        if [ $VERBOSE -ne "0" ]; then
            echo -e "  ${FG_YELLOW}Truth Dependencies:${RESET}"
            while read -r t; do
                echo -e "    $t"
            done <<< "$truth_deps"
            #for t in "$truth_deps"; do
            #    echo -e "    $t"
            #done
            echo -e "  ${FG_YELLOW}Target Dependencies:${RESET}"
            while read -r t; do
                echo -e "    $t"
            done <<< "$target_deps"
            echo -e "  ${FG_YELLOW}Differences:${RESET}"
        fi
        diff <(echo "$truth_deps") <(echo "$target_deps") | sed 's/^/    /'
    else
        if [ $SHOW_ALL -ne "0" ]; then
            if [[ -z "$truth_deps" ]]; then
                echo -e "  ${FG_YELLOW}○ No dependencies defined.${RESET}"
            else
                echo -e "  ${FG_GREEN}✓ All Dependencies Match.${RESET}"
            fi
        fi
    fi
done

echo -e "\n--- Audit Complete ---"