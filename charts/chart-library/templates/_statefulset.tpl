{{/*
Reusable StatefulSet Snippet

Parameters:
- context: root chart context (.)
- service: service config block (e.g., .Values.service or .Values.serviceAdmin)
- statefulset: statefulset config block (e.g., .Values.statefulset or .Values.statefulsetAdmin)

Usage:
{{ include "chart-library.snippets.statefulset" (dict "context" . "service" .Values.service "statefulset" .Values.statefulset) }}
*/}}
{{- define "chart-library.snippets.statefulset" -}}
{{- $context := .context -}}
{{- $svc := .service -}}
{{- $sts := .statefulset -}}
{{- $resolvedInitContainers := list -}}
{{- $resolvedInitImages := list -}}

{{- if eq (kindOf $sts.initContainers) "map" -}}
  {{- range $name := keys $sts.initContainers | sortAlpha -}}
    {{- $init := index $sts.initContainers $name -}}
    {{- $enabled := true -}}
    {{- if hasKey $init "enabled" -}}
      {{- $enabled = $init.enabled -}}
    {{- end -}}
    {{- if $enabled -}}
      {{- $image := default (dict) $init.image -}}
      {{- $repository := $image.repository | default $sts.image.repository -}}
      {{- $tag := $image.tag | default $sts.image.tag | default $context.Chart.AppVersion -}}
      {{- $pullPolicy := $image.pullPolicy | default $sts.image.pullPolicy -}}

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
{{- else if eq (kindOf $sts.initContainers) "slice" -}}
  {{- $resolvedInitContainers = $sts.initContainers -}}
{{- end -}}

{{- $resolvedInitContainers = concat $resolvedInitContainers (default (list) $sts.extraInitContainers) -}}
{{- if $sts.enabled -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "chart-library.fullname" $context }}{{ if $sts.nameSuffix }}-{{ $sts.nameSuffix }}{{ end }}
  namespace: {{ include "chart-library.namespace" $context | quote }}
  labels:
    {{- include "chart-library.labels" $context | nindent 4 }}
spec:
  serviceName: {{ include "chart-library.fullname" $context }}{{ if $svc.nameSuffix }}-{{ $svc.nameSuffix }}{{ end }}-headless
  {{- if not $sts.autoscaling.enabled }}
  replicas: {{ $sts.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "chart-library.selectorLabels" $context | nindent 6 }}
      {{- with $sts.selectorLabels }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
  template:
    metadata:
      {{- with $sts.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "chart-library.labels" $context | nindent 8 }}
        {{- with $sts.selectorLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with $sts.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "chart-library.resolvePullSecrets" (dict "images" (concat (list $sts.image) $resolvedInitImages) "context" $context) | nindent 6 }}
      serviceAccountName: {{ include "chart-library.serviceAccountName" (dict "context" $context "serviceAccount" $context.Values.serviceAccount) }}
      {{- with $sts.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $resolvedInitContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $context.Chart.Name }}
          {{- with $sts.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ $sts.image.repository }}:{{ $sts.image.tag | default $context.Chart.AppVersion }}"
          imagePullPolicy: {{ $sts.image.pullPolicy }}
          ports:
            {{- range $port := $svc.ports }}
            - name: {{ $port.name }}
              containerPort: {{ $port.port }}
              protocol: {{ default "TCP" $port.protocol }}
            {{- end }}
          {{- if $sts.command }}
          command: {{ toYaml $sts.command | nindent 12 }}
          {{- end }}
          {{- if $sts.args }}
          args: {{ toYaml $sts.args | nindent 12 }}
          {{- end }}
          {{- $baseEnv := $sts.env }}
          {{- $overrideEnv := $sts.extraEnv }}
          {{- if hasKey $sts "defaultEnv" }}
            {{- $baseEnv = $sts.defaultEnv }}
            {{- $overrideEnv = concat (default (list) $sts.env) (default (list) $sts.extraEnv) }}
          {{- end }}
          {{- if or $baseEnv $overrideEnv }}
          env:
            {{- include "chart-library.snippets.mergedEnv" (dict "env" $baseEnv "extraEnv" $overrideEnv) | nindent 12 }}
          {{- end }}
          {{- if or $sts.envFrom $sts.extraEnvFrom }}
          envFrom:
            {{- with $sts.envFrom }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- with $sts.extraEnvFrom }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- end }}
          {{- with $sts.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $sts.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $sts.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $sts.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $sts.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with $sts.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $sts.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $sts.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $sts.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}
{{- end -}}
