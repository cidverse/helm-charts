{{/*
Reusable Ingress Snippet

Parameters:
- context: root chart context (.)
- ingress: the ingress config block (e.g., .Values.ingress or .Values.ingressAdmin)
- service: the service config block (e.g., .Values.service or .Values.serviceAdmin)

Usage:
{{ include "chart-library.snippets.ingress" (dict "context" . "ingress" .Values.ingress "service" .Values.service) }}
{{ include "chart-library.snippets.ingress" (dict "context" . "ingress" .Values.ingressAdmin "service" .Values.serviceAdmin) }}
*/}}
{{- define "chart-library.snippets.ingress" -}}
{{- $root := .context -}}
{{- $ingress := .ingress -}}
{{- $svc := .service -}}
{{- if $ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "chart-library.fullname" $root }}{{ if $ingress.name }}-{{ $ingress.name }}{{ end }}
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
  {{- with $ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- if $ingress.tls }}
  tls:
    {{- range $ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            backend:
              service:
                name: {{ include "chart-library.fullname" $root }}{{ if $svc.name }}-{{ $svc.name }}{{ end }}
                port:
                  number: {{ index $svc.ports 0 "port" }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
