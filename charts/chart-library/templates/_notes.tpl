{{/*
Resolve a primary endpoint string for NOTES output.

Parameters:
- context: root chart context (.)
- route: route config block (optional)
- ingress: ingress config block (optional)
- service: service config block
- routeProtocol: protocol for route host (default: https)
- ingressProtocol: protocol for ingress host (default: http)
- portIndex: service port index for in-cluster fallback (default: 0)

Usage:
{{ include "chart-library.notes.primaryEndpoint" (dict "context" . "route" .Values.route "ingress" .Values.ingress "service" .Values.service) }}
*/}}
{{- define "chart-library.notes.primaryEndpoint" -}}
{{- $root := .context -}}
{{- $route := .route -}}
{{- $ingress := .ingress -}}
{{- $service := .service -}}
{{- $routeProtocol := default "https" .routeProtocol -}}
{{- $ingressProtocol := default "http" .ingressProtocol -}}
{{- $portIndex := default 0 .portIndex -}}
{{- if and $route $route.enabled -}}
  {{- if $route.host -}}
{{ printf "%s://%s" $routeProtocol $route.host }}
  {{- else -}}
{{ printf "Route enabled with auto-generated host. Check: oc get route %s -n %s" (include "chart-library.fullname" $root) $root.Release.Namespace }}
  {{- end -}}
{{- else if and $ingress $ingress.enabled -}}
{{ printf "%s://%s" $ingressProtocol (index (index $ingress.hosts 0) "host") }}
{{- else -}}
{{ printf "%s.%s.svc.cluster.local:%v" (include "chart-library.fullname" $root) $root.Release.Namespace (index (index $service.ports $portIndex) "port") }}
{{- end -}}
{{- end -}}
