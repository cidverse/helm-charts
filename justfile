_default:
    @just -l

build +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    helm package --destination .tmp "charts/{{CHART}}"

lint +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    helm lint --strict "charts/{{CHART}}"

render +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    helm template "{{CHART}}" "charts/{{CHART}}" \
        --values "charts/{{CHART}}/values.yaml" \
        --namespace default \
        --include-crds \
        --debug

deploy +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    helm upgrade --install "{{CHART}}" "charts/{{CHART}}" \
        --values "charts/{{CHART}}/values.yaml" \
        --namespace test-namespace \
        --create-namespace

undeploy +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    helm uninstall "{{CHART}}" --namespace test-namespace

release +CHART:
    helm dependency build --skip-refresh "charts/{{CHART}}"
    ./scripts/release.sh "{{CHART}}"
