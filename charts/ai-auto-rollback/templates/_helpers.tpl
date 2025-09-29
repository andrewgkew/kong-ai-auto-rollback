{{/*
Expand the name of the chart.
*/}}
{{- define "aiautorollback.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define the Prompt
*/}}
{{- define "ai_prompt" -}}
{{- if .Values.aiagent.prompt }}
{{- .Values.aiagent.prompt }}
{{- else -}}
Using Konnect Analytics which route is throwing a non 200 error in the last 15 minutes? If there are no issues in the last 15 minutes then send a message to Slack channel with id of {{ .Values.aiagent.slack_channel_id }} with a summary of your findings. If you find a route that is causing the error check the github repository YAML configuration to locate the file that needs changing. Create a pull request to resolve this issue. You will be working in files that define configuration in YAML so please make sure you remove all the necessary files, so if its an element in a YAML list please remove the entire element. Please make sure you complete all the changes in 1 commit and not multiple. Then return the name of the control plane and then name of the route. Send that information to Slack channel with id of {{ .Values.aiagent.slack_channel_id }} and give a description as to what the problem is and a link to the PR that you created and a list of all the tasks you performed to achieve this.
{{- end }}
{{- end }}