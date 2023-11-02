resource "newrelic_alert_policy" "foo" {
  name = "foo"
}

resource "newrelic_infra_alert_condition" "high_disk_usage" {
  policy_id = newrelic_alert_policy.foo.id

  name        = "High disk usage"
  description = "Warning if disk usage goes above 80% and critical alert if goes above 90%"
  type        = "infra_metric"
  event       = "StorageSample"
  select      = "diskUsedPercent"
  comparison  = "above"
  where       = "%frontend%"

  critical {
    duration      = 25
    value         = 40
    time_function = "all"
  }

  warning {
    duration      = 10
    value         = 60
    time_function = "all"
  }
}
// Create a reusable notification destination
resource "newrelic_notification_destination" "email-destination" {
  name = "destination-email"
  type = "EMAIL"
  #email = "1119ankitasharma1999@gmail.com"
  property {
    key = "email"
    value = "1119ankitasharma1999@gmail.com"
  }

  auth_basic {
    user ="username" 
    password = "password"
  }
}

// Create a notification channel to use in the workflow
resource "newrelic_notification_channel" "email-channel" {
  name = "channel-email"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email-destination.id
  product = "IINT" // Please note the product used!

  property {
    key = "payload"
    value = "{}"
    label = "Payload Template"
  }
}

// A workflow that matches issues that include incidents triggered by the policy
resource "newrelic_workflow" "workflow-example" {
  name = "workflow-example"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [newrelic_alert_policy.foo.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.email-channel.id
  }
}
