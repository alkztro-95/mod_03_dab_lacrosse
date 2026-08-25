-- Optimize individual gold table by category
OPTIMIZE {{job.parameters.catalog_name}}.{{job.parameters.schema_gold}}.{{input}}
