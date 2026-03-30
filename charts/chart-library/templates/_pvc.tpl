{{/*
Reusable PersistentVolumeClaim snippet.

Parameters:
- context: root chart context (.)
- pvc: persistence config block

Usage:
{{ include "chart-library.snippets.pvc" (dict "context" . "pvc" .Values.persistence) }}
*/}}
{{- define "chart-library.pvcName" -}}
{{- $context := .context -}}
{{- $pvc := .pvc -}}
{{- if $pvc.name -}}
{{- $pvc.name -}}
{{- else -}}
{{- printf "%s-%s" (include "chart-library.fullname" $context) (default "data" $pvc.nameSuffix) -}}
{{- end -}}
{{- end -}}

{{- define "chart-library.snippets.pvc" -}}
{{- $context := .context -}}
{{- $pvc := .pvc -}}
{{- if $pvc.enabled -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "chart-library.pvcName" (dict "context" $context "pvc" $pvc) }}
  namespace: {{ include "chart-library.namespace" $context | quote }}
  labels:
    {{- include "chart-library.labels" $context | nindent 4 }}
    {{- with $pvc.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $pvc.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  accessModes:
    {{- toYaml (default (list "ReadWriteOnce") $pvc.accessModes) | nindent 4 }}
  resources:
    requests:
      storage: {{ default "10Gi" $pvc.size }}
  {{- with $pvc.storageClassName }}
  storageClassName: {{ . | quote }}
  {{- end }}
  {{- with $pvc.volumeMode }}
  volumeMode: {{ . | quote }}
  {{- end }}
{{- end -}}
{{- end -}}
