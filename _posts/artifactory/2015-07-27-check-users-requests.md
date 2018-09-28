---
layout: post
title: Artifactory Check Users Requests
categories: tech
tags:
- Artifactory
- Security
- Active Directory
- LDAP
source_codes:
  - file: _code/check-users-requests/CheckUsersRequests.sh
    language: bash
    title: CheckUsersRequests.sh
  - file: _code/check-users-requests/logstash/logstash.conf
    language: ruby
    title: logstash/logstash.conf
  - file: _code/check-users-requests/FormatLogs.sh
    language: bash
    title: FormatLogs.sh
  - file: _code/check-users-requests/CreateExcelDoc.ps1
    language: powershell
    title: CreateExcelDoc.ps1
---

These scripts grep the Artifactory access logs for user access, the generated output is then formatted via logstash and finally converted to a Excel spreadsheet, during which Active Directory is check to see if the users account is disabled or enabled.

The reason for this script was created is that security needed to ensure that no disabled users had been trying to access Artifactory from outside of the network after they had left the company.

# Steps
1. CheckUsersRequests.sh
2. FormatLogs.sh (logstash is needed)
3. CreateExcelDoc.ps1 (excel is needed)

{% source_code _code/check-users-requests/CheckUsersRequests.sh %}

{% source_code _code/check-users-requests/logstash/logstash.conf %}

{% source_code _code/check-users-requests/FormatLogs.sh %}

{% source_code _code/check-users-requests/CreateExcelDoc.ps1 %}
