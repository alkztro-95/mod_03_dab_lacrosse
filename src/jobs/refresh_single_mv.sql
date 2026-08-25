-- Refresh metric view
REFRESH MATERIALIZED VIEW {{job.parameters.catalog_name}}.{{job.parameters.schema_gold}}.{{input}}
