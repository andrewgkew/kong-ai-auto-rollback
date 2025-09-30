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
Using Konnect Analytics, identify routes throwing non-200 errors in the last 15 minutes.
An issue exists if the number of requests equals the number of non-200 errors (100% failure rate) in the last 15 minutes.
Do not go further back in time than the last 15 minutes when looking for number of requests.

If NO issues are found in the last 15 minutes:
- Send a message to Slack channel {{ .Values.aiagent.slack_channel_id }} with a summary of your findings.

If you find a problematic route:
1. Check the GitHub repository YAML configuration to locate the file that needs changing.
2. Identify the problematic configuration element (route, service, or plugin).

CRITICAL YAML REMOVAL INSTRUCTIONS:
When removing a problematic element from YAML:
- Remove the ENTIRE element including ALL its nested fields
- For plugins: Remove from the `name:` field through the END of the `config:` block and all its nested properties
- For list items: Remove the complete list entry including the leading dash (-)
- Preserve proper YAML indentation for remaining elements
- Remove any trailing empty lines left by the deletion

PLUGIN YAML STRUCTURE (remove ALL of this):

- name: plugin-name
  enabled: true
  config:
    configField1: value1
    configField2: value2
    nestedConfig:
      subField1: value1
      subField2: value2

BEFORE REMOVAL example:

plugins:
- name: rate-limiting
  config:
    minute: 100
- name: problematic-plugin
  enabled: true
  config:
    field1: value1
    field2: value2
- name: cors
  config:
    origins: ["*"]

AFTER REMOVAL example:
plugins:
- name: rate-limiting
  config:
    minute: 100
- name: cors
  config:
    origins: ["*"]

Create a pull request with:

Clear title: "Fix: Remove failing [plugin/route/service] causing 100% error rate"
Description including control plane name, route name, and error analysis

Send to Slack channel {{ .Values.aiagent.slack_channel_id }}:

Control plane name
Route name
Problem description (what was failing and why)
Link to the PR
Complete list of tasks performed to resolve the issue

VALIDATION:
After modifying YAML, verify:

Valid YAML syntax (proper indentation maintained)
No orphaned or incomplete configuration blocks
Related elements are not broken by the removal
{{- end }}
{{- end }}