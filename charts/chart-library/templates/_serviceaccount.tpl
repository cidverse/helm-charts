{{/*
Reusable ServiceAccount Snippet

Parameters:
- context: root chart context (.)
- serviceAccount: service account config block (e.g., .Values.serviceAccount or .Values.adminServiceAccount)

Usage:
{{ include "chart-library.snippets.serviceaccount" (dict "context" . "serviceAccount" .Values.serviceAccount) }}
*/}}
{{- define "chart-library.snippets.serviceaccount" -}}
{{- $root := .context -}}
{{- $sa := .serviceAccount -}}
{{- if $sa.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ default (include "chart-library.fullname" $root) $sa.name }}
  namespace: {{ include "chart-library.namespace" $root }}
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
  {{- with $sa.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ $sa.automount }}
{{- end }}
{{- end -}}

{{/*
Get the name of the ServiceAccount to use

Parameters:
- context: root chart context (.)
- serviceAccount: service account config block (e.g., .Values.serviceAccount or .Values.adminServiceAccount)

Usage:
{{ include "chart-library.serviceAccountName" (dict "context" . "serviceAccount" .Values.serviceAccount) }}
*/}}
{{- define "chart-library.serviceAccountName" -}}
{{- $root := .context -}}
{{- $sa := .serviceAccount -}}
{{- if $sa.create }}
{{- default (include "chart-library.fullname" $root) $sa.name }}
{{- else }}
{{- default "default" $sa.name }}
{{- end }}
{{- end }}
