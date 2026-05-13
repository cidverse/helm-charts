{{/*
Reusable OpenShift Route snippet.

Parameters:
- context: root chart context (.)
- route: route config block (e.g., .Values.route)
- service: service config block (e.g., .Values.service)

Usage:
{{ include "chart-library.snippets.route" (dict "context" . "route" .Values.route "service" .Values.service) }}
*/}}
{{- define "chart-library.snippets.route" -}}
{{- $root := .context -}}
{{- $route := .route -}}
{{- $svc := .service -}}
{{- if and $route.enabled (eq (include "chart-library.capabilities.supportsOpenShiftAPIs" $root | trim) "true") -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ include "chart-library.fullname" $root }}{{ if $route.name }}-{{ $route.name }}{{ end }}
  namespace: {{ include "chart-library.namespace" $root | quote }}
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
    {{- with $route.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $route.host }}
  host: {{ . | quote }}
  {{- end }}
  wildcardPolicy: {{ default "None" $route.wildcardPolicy }}
  to:
    kind: Service
    name: {{ include "chart-library.fullname" $root }}{{ if $svc.name }}-{{ $svc.name }}{{ end }}
    weight: {{ default 100 $route.weight }}
  port:
    targetPort: {{ default (index (index $svc.ports 0) "name") $route.targetPort }}
  {{- if and $route.tls $route.tls.enabled }}
  tls:
    termination: {{ default "edge" $route.tls.termination }}
    insecureEdgeTerminationPolicy: {{ default "Redirect" $route.tls.insecureEdgeTerminationPolicy }}
  {{- end }}
{{- end }}
{{- end -}}
