---
layout: post
title: Check Artifactory Sync Backups
categories: tech
tags:
- Artifactory
- Backup
source_codes:
  - file: _code/sync_backups/s3_sync_artifactory_configs.cfg
    language: ini
    title: s3_sync_artifactory_configs.cfg
  - file: _code/sync_backups/s3_sync_artifactory_configs.py
    language: python
    title: s3_sync_artifactory_configs.py
---

{% source_code _code/sync_backups/s3_sync_artifactory_configs.cfg %}

This script does the following : -

- Converts Artifactory XML config file to a Chef template.
- Uploads backup files to a S3 bucket.

{% source_code _code/sync_backups/s3_sync_artifactory_configs.py %}
