{{/*
Merges environment variable lists by `name`.

Entries from `extraEnv` override entries from `env` with the same `name`.
New entries from `extraEnv` are appended.
*/}}
{{- define "chart-library.snippets.mergedEnv" -}}
{{- $env := default (list) .env -}}
{{- $extraEnv := default (list) .extraEnv -}}
{{- $extraByName := dict -}}
{{- $baseNames := dict -}}
{{- $merged := list -}}

{{- range $item := $extraEnv -}}
  {{- if and (kindIs "map" $item) (hasKey $item "name") -}}
    {{- $_ := set $extraByName (get $item "name") $item -}}
  {{- end -}}
{{- end -}}

{{- range $item := $env -}}
  {{- if and (kindIs "map" $item) (hasKey $item "name") -}}
    {{- $name := get $item "name" -}}
    {{- $_ := set $baseNames $name true -}}
    {{- if hasKey $extraByName $name -}}
      {{- $merged = append $merged (get $extraByName $name) -}}
    {{- else -}}
      {{- $merged = append $merged $item -}}
    {{- end -}}
  {{- else -}}
    {{- $merged = append $merged $item -}}
  {{- end -}}
{{- end -}}

{{- range $item := $extraEnv -}}
  {{- if and (kindIs "map" $item) (hasKey $item "name") -}}
    {{- $name := get $item "name" -}}
    {{- if not (hasKey $baseNames $name) -}}
      {{- $merged = append $merged $item -}}
    {{- end -}}
  {{- else -}}
    {{- $merged = append $merged $item -}}
  {{- end -}}
{{- end -}}

{{- toYaml $merged -}}
{{- end -}}
