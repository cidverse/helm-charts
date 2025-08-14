{{/*
Allow the release namespace to be overridden.
*/}}
{{- define "chart-library.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
