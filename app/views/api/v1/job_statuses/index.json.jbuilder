json.array! @job_statuses.collect { |job_status| job_status.to_builder('v1').attributes! }
