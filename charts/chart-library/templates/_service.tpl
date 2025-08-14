{{/*
Reusable Service Snippet

Parameters:
- context: root chart context (.)
- service: the service config block (e.g., .Values.service or .Values.serviceAdmin)

Usage:
{{ include "chart-library.snippets.service" (dict "context" . "service" .Values.service) }}
{{ include "chart-library.snippets.service" (dict "context" . "service" .Values.serviceAdmin) }}
*/}}
{{- define "chart-library.snippets.service" -}}
{{- $root := .context -}}
{{- $svc := .service -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "chart-library.fullname" $root }}{{ if $svc.name }}-{{ $svc.name }}{{ end }}
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
spec:
  type: {{ $svc.type }}
  ports:
    {{- range $port := $svc.ports }}
    - name: {{ $port.name }}
      port: {{ $port.port }}
      targetPort: {{ default $port.name $port.targetPort | default $port.port }}
      protocol: {{ default "TCP" $port.protocol }}
    {{- end }}
  selector:
    {{- include "chart-library.selectorLabels" $root | nindent 4 }}
{{- end -}}
