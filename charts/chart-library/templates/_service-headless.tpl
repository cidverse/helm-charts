{{/*
Reusable headless Service snippet for StatefulSets.

Parameters:
- context: root chart context (.)
- service: service config block (e.g., .Values.service)

Usage:
{{ include "chart-library.snippets.serviceHeadless" (dict "context" . "service" .Values.service) }}
*/}}
{{- define "chart-library.snippets.serviceHeadless" -}}
{{- $root := .context -}}
{{- $svc := .service -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "chart-library.fullname" $root }}{{ if $svc.name }}-{{ $svc.name }}{{ end }}-headless
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
spec:
  clusterIP: None
  ports:
    {{- range $port := $svc.ports }}
    - name: {{ $port.name }}
      port: {{ $port.port }}
      targetPort: {{ default $port.port $port.targetPort }}
      protocol: {{ default "TCP" $port.protocol }}
    {{- end }}
  selector:
    {{- include "chart-library.selectorLabels" $root | nindent 4 }}
{{- end -}}
