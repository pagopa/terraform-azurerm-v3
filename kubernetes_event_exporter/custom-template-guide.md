# Creating a Custom Template for Kubernetes Event Exporter
This guide explains how to create a custom template for configuring the **Kubernetes Event Exporter**. This tool is commonly used to export Kubernetes events to various targets (e.g., files, Slack, Opsgenie) based on configurable routing rules.
## Configuration Structure
The Kubernetes Event Exporter configuration consists of two main sections:
1. **`receivers`**: Defines the destinations (outputs) for the exported events.
2. **`route`**: Specifies the routing rules for events to be sent to the configured receivers.

### 1. `receivers` Section
**Receivers** are the targets where the events are sent. These could include files, integrations with services (e.g., Slack, Opsgenie), or other endpoints.
#### General Configuration Example
- **File Receiver**: Writes events to a file or directly to `stdout`.
- **Slack Receiver**: Sends notification messages to a Slack channel.
- **Opsgenie Receiver**: Generates Opsgenie alerts for specific types of events.

#### Receiver Examples

1. **File Receiver**:

```yaml
- file:
  layout: {}
  path: /dev/stdout
  name: "dump"
```
2. **Slack Receiver**:

```yaml
   - name: "${slack_receiver_name}"  # Unique name for the receiver
     slack:
       token: "${slack_token}"      # Slack API token
       channel: "${slack_channel}"  # Destination channel
       message: "${slack_message_prefix} {{ .Message }}"
       title: "${slack_title}"
       author_name: "${slack_author}"
       fields:
         namespace: "{{ .Namespace }}"
         reason: "{{ .Reason }}"
         object: "{{ .InvolvedObject.Name }}"
         createdAt: "{{ .GetTimestampISO8601 }}"
```
3. **Opsgenie Receiver**:

```yaml
   - name: "${opsgenie_receiver_name}"
     opsgenie:
       apiKey: "${opsgenie_api_key}"        # Opsgenie API key
       priority: "P2"                       # Alert priority level
       message: "[TAG] {{ .Reason }} for {{ .InvolvedObject.Namespace }}/{{ .InvolvedObject.Name }}"
       alias: "{{ .UID }}"                  # Alert alias
       description: "<pre>{{ toPrettyJson . }}</pre>"  # Detailed message
       tags:
         - "event"
         - "{{ .Reason }}"
         - "{{ .InvolvedObject.Kind }}"
         - "{{ .InvolvedObject.Name }}"
```

### 2. `route` Section
The **route** section defines the logic for routing captured Kubernetes events to the configured receivers.
It's need to be defined like a block to make filter works properly.

#### Key Components:
- **`match`**: Specifies which events should be sent to specific receivers.
- **`drop`**: Filters and excludes certain events. Like by reason (`reason`) or object type (`kind`).
- **`receiver`**: Name of the receiver configured in the `receivers` section.

### Creating the Template
To build a customizable template:
1. Identify possible receivers (e.g., file, Slack, Opsgenie).
2. Separate fixed configurations (e.g., logging to stdout) from optional ones (e.g., Slack or Opsgenie notifications).
3. Use conditional constructs (`%{ if } ... %{ endif }`) to enable optional receivers based on predefined flags or environment variables.
4. Link routing rules to receivers to ensure the correct events are sent to the appropriate targets.
