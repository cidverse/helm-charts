{{/*
Checks if the target Kubernetes platform supports OpenShift APIs.
*/}}
{{- define "chart-library.capabilities.supportsOpenShiftAPIs" -}}
{{- if or
    (.Capabilities.APIVersions.Has "security.openshift.io/v1")
    (.Capabilities.APIVersions.Has "route.openshift.io/v1")
    (.Capabilities.APIVersions.Has "apps.openshift.io/v1")
  -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
