#!/usr/bin/env python3

import yaml
import argparse
import os

SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))

from string import Template


TEX_HEADER = """% DO EDIT THIS FILE DIRECTLY!
% This file is generated from data in YAML file ../../../_data/cv.yaml via 'make cv_update_tex'

"""


class TexTemplate(Template):
    delimiter = '$'
    pattern = r'''
    \$(?:
      (?P<escaped>\$) |   # Escape sequence of two delimiters
      (?P<named>[_a-z][_a-z0-9]*)      |   # delimiter and a Python identifier
      {(?P<braced>[_a-z][_a-z0-9]*)}   |   # delimiter and a braced identifier
      (?P<invalid>)              # Other ill-formed delimiter exprs
    )
    '''


def parse_args():
    cv_yaml_path = os.path.join(SCRIPT_PATH, '../../_data/cv.yaml')
    template_dir = os.path.join(SCRIPT_PATH, './tex_templates')
    out_dir = os.path.join(SCRIPT_PATH, '../../_docs/latex/generated')

    parser = argparse.ArgumentParser(description='Updates CV Tex generated files')
    parser.add_argument('-c', '--cvYaml', help='CV Yaml data file', default=cv_yaml_path)
    parser.add_argument('-t', '--templateDir', help='Template Directory', default=template_dir)
    parser.add_argument('-o', '--outDir', help='Output Directory', default=out_dir)

    try:
        args = parser.parse_args()
    except argparse.ArgumentError as exc:
        print(exc.message)
        print(exc.argument)
        return None

    return args


def print_elem_by_name(elem, name):
    if name in elem and elem[name] is not None:
        print(elem[name].strip())


def escape_tex(text):
    escape_chars = ['&', '#']

    for c in escape_chars:
        text = text.replace(c, f"\\{c}")

    return text


def apply_tex_template(template, mappings):
    t = TexTemplate(template)
    return t.substitute(mappings)


def write_tex_from_template(in_file, out_file, mappings):
    s = apply_tex_template(open(in_file, 'r').read(),
                       mappings)

    with open(out_file, 'w') as o:
        o.write(TEX_HEADER)
        o.write(s)


def write_tex_projects(out_file, projects):
    text = "\\projects{\n"

    for p in projects:
        text += apply_tex_template("\\textbf{\\href{$HREF}{$TITLE}}\n",
                                   {"HREF": p['href'],
                                    "TITLE": escape_tex(p['title']),})

        text += "\\begin{itemize}\n"
        for i in p['items']:
            text += "  \\item {0}\n".format(escape_tex(i))
        text += "\\end{itemize}\n"

    text += "}\n"

    with open(out_file, 'w') as o:
        o.write(TEX_HEADER)
        o.write(text)


def main():
    print("Updating CV tex files...")

    args = parse_args()

    with open(args.cvYaml, 'r') as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as error:
            print(error)

        write_tex_from_template(os.path.join(args.templateDir, 'info.tex'),
                                os.path.join(args.outDir, 'info.tex'),
                                {"CV_NAME_FIRST": data['cv']['name']['first'].upper(),
                                 "CV_NAME_SURNAME": data['cv']['name']['surname'].upper(),
                                 "CV_TITLE_01": data['cv']['titles'][0],
                                 "CV_TITLE_02": data['cv']['titles'][1]})

        write_tex_from_template(os.path.join(args.templateDir, 'hypersetup.tex'),
                                os.path.join(args.outDir, 'hypersetup.tex'),
                                {"DOC_TITLE": data['cv']['doc']['title'],
                                 "DOC_SUBJECT": data['cv']['doc']['subject'],
                                 "DOC_AUTHOR": data['cv']['doc']['author'],
                                 "DOC_KEYWORDS": data['cv']['doc']['keywords'][0]})

        write_tex_from_template(os.path.join(args.templateDir, 'contacts.tex'),
                                os.path.join(args.outDir, 'contacts.tex'),
                                {"CONTACT_LINKEDIN": data['cv']['contacts']['linkedin'],
                                 "CONTACT_GITHUB": data['cv']['contacts']['github'],
                                 "CONTACT_WEBSITE": data['cv']['contacts']['website']['domain']})

        write_tex_from_template(os.path.join(args.templateDir, 'summary.tex'),
                                os.path.join(args.outDir, 'summary.tex'),
                                {"SUMMARY": data['cv']['summary'].strip().replace('\n', ' \\\\\n')})

        write_tex_projects(os.path.join(args.outDir, 'projects.tex'),
                           data['cv']['projects'])


if __name__ == "__main__":
    main()