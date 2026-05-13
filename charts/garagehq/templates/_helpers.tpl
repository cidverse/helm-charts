{{- define "garagehq.configSecretName" -}}
{{- if .Values.configSecret.name -}}
{{- .Values.configSecret.name -}}
{{- else -}}
{{- printf "%s-config" (include "chart-library.fullname" .) -}}
{{- end -}}
{{- end -}}
