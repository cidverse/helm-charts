{{/*
Reusable Deployment Snippet

Parameters:
- context: root chart context (.)
- service: service config block (e.g., .Values.service or .Values.serviceAdmin)
- deployment: deployment config block (e.g., .Values.deployment or .Values.deploymentAdmin)

Usage:
{{ include "chart-library.snippets.deployment" (dict "context" . "service" .Values.service "deployment" .Values.deployment) }}
*/}}
{{- define "chart-library.snippets.deployment" -}}
{{- $root := .context -}}
{{- $svc := .service -}}
{{- $dep := .deployment -}}
{{- $resolvedInitContainers := list -}}
{{- $resolvedInitImages := list -}}

{{- if eq (kindOf $dep.initContainers) "map" -}}
  {{- range $name := keys $dep.initContainers | sortAlpha -}}
    {{- $init := index $dep.initContainers $name -}}
    {{- $enabled := true -}}
    {{- if hasKey $init "enabled" -}}
      {{- $enabled = $init.enabled -}}
    {{- end -}}
    {{- if $enabled -}}
      {{- $image := default (dict) $init.image -}}
      {{- $repository := $image.repository | default $dep.image.repository -}}
      {{- $tag := $image.tag | default $dep.image.tag | default $root.Chart.AppVersion -}}
      {{- $pullPolicy := $image.pullPolicy | default $dep.image.pullPolicy -}}

      {{- $container := dict
        "name" $name
        "image" (printf "%s:%s" $repository $tag)
        "imagePullPolicy" $pullPolicy
      -}}

      {{- with $init.command -}}
        {{- $_ := set $container "command" . -}}
      {{- end -}}
      {{- with $init.args -}}
        {{- $_ := set $container "args" . -}}
      {{- end -}}

      {{- $env := concat (default (list) $init.env) (default (list) $init.extraEnv) -}}
      {{- if gt (len $env) 0 -}}
        {{- $_ := set $container "env" $env -}}
      {{- end -}}

      {{- $envFrom := concat (default (list) $init.envFrom) (default (list) $init.extraEnvFrom) -}}
      {{- if gt (len $envFrom) 0 -}}
        {{- $_ := set $container "envFrom" $envFrom -}}
      {{- end -}}

      {{- with $init.securityContext -}}
        {{- $_ := set $container "securityContext" . -}}
      {{- end -}}
      {{- with $init.volumeMounts -}}
        {{- $_ := set $container "volumeMounts" . -}}
      {{- end -}}
      {{- with $init.resources -}}
        {{- $_ := set $container "resources" . -}}
      {{- end -}}

      {{- $resolvedInitContainers = append $resolvedInitContainers $container -}}
      {{- $resolvedInitImages = append $resolvedInitImages (dict "pullSecrets" (default (list) $image.pullSecrets)) -}}
    {{- end -}}
  {{- end -}}
{{- else if eq (kindOf $dep.initContainers) "slice" -}}
  {{- $resolvedInitContainers = $dep.initContainers -}}
{{- end -}}

{{- $resolvedInitContainers = concat $resolvedInitContainers (default (list) $dep.extraInitContainers) -}}
{{- if $dep.enabled -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "chart-library.fullname" $root }}{{ if $dep.nameSuffix }}-{{ $dep.nameSuffix }}{{ end }}
  namespace: {{ include "chart-library.namespace" $root | quote }}
  labels:
    {{- include "chart-library.labels" $root | nindent 4 }}
spec:
  {{- if not $dep.autoscaling.enabled }}
  replicas: {{ $dep.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "chart-library.selectorLabels" $root | nindent 6 }}
  template:
    metadata:
      {{- with $dep.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "chart-library.labels" $root | nindent 8 }}
        {{- with $dep.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "chart-library.resolvePullSecrets" (dict "images" (concat (list $dep.image) $resolvedInitImages) "context" $root) | nindent 6 }}
      serviceAccountName: {{ include "chart-library.serviceAccountName" (dict "context" $root "serviceAccount" $dep.serviceAccount) }}
      {{- with $dep.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $resolvedInitContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $root.Chart.Name }}
          {{- with $dep.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ $dep.image.repository }}:{{ $dep.image.tag | default $root.Chart.AppVersion }}"
          imagePullPolicy: {{ $dep.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ $svc.port }}
              protocol: TCP
          {{- with $dep.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $dep.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $dep.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $dep.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with $dep.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $dep.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $dep.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $dep.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}
{{- end -}}
