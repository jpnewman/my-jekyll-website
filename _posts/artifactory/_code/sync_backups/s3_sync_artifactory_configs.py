#!/usr/bin/python -tt
# -*- coding: utf-8 -*-

"""
This script does the following : -
- Converts Artifactory XML config file to a Chef template.
- Uploads backup files to a S3 bucket.
"""

from collections import OrderedDict
from lxml import etree
import ConfigParser
import socket
import codecs
import gnupg
import glob
import os
import re

# AWS S3 module
import boto

CONFIG_FILENAME = 's3_sync_artifactory_configs.cfg'

REPLACE_ELEMENT_VALUE_MAP = OrderedDict([
    ('./config/logo', {
        'variable': 'logo'}),
    ('./config/footer', {
        'variable': 'footer'}),
    ('./config/localReplications/localReplication/url', {
        'regex_variable': {
            'search_regex': r"^https?://.*?(/.*)$",
            'replace_variable': r"<%if !@replication_host.empty? %><%= @replication_host %>\1<% end %>"
        }
    }),
    ('./config/localReplications/localReplication/enabled', {
        'text': r"<%if @replication_enabled && !@replication_host.empty? %>true<% else %>false<% end %>"}),
    ('./config/localRepositories/localRepository/description', {
        'escape': None})
])


class Options(object):
    """Basic option class for elem2json"""
    __slots__ = ["pretty"]
    pretty = False


def load_config():
    """Loads Configuration file"""

    script_path = os.path.dirname(os.path.realpath(__file__))
    config_file = os.path.join(script_path, CONFIG_FILENAME)

    if not os.path.exists(config_file):
        raise RuntimeError("ERROR: File not found: %s" % config_file)

    config = ConfigParser.RawConfigParser()
    config.read(config_file)

    return config


def indent_xml_elem(elem, level=0):
    """Indents XML Elements"""

    i = "\n" + (level * "    ")
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "    "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent_xml_elem(elem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def convert_config_to_chef_template(config, folder):
    """Converts Artifactory Config XML file into a Chef template"""

    if not os.path.exists(folder):
        raise RuntimeError("ERROR: Folder not found: %s" % folder)

    backup_file = config.get('sync_config', 'artifactory_config_backup_file')
    artifactory_config_file = os.path.join(folder, backup_file)

    if not os.path.exists(artifactory_config_file):
        msg = "ERROR: File not found: %s" % artifactory_config_file
        raise RuntimeError(msg)

    if validate_xml(config, artifactory_config_file) is False:
        msg = "ERROR: Xml file not validate: %s" % artifactory_config_file
        raise RuntimeError(msg)

    parser = etree.XMLParser(ns_clean=True, remove_pis=True, recover=True)
    tree = etree.parse(artifactory_config_file, parser)
    root = tree.getroot()

    convert_xml(root)
    save_transformed_xml(config, root, folder)


def convert_xml(xml_root):
    """Converts XML"""

    path = []
    context = etree.iterwalk(xml_root, events=('start', 'end'))
    for event, element in context:
        if (event == 'start'):
            clean_tag = element.tag

            # Remove namespace
            i = element.tag.find('}')
            if i >= 0:
                clean_tag = element.tag[i+1:]

            path.append(clean_tag)

            if element.text is None:
                continue

            tag_xpath = './' + '/'.join(path)
            if tag_xpath in REPLACE_ELEMENT_VALUE_MAP.keys():
                value = REPLACE_ELEMENT_VALUE_MAP[tag_xpath]
                if 'text' in value.keys():
                    element.clear()
                    element.text = etree.CDATA(value['text'])
                if 'cdata' in value.keys():
                    element.text = etree.CDATA(element.text)
                if 'escape' in value.keys():
                    text = re.sub(r'"', r'&quot;', element.text)
                    element.text = etree.CDATA(text)
                if 'variable' in value.keys():
                    text = "<%= @{0} %>".format(value['variable'])
                    element.clear()
                    element.text = etree.CDATA(text)
                if 'regex_variable' in value.keys():
                    text = re.sub(value['regex_variable']['search_regex'],
                                  value['regex_variable']['replace_variable'],
                                  element.text)
                    element.text = etree.CDATA(text)
        else:
            path.pop()


def save_transformed_xml(config, xml_root, folder):
    """Save XML to file"""

    indent_xml_elem(xml_root)

    chef_template = config.get('sync_config',
                               'artifactory_config_chef_template')
    output_filename_path = os.path.join(folder, chef_template)
    save_xml(xml_root, output_filename_path)

    transform_xml(config, output_filename_path, output_filename_path)


def validate_xml(config, xml_filename):
    """Validates a XML file"""

    if not os.path.exists(xml_filename):
        raise RuntimeError("ERROR: Xml file not found: %s" % xml_filename)

    script_path = os.path.dirname(os.path.realpath(__file__))
    xsd_filename = config.get('backup_xmls', 'artifactory_config_xsd_filename')
    schema_filename = os.path.join(script_path, xsd_filename)

    if not os.path.exists(schema_filename):
        msg = "ERROR: Xml schema ile not found: %s" % schema_filename
        raise RuntimeError(msg)

    with open(schema_filename) as schema_file:
        schema = etree.XMLSchema(etree.parse(schema_file))

    with open(xml_filename) as xml_file:
        xml = etree.parse(xml_file)

    return schema.validate(xml)


def transform_xml(config, xml_filename, output_file_path):
    """Transforms a XMl file"""

    if not os.path.exists(xml_filename):
        raise RuntimeError("ERROR: Xml file not found: %s" % xml_filename)

    script_path = os.path.dirname(os.path.realpath(__file__))
    xslt_filename = config.get('backup_xmls',
                               'artifactory_config_xslt_filename')
    stylesheet_filename = os.path.join(script_path, xslt_filename)

    if not os.path.exists(stylesheet_filename):
        msg = "ERROR: Xml stylesheet ile not found: %s" % stylesheet_filename
        raise RuntimeError(msg)

    with open(xml_filename) as xml_file:
        xml = etree.parse(xml_file)

    with open(stylesheet_filename) as stylesheet_file:
        transform = etree.XSLT(etree.parse(stylesheet_file))

    result = transform(xml)
    transformed_xml = etree.tostring(result,
                                     pretty_print=True,
                                     encoding='utf-8')

    print "Creating file: " + output_file_path
    with codecs.open(output_file_path, 'w', 'utf-8') as output_file:
        docstring = r'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
                    + '\n'
        output_file.write(docstring)
        output_file.write(transformed_xml.decode('utf-8'))
        output_file.close()


def save_xml(xml, output_file_path):
    """Saves XML Document"""

    etree.ElementTree(xml).write(output_file_path,
                                 pretty_print=True,
                                 xml_declaration=True,
                                 encoding='UTF-8',
                                 standalone='yes')


def get_s3_connection(config):
    """Opens S3 Connection"""

    conn = boto.connect_s3(config.get('s3cfg', 'access_key'),
                           config.get('s3cfg', 'secret_key'),
                           is_secure=True,)

    return conn


def list_s3_bucket_files(s3_bucket):
    """List S3 buckets"""

    for key in s3_bucket.list(delimiter="/"):
        print key.name


def create_s3_key(config, file_path):
    """Creates backup S3 key"""

    key = config.get('s3cfg', 's3_backup_prefix').strip('/') + '/' + \
        socket.getfqdn() + '/' + \
        config.get('sync_config',
                   'artifactory_backup_task_version_folder').strip('/') + \
        '/' + os.path.basename(file_path)

    return key


def upload_file_to_s3(config, file_path):
    """Uploads a files to S3"""

    if not os.path.exists(file_path):
        raise RuntimeError("ERROR: File not found: %s" % file_path)

    conn = get_s3_connection(config)

    s3_bucket = conn.get_bucket(config.get('s3cfg', 's3_backup_bucket'))
    # list_s3_bucket_files(s3_bucket)

    s3_key = create_s3_key(config, file_path)
    print 'Uploading S3 file: ' + s3_key

    key = s3_bucket.new_key(s3_key)
    key.set_metadata('Content-Type', 'application/xml')

    if config.getboolean('gpg', 'encrypt_files') is True:
        key.set_metadata('x-amz-meta-s3tools-gpgenc', 'gpg')  # FYI: For s3cmd

    bytes_written = key.set_contents_from_filename(file_path, encrypt_key=True)

    if bytes_written is None:
        return

    file_size = os.stat(file_path).st_size
    if bytes_written != file_size:
        msg = "ERROR: Mismatch in bytes synced to S3 bucket and local file: " \
              "{0} != {1}".format(bytes_written, file_size)
        raise RuntimeError(msg)

    # key.set_acl('private')


def download_file_from_s3(config, s3_file_key, to_file, file_ext=''):
    """Downloads a files from S3"""

    file_ext = file_ext.lower()
    s3_file_key = s3_file_key + file_ext

    conn = get_s3_connection(config)

    s3_bucket = conn.get_bucket(config.get('s3cfg', 's3_backup_bucket'))
    print 'Getting S3 file: ' + s3_file_key

    key = s3_bucket.get_key(s3_file_key)
    if key is None:
        raise RuntimeError("ERROR: Bucket Key not found: %s" % s3_file_key)

    file_extension = os.path.splitext(to_file)[1]
    if file_extension.lower() != file_ext and \
       config.getboolean('gpg', 'encrypt_files') is True:
        to_file += '.gpg'

    key.get_contents_to_filename(to_file)


def upload_config_files_to_s3(config, folder):
    """Uploads sync_config files to S3"""

    if not os.path.exists(folder):
        raise RuntimeError("ERROR: Folder not found: %s" % folder)

    upload_files = ['artifactory_config_backup_file',
                    'artifactory_security_backup_file',
                    'artifactory_config_chef_template']
    for upload_file in upload_files:
        upload_file_config = config.get('sync_config', upload_file)
        upload_file_path = os.path.join(folder, upload_file_config)
        upload_file_to_s3(config, upload_file_path)


def upload_folder_files_to_s3(config, folder, file_ext='*'):
    """Uploads files to S3"""

    if not os.path.exists(folder):
        raise RuntimeError("ERROR: Folder not found: %s" % folder)

    upload_files = glob.glob(os.path.join(folder, file_ext))

    for upload_file_path in upload_files:
        upload_file_to_s3(config, upload_file_path)


def get_gpg(config):
    """Uploading gpg object"""

    gpg = gnupg.GPG(gnupghome='{}/.gnupg'.format(os.path.expanduser('~')),
                    gpgbinary=config.get('gpg', 'gpg_binary'),
                    keyring=config.get('gpg', 'keyring'),
                    secret_keyring=config.get('gpg', 'secret_keyring'),
                    options=['--throw-keyids',
                             '--personal-digest-preferences=sha256',
                             '--s2k-digest-algo=sha256'])

    gpg.encoding = 'latin-1'

    return gpg


def download_config_files_from_s3(config, to_folder, file_ext='.gpg'):
    """Downloads sync_config files from S3"""

    if not os.path.exists(to_folder):
        raise RuntimeError("ERROR: Folder not found: %s" % to_folder)

    download_files = ['artifactory_config_backup_file',
                      'artifactory_security_backup_file',
                      'artifactory_config_chef_template']
    for download_file in download_files:
        download_file_config = config.get('sync_config', download_file)
        download_file_path = os.path.join(to_folder, download_file_config)
        s3_key = create_s3_key(config, download_file_path)
        download_file_from_s3(config, s3_key, download_file_path, file_ext)


def gpg_debug(status):
    """Debug gpg status"""

    print 'ok: ', status.ok
    print 'status: ', status.status
    print 'stderr: ', status.stderr


def encrypt_folder(config, folder, exclude_file_ext=None):
    """Encrypt files within a folder"""

    if not os.path.exists(folder):
        raise RuntimeError("ERROR: Folder not found: %s" % folder)

    if exclude_file_ext is None:
        exclude_file_ext = []
    else:
        exclude_file_ext = [x.lower() for x in exclude_file_ext]

    if '.gpg' not in exclude_file_ext:
        exclude_file_ext.append('.gpg')

    gpg = get_gpg(config)
    for root, dirs, files in os.walk(folder):
        for backup_file in files:
            file_extension = os.path.splitext(backup_file)[1]

            if file_extension.lower() in exclude_file_ext:
                continue

            file_path = os.path.join(root, backup_file)
            with open(file_path, 'rb') as input_file:
                gpg_passphrase = config.get('s3cfg', 'gpg_passphrase')
                status = gpg.encrypt_file(input_file,
                                          recipients=None,
                                          symmetric='AES256',
                                          armor=False,
                                          always_trust=True,
                                          passphrase=gpg_passphrase,
                                          output=file_path + '.gpg')

                if status.ok is False:
                    msg = "ERROR: Encrypting file: %s" % input_file
                    raise RuntimeError(msg)

                # gpg_debug(status)


def decrypt_folder(config, folder):
    """Decrypt files within a folder"""

    if not os.path.exists(folder):
        raise RuntimeError("ERROR: Folder not found: %s" % folder)

    gpg = get_gpg(config)

    for root, dirs, files in os.walk(folder):
        for backup_file in files:
            file_name, file_extension = os.path.splitext(backup_file)

            if file_extension.lower() != '.gpg':
                continue

            file_path = os.path.join(root, backup_file)
            with open(file_path, 'rb') as input_file:
                gpg_passphrase = config.get('s3cfg', 'gpg_passphrase')
                output_file = os.path.join(root, file_name) + '.txt'
                status = gpg.decrypt_file(input_file,
                                          always_trust=True,
                                          passphrase=gpg_passphrase,
                                          output=output_file)

                if status.ok is False:
                    msg = "ERROR: Decrypting file: %s" % input_file
                    raise RuntimeError(msg)

                # gpg_debug(status)


def main():
    """Main function"""

    config = load_config()

    backup_dir = config.get('sync_config', 'artifactory_backup_dir')

    if not os.path.exists(backup_dir):
        raise RuntimeError("ERROR: Folder not found: %s" % backup_dir)

    task_version = config.get('sync_config',
                              'artifactory_backup_task_version_folder')

    for backup_task_folder in [d for d in os.listdir(backup_dir)
                               if os.path.isdir(os.path.join(backup_dir, d))]:

        backup_task_folder = os.path.join(backup_dir, backup_task_folder)
        backup_task_version_folder = os.path.join(backup_task_folder,
                                                  task_version)

        convert_config_to_chef_template(config, backup_task_version_folder)

        if config.getboolean('gpg', 'encrypt_files') is True:
            encrypt_folder(config,
                           backup_task_version_folder,
                           exclude_file_ext=['.txt'])
            # decrypt_folder(config, backup_task_version_folder) # TEST

            upload_folder_files_to_s3(config,
                                      backup_task_version_folder,
                                      file_ext='*.gpg')

            # TEST
            to_folder = os.path.dirname(os.path.realpath(__file__))
            download_config_files_from_s3(config, to_folder)
        else:
            upload_config_files_to_s3(config, backup_task_version_folder)

if __name__ == "__main__":
    main()
