{{/*
Render a value that may itself contain Helm template syntax.

Why:
Helm does not automatically evaluate {{ ... }} inside values.yaml.
If you have templated values (e.g., `name: "{{ .Release.Name }}-secret"`), you must use `tpl` to render them with a given context.

This helper:
- Detects if the value contains template markers ("{{").
- Uses `tpl` to render them with the provided root context or optional scope.
- Supports strings and YAML-serializable objects (objects are converted to YAML first).
- If the value contains no templates, returns it unchanged.

Parameters:
- value: the value to render (string or YAML-serializable object)
- root: the root chart context (.)
- scope (optional): additional scope to make available as .RelativeScope in the template

Usage:
{{ include "chart-library.template.render" (dict "value" .Values.someValue "root" $) }}
{{ include "chart-library.template.render" (dict "value" .Values.someValue "root" $ "scope" $myScope) }}
*/}}
{{- define "chart-library.template.render" -}}
{{- $val := ternary .value (.value | toYaml) (typeIs "string" .value) -}}

{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
    {{- tpl (cat "{{- with $.RelativeScope -}}" $val "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $val .context }}
  {{- end }}
{{- else }}
  {{- $val }}
{{- end }}
{{- end -}}
