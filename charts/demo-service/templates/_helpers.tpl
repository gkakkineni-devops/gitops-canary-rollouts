{{- define "demo-service.name" -}}
{{- .Release.Name -}}
{{- end -}}

{{- define "demo-service.labels" -}}
app.kubernetes.io/name: {{ include "demo-service.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
