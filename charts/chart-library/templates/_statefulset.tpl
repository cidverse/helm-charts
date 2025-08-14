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
  template:
    metadata:
      {{- with $sts.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "chart-library.labels" $context | nindent 8 }}
        {{- with $sts.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "chart-library.resolvePullSecrets" (dict "images" (list $sts.image) "context" $context) | nindent 6 }}
      serviceAccountName: {{ include "chart-library.serviceAccountName" (dict "context" $context "serviceAccount" $context.serviceAccount) }}
      {{- with $sts.podSecurityContext }}
      securityContext:
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
          {{- if or $sts.env $sts.extraEnv }}
          env:
          {{- with $sts.env }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $sts.extraEnv }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
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
