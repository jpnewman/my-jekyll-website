#!/usr/bin/env python3

import yaml
import argparse
import os

SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))

MARKDOWN_HEADER = """---
layout: cv
title: CV
permalink: /cv/
add_to_navbar: 'true'
weight: 4
---

[//]: # (DO EDIT THIS FILE DIRECTLY!)
[//]: # (This file is generated from data in YAML file ./_data/cv.yaml via 'make cv_update_markdown')
"""


def parse_args():
    cv_yaml_path = os.path.join(SCRIPT_PATH, '../../_data/cv.yaml')
    out_dir = os.path.join(SCRIPT_PATH, '../..')

    parser = argparse.ArgumentParser(description='Updates CV Tex generated files')
    parser.add_argument('-c', '--cvYaml', help='CV Yaml data file', default=cv_yaml_path)
    parser.add_argument('-o', '--outDir', help='Output Directory', default=out_dir)

    try:
        args = parser.parse_args()
    except argparse.ArgumentError as exc:
        print(exc.message)
        print(exc.argument)
        return None

    return args


def test_element(elem, name):
    return name in elem and elem[name] is not None


def gen_item_section(element, header, name):
    text = ""

    if test_element(element, name):
        text += f"\n#### {header}: -\n"
        for r in element[name]:
            text += f"- {r}\n"

    return text


def gen_experience_markdown(experience):
    text = "\n\n# Work Experience\n"

    for e in experience:
        text += f"\n## {e['title']}\n"
        text += f"\n### {e['company']}\n"

        if test_element(e, 'summary'):
            text += f"\n{e['summary']}\n"

        text += gen_item_section(e, 'Responsibilities', 'responsibilities')
        text += gen_item_section(e, 'Key Achievements', 'achievements')

    return text


def gen_qualifications_markdown(qualifications):
    text = "\n\n# Qualifications\n\n"

    for q in qualifications:
        text += f"### {q['name']}\n\n"
        text += "- {0}\n\n".format(q['desc'].replace('\n', ' '))

    return text


def write_markdown(out_file, cv_data):
    text = "\n# Summary\n\n"
    text += "{0}".format(cv_data['summary'].strip())

    # text += "\n\n# Skills\n" # TODO: Implement

    text += gen_experience_markdown(cv_data['experience'])
    text += gen_qualifications_markdown(cv_data['qualifications'])

    with open(out_file, 'w') as o:
        o.write(MARKDOWN_HEADER)
        o.write(text)


def main():
    print("Updating CV Markdown file...")

    args = parse_args()

    with open(args.cvYaml, 'r') as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as error:
            print(error)

    write_markdown(os.path.join(args.outDir, 'cv.md'), data['cv'])


if __name__ == "__main__":
    main()
