{{/*
Render the imagePullSecrets block from global and image-specific pull secrets.

Parameters:
- images: list of image configuration blocks (each may have .pullSecrets)
- context: root chart context (.)

Logic:
- Collect secrets from `.Values.global.imagePullSecrets`.
- Collect secrets from each provided image's `pullSecrets`.
- Support both `string` and `map` with `name` key.

Usage:
{{ include "chart-library.resolvePullSecrets" (dict "images" (list .Values.image1 .Values.image2) "context" .) }}
*/}}
{{- define "chart-library.resolvePullSecrets" -}}
{{- $pullSecrets := list -}}
{{- $ctx := .context -}}

{{- range $ctx.Values.global.imagePullSecrets -}}
  {{- if kindIs "map" . -}}
    {{- $pullSecrets = append $pullSecrets (include "chart-library.template.render" (dict "value" .name "context" $ctx)) -}}
  {{- else -}}
    {{- $pullSecrets = append $pullSecrets (include "chart-library.template.render" (dict "value" . "context" $ctx)) -}}
  {{- end -}}
{{- end -}}

{{- range .images -}}
  {{- range .pullSecrets -}}
    {{- if kindIs "map" . -}}
      {{- $pullSecrets = append $pullSecrets (include "chart-library.template.render" (dict "value" .name "context" $ctx)) -}}
    {{- else -}}
      {{- $pullSecrets = append $pullSecrets (include "chart-library.template.render" (dict "value" . "context" $ctx)) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if not (empty $pullSecrets) -}}
imagePullSecrets:
  {{- range $pullSecrets | uniq }}
  - name: {{ . }}
  {{- end }}
{{- end -}}
{{- end -}}
