#!/usr/bin/env python3

from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    def __init__(self):
        self.reset()
        self.strict = False
        self.convert_charrefs= True
        self.data = []
        self.stripTags = ['html', 'span']

    def handle_decl(self, decl):
        # self.data.append("<!{0}>".format(decl))
        pass

    def handle_starttag(self, startTag, attrs):
        if startTag not in self.stripTags:
            self.data.append(self.create_tag_str(startTag, attrs))

    def handle_endtag(self, endTag):
        if endTag not in self.stripTags:
            self.data.append("</{0}>".format(endTag))

    def handle_startendtag(self, startendTag, attrs):
        if startendTag not in self.stripTags:
            self.data.append(self.create_tag_str(startendTag, attrs, True))

    def handle_comment(self, data):
        self.data.append("<!-- {0} -->".format(data.strip()))

    def handle_data(self, d):
        self.data.append(d)

    def create_tag_str(self, tag, attrs=None, startendtag=False):
        tag_attr = ""
        startend_tag = ""

        if startendtag:
            startend_tag = "/"

        if attrs:
            for attr in attrs:
                if '"'in attr[1]:
                    tag_attr += " {0}='{1}'".format(attr[0], attr[1])
                else:
                    tag_attr += " {0}=\"{1}\"".format(attr[0], attr[1])

        return "<{0}{1}{2}>".format(tag, tag_attr, startend_tag)

    def get_data(self):
        return ''.join(self.data)


def strip_tags():
    parser = MyHTMLParser()
    with open('_cv/_cv.html', 'r') as f:
        parser.feed(str(f.read()))

    return parser.get_data()


def main():
    with open('cv.html', 'w') as f:
        f.write(strip_tags())

if __name__ == "__main__":
    main()
