#!/usr/bin/env bash
set -euo pipefail

# Usage: ./release.sh <chart-name> [forceUpdate]
# Example: ./release.sh nexus-oss

CHART_NAME="$1"
FORCE_UPDATE="${2:-false}"

CHART_DIR="./charts/${CHART_NAME}"
if [ ! -d "$CHART_DIR" ]; then
    echo "Error: Chart directory '$CHART_DIR' not found."
    exit 1
fi

# get version from Chart.yaml
CHART_VERSION=$(grep -E '^version:' "$CHART_DIR/Chart.yaml" | awk '{print $2}' | tr -d '"')
if [ -z "$CHART_VERSION" ]; then
    echo "Error: Could not determine chart version from $CHART_DIR/Chart.yaml"
    exit 1
fi
CHART_TGZ="${CHART_NAME}-${CHART_VERSION}.tgz"

# registries
registries=(
  "oci://ghcr.io/cidverse/helm-charts"
  "oci://registry.gitlab.com/cidverse/helm-charts"
)

# package chart
TMP_DIR=$(mktemp -d)
helm package "$CHART_DIR" --destination "$TMP_DIR"

# push chart
for registry in "${registries[@]}"; do
    chartRef="${registry}/${CHART_NAME}:${CHART_VERSION}"

    echo "Checking ${chartRef}..."
    if skopeo inspect --raw "docker://${registry#oci://}/$CHART_NAME:$CHART_VERSION" &>/dev/null && [[ "$FORCE_UPDATE" == false ]]; then
        echo "[${chartRef}] skipping - already exists"
    else
        echo "[${chartRef}] pushing..."
        helm push "$TMP_DIR/$CHART_TGZ" "$registry"
    fi
done
