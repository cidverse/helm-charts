{{/*
Common labels
*/}}
{{- define "chart-library.labels" -}}
helm.sh/chart: {{ include "chart-library.chart" . }}
{{ include "chart-library.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart-library.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart-library.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
