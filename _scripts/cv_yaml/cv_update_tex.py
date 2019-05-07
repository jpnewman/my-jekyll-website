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


def escape_tex(text):
    escape_chars = ['&', '#']

    for c in escape_chars:
        text = text.replace(c, f"\\{c}")

    text = text.strip().replace('\n', ' \\\\\n')

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


def write_tex_qualifications(out_file, qualifications):
    text = "\\qualifications{\n"

    for q in qualifications:
        text += apply_tex_template("\\textbf{$NAME}\\\\\\textsc{$DESC\\vspace{1.25mm}} \\\\\n",
                                   {"NAME": escape_tex(q['name']),
                                    "DESC": escape_tex(q['desc'])})

    text += "}\n"

    with open(out_file, 'w') as o:
        o.write(TEX_HEADER)
        o.write(text)


def test_element(elem, name):
    return name in elem and elem[name] is not None


def get_experience_item_or_default(elem, name, default="  {}\n"):
    if name in elem and elem[name] is not None:
        return "  {{{0}}}\n".format(escape_tex(elem[name].strip()))

    return default


def get_experience_items_tex(items):
    text = "  {\\begin{itemize}\n"

    for i in items:
         text += f"    \item {escape_tex(i)}\n"

    text += "  \\end{itemize}\n"
    text += "  }\n"

    return text


def get_experience_tex(experience):
    e = experience

    text = "\\begin{twenty}\n"
    text += "\\twentyitem\n"
    text += f"  {{{e['start_date']}}}\n"
    text += f"  {{{e['end_date']}}}\n"
    text += f"  {{{e['title']}}}\n"

    if test_element(e, 'href'):
        text += f"  {{\\href{{{e['href']}}}{{{e['company']}}}}}\n"
    else:
        text += f"  {{{e['company']}}}\n"

    text += f"  {{{e['location']}}}\n"

    text += get_experience_item_or_default(e, 'summary')

    if test_element(e, 'responsibilities'):
        text += get_experience_items_tex(e['responsibilities'])
    else:
        text += "  {}\n"

    text += get_experience_items_tex(e['achievements'])

    text += "\\end{twenty}\n"

    text += "\n\\vspace{0.75\\baselineskip}\n"

    return text


def write_experience(out_file, experience):
    text = ""

    for e in experience:
        text += get_experience_tex(e)

    with open(out_file, 'w') as o:
        o.write(TEX_HEADER)
        o.write(text)


def write_experience_files(out_dir, experience):
    write_experience(os.path.join(out_dir, "experience_01.tex"), [experience[0]])
    write_experience(os.path.join(out_dir, "experience_02.tex"), experience[1:])


def write_tex_skills(out_file, skills):
    text = ""

    for s in skills:
        text += f"\\{s['id']}{{"
        groups = []
        for g in reversed(s['groups']):
            groups_text = f"{{"
            escape_group_text = [escape_tex(i) for i in g['items']]
            groups_text += " $\\textbullet$ ".join(escape_group_text)
            groups_text += f" / {g['level']}}}"

            groups.append(groups_text)

        text += ", ".join(groups)
        text += f"}}\n\n"

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

        write_tex_qualifications(os.path.join(args.outDir, 'qualifications.tex'),
                                 data['cv']['qualifications'])

        write_tex_skills(os.path.join(args.outDir, 'skills.tex'),
                         data['cv']['skills'])

        write_experience_files(args.outDir, data['cv']['experience'])


if __name__ == "__main__":
    main()
