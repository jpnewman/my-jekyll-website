#!/usr/bin/env python3

import unicodedata
import argparse
import os

from bs4 import BeautifulSoup, Doctype, Comment

def parse_args():
    parser = argparse.ArgumentParser(description='Clean CV HTML')
    parser.add_argument('-f', '--file', help='Input HTML file', required=True)
    parser.add_argument('-o', '--outfile', help='Output HTML file', default=None)

    try:
        args = parser.parse_args()
    except argparse.ArgumentError as exc:
        print(exc.message)
        print(exc.argument)
        return None

    if args.outfile is None:
        filename, fileext = os.path.splitext(args.file)
        args.outfile = "{0}_Clean{1}".format(filename, fileext)

    return args


# Based On: https://stackoverflow.com/questions/38168118/remove-comments-from-html-tags
def strip_comments(soup):
    comments = soup.find_all(text=lambda text:isinstance(text, Comment))
    for comment in comments:
       comment.extract()


def strip_tag(tag):
    return BeautifulSoup(''.join(str(child) for child in tag.children), 'html.parser')


def strip_tags(soup, remove_tags):
    for find_tag in remove_tags:
        tag = soup.find(find_tag)
        soup = strip_tag(tag)

    return soup


def strip_attribute(soup, attrs):
    for tag in soup():
        for attribute in attrs:
            del tag[attribute]


def replace_text_ligatures(tag):
    # print(tag.name)
    text = tag.text
    text = text.replace("–", "&ndash;")
    text = text.replace("’", "'")
    text = unicodedata.normalize("NFKD", text)
    # tag.string = text # FIXME: Tag order is incorrect.


def replace_ligatures(soup):
    p_tags = soup.find_all('p')
    for p_tag in p_tags:
        tags = [replace_text_ligatures(tag) for tag in p_tag.find_all()]


def update_list_format(soup):
    p_tags = soup.find_all('p')
    for p_tag in p_tags:
        p_tag.string = "TODO: " + p_tag.text


def clean_html(input_file, output_file):
    remove_tags = ['html', 'body']
    remove_attrs = ["class"]

    html = open(input_file, 'r').read()
    html = html.replace(u'&#160;', u' ')

    soup = BeautifulSoup(html, 'html.parser')

    for item in soup.contents:
        if isinstance(item, Doctype):
            item.extract()

    soup.head.decompose()
    soup.style.decompose()
    # [tag.decompose() for tag in soup("script")]

    strip_comments(soup)
    soup = strip_tags(soup, remove_tags)
    strip_attribute(soup, remove_attrs)

    replace_ligatures(soup)

    # update_list_format(soup)

    # print(soup.prettify())
    with open(output_file, 'w') as f:
        f.write(str(soup))


def main():
    args = parse_args()
    if args is None: return

    clean_html(args.file, args.outfile)

if __name__ == "__main__":
    main()
