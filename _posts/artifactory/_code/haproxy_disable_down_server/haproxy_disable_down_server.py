#!/usr/bin/python
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4

import os
import subprocess
import csv
import ConfigParser
import re
from smtplib import SMTP
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def load_config():
    script_path = os.path.dirname(os.path.realpath(__file__))
    config_filename = 'haproxy_disable_down_server.cfg'

    config_file = os.path.join(script_path, config_filename)

    if not os.path.exists(config_file):
        raise RuntimeError('ERROR: File not found: %s' % config_file)

    config = ConfigParser.RawConfigParser()
    config.read(config_file)

    version = get_haproxy_version(config)
    config.set('haproxy', 'version', version)

    return config

def unix_socket_cmd(socket, command):
    print 'echo "%s" | socat stdio %s' % (command, socket)

    proc1 = subprocess.Popen(['echo', command], stdout=subprocess.PIPE, shell=False)
    proc2 = subprocess.Popen(['socat', 'stdio', socket], stdin=proc1.stdout, shell=False, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
    output = proc2.communicate()

    if proc2.returncode:
        msg = "Socket error: %s" % proc2.returncode

        if output:
            msg += "\n%s" % output

        raise RuntimeError(msg)

    return output

def get_info(config):
    info = {}

    pattern = "^(.*?):(.*?)$"
    re_pattern = re.compile(pattern, re.IGNORECASE)

    output = unix_socket_cmd(config.get('haproxy', 'socket'), "show info")

    for line in output[0].split('\n'):
        match = re_pattern.match(line)
        if match is not None:
            info[match.group(1).strip()] = match.group(2).strip()

    return info

def get_haproxy_version(config):
    info = get_info(config)
    return info['Version']

def get_server_stat(config):
    stats = {}

    output = unix_socket_cmd(config.get('haproxy', 'socket'), "show stat")

    res = output[0].split('\n')
    res = [x for x in res if x]

    reader = csv.reader(res, delimiter=',', quotechar="'")
    header = reader.next()
    header[0] = header[0].replace("#", "").strip()

    for row in reader:
        prop = {}
        for i in range(0, len(header) - 1):
            prop[header[i]] = row[i]

        key = "%s/%s" % (prop['pxname'], prop['svname'])
        stats[key] = prop

    return stats

def disable_server(socket, server):
    cmd = "disable server %s" % server
    unix_socket_cmd(socket, cmd)

def disable_servers(config, servers):
    for server in servers:
        disable_server(config.get('haproxy', 'socket'), server)

def enable_server(socket, server):
    cmd = "enable server %s" % server
    unix_socket_cmd(socket, cmd)

def enable_servers(config, servers):
    for server in servers:
        enable_server(config.get('haproxy', 'socket'), server)

def get_servers_via_stats(stats, stat_status='DOWN', stat_type=2):
    servers = {}

    for key, value in stats.iteritems():
        if int(value['type']) == stat_type and value['status'].lower() == stat_status.lower():
            servers[key] = value

    return servers

def send_email(config, from_email, to_emails, msg):
    print 'Sending e-mail...'
    try:
        conn = SMTP(config.get('smtp', 'server'), config.getint('smtp', 'port'), timeout=30)
        conn.set_debuglevel(True)

        username = config.get('smtp', 'username').strip()
        password = config.get('smtp', 'password').strip()

        if username != "":
            print 'Login into SMTP server...'
            conn.login(username, password)

        try:
            conn.sendmail(from_email, to_emails, msg)
        finally:
            conn.quit()
    except Exception, exc:
        raise exc

def send_email_servers_down(config, servers):
    if not config.getboolean('email', 'send_email'):
        print 'INFO: No e-mail sent!'
        return

    print 'Composing e-mail...'

    email_to = config.get('email', 'to').split('\n')
    email_to = [x for x in email_to if x]
    email_to = [x.strip() for x in email_to]
    email_to = ','.join(email_to)

    msg = MIMEMultipart('alternative')
    msg['Subject'] = config.get('email', 'subject')
    msg['Form'] = config.get('email', 'from')
    msg['To'] = email_to
    msg['X-Priority'] = '1'

    stats_uri = config.get('haproxy', 'stats_uri')

    servers_text = ""
    for server in servers:
        servers_text += server

    text = config.get('email', 'message_text').format(servers_text, stats_uri)

    servers_html = '<table cellspacing="0" cellpadding="10" width="100%">'
    headers = ['pxname', 'svname', 'status', 'check_status']

    servers_html += '<tr style="text-align: center;">'
    servers_html += '<td>&nbsp;</td>'
    servers_html += '<td>&nbsp;</td>'
    for header in headers:
        servers_html += '<td><b>%s</b></td>' % header
    servers_html += '</tr>'

    for key, value in servers.iteritems():
        servers_html += '<tr style="text-align: center;">'
        servers_html += '<td style="color: #FFF; background-color: #D04040"><h2>!</h2></td>'
        servers_html += "<td>%s</td>" % key

        for k in headers:
            servers_html += '<td>%s</td>' % value[k]

        servers_html += '</tr>'

    servers_html += '</table>'

    stats_uri_html = '<a href="%s">%s</a>' % (stats_uri, stats_uri)
    html = config.get('email', 'message_html').format(servers_html, stats_uri_html)

    text_part = MIMEText(text, 'plain')
    html_part = MIMEText(html, 'html')

    msg.attach(text_part)
    msg.attach(html_part)

    send_email(config, config.get('email', 'from'), email_to, msg.as_string())

def main():
    config = load_config()

    stats = get_server_stat(config)
    down_servers = get_servers_via_stats(stats)
    if len(down_servers) > 0:
        disable_servers(config, down_servers)
        send_email_servers_down(config, down_servers)

if __name__ == "__main__":
    main()
