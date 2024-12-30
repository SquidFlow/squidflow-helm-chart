{{/*
Expand the name of the chart.
*/}}
{{- define "squidflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "squidflow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "squidflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "squidflow.labels" -}}
helm.sh/chart: {{ include "squidflow.chart" . }}
{{ include "squidflow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "squidflow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "squidflow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend image pull policy
*/}}
{{- define "squidflow.backendImagePullPolicy" -}}
{{- .Values.backend.image.pullPolicy | default "IfNotPresent" }}
{{- end }}

{{/*
Frontend image pull policy
*/}}
{{- define "squidflow.frontendImagePullPolicy" -}}
{{- .Values.frontend.image.pullPolicy | default "IfNotPresent" }}
{{- end }}