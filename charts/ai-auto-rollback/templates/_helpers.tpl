{{/*
Expand the name of the chart.
*/}}
{{- define "aiautorollback.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}